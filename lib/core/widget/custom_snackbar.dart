import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/dimensions.dart';
import '../constants/styles.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
}) {
  if (message != null && message.isNotEmpty) {
    if (getXSnackBar) {
      Get.showSnackbar(
        GetSnackBar(
          backgroundColor: isError ? Colors.red : Colors.green,
          message: message,
          maxWidth: 500,
          duration: const Duration(seconds: 5),
          snackStyle: SnackStyle.FLOATING,
          margin: const EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            bottom: 100,
          ),
          borderRadius: Dimensions.radiusSmall,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          margin: const EdgeInsets.only(
            right: Dimensions.paddingSizeSmall,
            top: Dimensions.paddingSizeSmall,
            bottom: Dimensions.paddingSizeSmall,
            left: Dimensions.paddingSizeSmall,
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          content: Text(
            message,
            style: robotoMedium.copyWith(color: Colors.white),
          ),
        ),
      );
    }
  }
}
