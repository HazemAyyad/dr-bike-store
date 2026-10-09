import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'store_feedback_notice.dart';

void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = false,
  String? title,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  if (message != null && message.isNotEmpty) {
    StoreFeedbackNotice.show(
      title:
          title ??
          (isError
              ? 'storeFeedbackErrorTitle'.tr
              : 'storeFeedbackSuccessTitle'.tr),
      message: message,
      tone: isError ? StoreFeedbackTone.error : StoreFeedbackTone.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
  }
}
