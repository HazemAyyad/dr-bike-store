import '../../controller/favorites/favorites_controller.dart';
import 'custom_snackbar.dart';

void showFavoriteFeedback(FavoriteActionOutcome outcome) {
  switch (outcome) {
    case FavoriteActionOutcome.added:
      showCustomSnackBar('تمت إضافة المنتج إلى المفضلة.', isError: false);
    case FavoriteActionOutcome.removed:
      showCustomSnackBar('تمت إزالة المنتج من المفضلة.', isError: false);
    case FavoriteActionOutcome.failed:
      showCustomSnackBar('تعذر تحديث المفضلة. حاول مجددًا.', isError: true);
    case FavoriteActionOutcome.invalidIdentity:
      showCustomSnackBar('هذا المنتج غير متاح للمفضلة.', isError: true);
    case FavoriteActionOutcome.loginRequired:
      break;
  }
}
