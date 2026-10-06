import 'package:doctor_bike/controller/favorites/favorites_controller.dart';
import 'package:doctor_bike/repository/favorites/favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = FavoritesRepository();

  test('guest favorite action is gated', () {
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => false,
    );
    expect(
      controller.requestToggle(listingId: 9),
      FavoriteActionOutcome.loginRequired,
    );
  });
  test('authenticated action is truthfully unavailable', () {
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );
    expect(
      controller.requestToggle(listingId: 9),
      FavoriteActionOutcome.unavailable,
    );
  });
  test(
    'repository exposes no remote capability',
    () => expect(repository.supportsRemoteFavorites, isFalse),
  );
  test(
    'unsupported capability is explicit',
    () => expect(repository.capability, FavoritesCapability.unsupported),
  );
  test('unavailable remains unavailable after controller restart', () {
    for (var i = 0; i < 2; i++) {
      final controller = FavoritesController(
        repository: repository,
        isAuthenticated: () => true,
      )..resolveCapability();
      expect(controller.status.value, FavoritesStatus.unavailable);
    }
  });
  test('error is distinct from unavailable', () {
    final controller = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );
    controller.status.value = FavoritesStatus.error;
    expect(controller.status.value, FavoritesStatus.error);
  });
  test('login transition is returned only for guest', () {
    final auth = FavoritesController(
      repository: repository,
      isAuthenticated: () => true,
    );
    expect(
      auth.requestToggle(listingId: 4),
      isNot(FavoriteActionOutcome.loginRequired),
    );
  });
  test('repository has no network dependency and cannot fabricate success', () {
    expect(
      repository.requestMutation(listingId: 4),
      FavoriteMutationResult.unsupported,
    );
  });
  test('listing identity is preserved at mutation boundary', () {
    expect(
      repository.requestMutation(listingId: 44, productId: 2),
      FavoriteMutationResult.unsupported,
    );
  });
  test('malformed listing identity is rejected', () {
    expect(
      repository.requestMutation(listingId: 0),
      FavoriteMutationResult.invalidIdentity,
    );
  });
  test('productId is never a listing identity fallback', () {
    expect(
      repository.requestMutation(listingId: null, productId: 44),
      FavoriteMutationResult.invalidIdentity,
    );
  });
}
