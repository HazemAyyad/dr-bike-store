import 'package:doctor_bike/controller/favorites/favorites_controller.dart';
import 'package:doctor_bike/repository/favorites/favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guest favorite action is gated without a remote mutation', () async {
    final repository = _FakeFavoritesGateway();
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => false,
    );

    expect(
      await controller.requestToggle(listingId: 9),
      FavoriteActionOutcome.loginRequired,
    );
    expect(repository.toggledIds, isEmpty);
  });

  test('malformed listing identity is rejected locally', () async {
    final repository = _FakeFavoritesGateway();
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );

    expect(
      await controller.requestToggle(listingId: 0),
      FavoriteActionOutcome.invalidIdentity,
    );
    expect(repository.toggledIds, isEmpty);
  });

  test('server add result is reflected by listing identity', () async {
    final repository = _FakeFavoritesGateway(isFavorite: true);
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );

    expect(
      await controller.requestToggle(listingId: 44, productId: 2),
      FavoriteActionOutcome.added,
    );
    expect(controller.contains(44), isTrue);
    expect(repository.toggledIds, [44]);
  });

  test('server remove result clears listing identity', () async {
    final repository = _FakeFavoritesGateway(isFavorite: false);
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );
    controller.listingIds.add(44);

    expect(
      await controller.requestToggle(listingId: 44),
      FavoriteActionOutcome.removed,
    );
    expect(controller.contains(44), isFalse);
    expect(controller.status.value, FavoritesStatus.empty);
  });

  test('load restores persisted favorite identities', () async {
    final repository = _FakeFavoritesGateway(initialIds: {7, 8});
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );

    await controller.load();

    expect(controller.listingIds, {7, 8});
    expect(controller.status.value, FavoritesStatus.empty);
  });

  test('remote failure is explicit and does not fabricate success', () async {
    final controller = FavoritesController(
      repository: _FakeFavoritesGateway(throwOnToggle: true),
      isAuthenticated: () => true,
    );

    expect(
      await controller.requestToggle(listingId: 4),
      FavoriteActionOutcome.failed,
    );
    expect(controller.contains(4), isFalse);
  });
}

class _FakeFavoritesGateway implements FavoritesGateway {
  _FakeFavoritesGateway({
    this.isFavorite = true,
    this.throwOnToggle = false,
    this.initialIds = const {},
  });

  final bool isFavorite;
  final bool throwOnToggle;
  final Set<int> initialIds;
  final List<int> toggledIds = [];

  @override
  Future<FavoriteSnapshot> load() async =>
      FavoriteSnapshot(listingIds: initialIds, items: const []);

  @override
  Future<FavoriteToggleResult> toggle(int listingId) async {
    if (throwOnToggle) throw StateError('network failure');
    toggledIds.add(listingId);
    return FavoriteToggleResult(listingId: listingId, isFavorite: isFavorite);
  }
}
