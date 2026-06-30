import 'package:get/get.dart';

import 'widget/custom_snackbar.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) {
    showCustomSnackBar(response.statusText, getXSnackBar: getXSnackBar);
  }
}
