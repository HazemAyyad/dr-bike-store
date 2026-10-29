import 'package:get/get.dart';
import '../../core/functions/store_session_boundary.dart';

import '../../core/model/get_all_item_model.dart';
import '../../repository/favorites/favorites_repository.dart';

enum FavoritesStatus { initial, loading, content, empty, error }

enum FavoriteActionOutcome {
  loginRequired,
  added,
  removed,
  invalidIdentity,
  failed,
}

class FavoritesController extends GetxController with StoreSessionAware {
  FavoritesController({
    required this.repository,
    required this.isAuthenticated,
  });

  final FavoritesGateway repository;
  final bool Function() isAuthenticated;
  final status = FavoritesStatus.initial.obs;
  final listingIds = <int>{}.obs;
  final items = <Item>[].obs;
  final errorMessage = RxnString();

  @override
  void clearSessionData() {
    listingIds.clear();
    items.clear();
    errorMessage.value = null;
    status.value = FavoritesStatus.initial;
  }

  bool contains(int? listingId) =>
      listingId != null && listingIds.contains(listingId);

  Future<void> load() async {
    final generation = sessionGeneration;
    if (!isAuthenticated()) return;
    status.value = FavoritesStatus.loading;
    errorMessage.value = null;
    try {
      final snapshot = await repository.load();
      if (!sessionIsCurrent(generation)) return;
      listingIds
        ..clear()
        ..addAll(snapshot.listingIds);
      items.assignAll(snapshot.items);
      status.value =
          items.isEmpty ? FavoritesStatus.empty : FavoritesStatus.content;
    } catch (error) {
      if (!sessionIsCurrent(generation)) return;
      errorMessage.value = error.toString();
      status.value = FavoritesStatus.error;
    }
  }

  Future<FavoriteActionOutcome> requestToggle({
    required int? listingId,
    int? productId,
  }) async {
    final generation = sessionGeneration;
    if (!isAuthenticated()) return FavoriteActionOutcome.loginRequired;
    if (listingId == null || listingId <= 0) {
      return FavoriteActionOutcome.invalidIdentity;
    }
    try {
      final result = await repository.toggle(listingId);
      if (!sessionIsCurrent(generation)) {
        return FavoriteActionOutcome.loginRequired;
      }
      if (result.isFavorite) {
        listingIds.add(result.listingId);
      } else {
        listingIds.remove(result.listingId);
        items.removeWhere((item) => item.listingId == result.listingId);
      }
      if (items.isEmpty && !result.isFavorite) {
        status.value = FavoritesStatus.empty;
      }
      return result.isFavorite
          ? FavoriteActionOutcome.added
          : FavoriteActionOutcome.removed;
    } catch (error) {
      if (!sessionIsCurrent(generation)) {
        return FavoriteActionOutcome.loginRequired;
      }
      errorMessage.value = error.toString();
      return FavoriteActionOutcome.failed;
    }
  }
}
