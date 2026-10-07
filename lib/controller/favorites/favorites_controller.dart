import 'package:get/get.dart';

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

class FavoritesController extends GetxController {
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

  bool contains(int? listingId) =>
      listingId != null && listingIds.contains(listingId);

  Future<void> load() async {
    if (!isAuthenticated()) return;
    status.value = FavoritesStatus.loading;
    errorMessage.value = null;
    try {
      final snapshot = await repository.load();
      listingIds
        ..clear()
        ..addAll(snapshot.listingIds);
      items.assignAll(snapshot.items);
      status.value =
          items.isEmpty ? FavoritesStatus.empty : FavoritesStatus.content;
    } catch (error) {
      errorMessage.value = error.toString();
      status.value = FavoritesStatus.error;
    }
  }

  Future<FavoriteActionOutcome> requestToggle({
    required int? listingId,
    int? productId,
  }) async {
    if (!isAuthenticated()) return FavoriteActionOutcome.loginRequired;
    if (listingId == null || listingId <= 0) {
      return FavoriteActionOutcome.invalidIdentity;
    }
    try {
      final result = await repository.toggle(listingId);
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
      errorMessage.value = error.toString();
      return FavoriteActionOutcome.failed;
    }
  }
}
