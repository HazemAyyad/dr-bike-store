import 'package:get/get.dart';

import '../../repository/favorites/favorites_repository.dart';

enum FavoritesStatus { initial, unavailable, error }

enum FavoriteActionOutcome { loginRequired, unavailable, invalidIdentity }

class FavoritesController extends GetxController {
  FavoritesController({
    required this.repository,
    required this.isAuthenticated,
  });

  final FavoritesRepository repository;
  final bool Function() isAuthenticated;
  final status = FavoritesStatus.initial.obs;

  @override
  void onInit() {
    resolveCapability();
    super.onInit();
  }

  void resolveCapability() {
    status.value =
        repository.supportsRemoteFavorites
            ? FavoritesStatus.error
            : FavoritesStatus.unavailable;
  }

  FavoriteActionOutcome requestToggle({
    required int? listingId,
    int? productId,
  }) {
    if (!isAuthenticated()) return FavoriteActionOutcome.loginRequired;
    final result = repository.requestMutation(
      listingId: listingId,
      productId: productId,
    );
    if (result == FavoriteMutationResult.invalidIdentity) {
      return FavoriteActionOutcome.invalidIdentity;
    }
    status.value = FavoritesStatus.unavailable;
    return FavoriteActionOutcome.unavailable;
  }
}
