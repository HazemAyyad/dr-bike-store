import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/dimensions.dart';
import '../constants/styles.dart';

class BuildDialogButton extends StatelessWidget {
  const BuildDialogButton({
    super.key,
    required this.bgColor,
    required this.onPressed,
    required this.text,
    required this.textColor,
    this.horizontal,
    this.vertical,
    this.fontSize,
    this.borderRadius,
    this.borderSideColor,
  });
  final String text;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double? horizontal;
  final double? vertical;
  final double? fontSize;
  final double? borderRadius;
  final Color? borderSideColor;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ?? 35.w,
            vertical: vertical ?? 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
            side: BorderSide(color: borderSideColor ?? Colors.red),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: robotoBold.copyWith(
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
