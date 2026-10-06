import 'package:get/get.dart';

import 'widget/custom_snackbar.dart';
import 'functions/handingData.dart';

class ApiChecker {
  static StoreResponseKind classify(
    Response response, {
    bool Function(Object? body)? parser,
  }) => StoreResponseClassifier.classify(response, parser: parser);

  static void checkApi(Response response, {bool getXSnackBar = false}) {
    final message = switch (response.statusCode) {
      401 || 403 => 'يرجى تسجيل الدخول للمتابعة',
      0 || 1 => 'تعذر الاتصال بالشبكة',
      _ => 'تعذر إكمال الطلب. حاول مرة أخرى.',
    };
    showCustomSnackBar(message, getXSnackBar: getXSnackBar);
  }
}
