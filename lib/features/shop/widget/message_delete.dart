import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';

void showLogoutDialog(
  BuildContext context, {
  required void Function() onPressed,
}) {
  showDialog(
    barrierColor: const Color(0xffd9d9d9).withOpacity(0.45),
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        title: Center(
          child: Text(
            "Do you want to remove this product from the cart ?".tr,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.red,
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          _buildDialogButton("Yes".tr, Colors.red, Colors.white, onPressed),
          _buildDialogButton("cancel".tr, Colors.white, Colors.red, () async {
            Get.back();
          }),
        ],
      );
    },
  );
}

Widget _buildDialogButton(
  String text,
  Color bgColor,
  Color textColor,
  VoidCallback onPressed,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: Colors.red),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeLarge,
          color: textColor,
        ),
      ),
    ),
  );
}
