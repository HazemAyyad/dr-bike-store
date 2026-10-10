import 'dart:async';

import 'package:get/get.dart';

import '../../controller/favorites/favorites_controller.dart';
import '../helper/route_helper.dart';
import 'custom_snackbar.dart';

void showFavoriteFeedback(FavoriteActionOutcome outcome) {
  switch (outcome) {
    case FavoriteActionOutcome.added:
      showCustomSnackBar(
        'storeFavoriteAdded'.tr,
        isError: false,
        title: 'storeFeedbackAddedTitle'.tr,
        actionLabel: 'storeViewFavorites'.tr,
        onAction: () => unawaited(_openFavorites()),
      );
    case FavoriteActionOutcome.removed:
      showCustomSnackBar('storeFavoriteRemoved'.tr, isError: false);
    case FavoriteActionOutcome.failed:
      showCustomSnackBar('storeFavoriteUpdateFailed'.tr, isError: true);
    case FavoriteActionOutcome.invalidIdentity:
      showCustomSnackBar('storeFavoriteUnavailable'.tr, isError: true);
    case FavoriteActionOutcome.loginRequired:
      break;
  }
}

Future<void> _openFavorites() async {
  await Get.toNamed(RouteHelper.favorites);
}
