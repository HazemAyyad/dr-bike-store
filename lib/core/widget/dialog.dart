// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultDialog extends StatelessWidget {
  Widget Child;
  double? paddingVerrtical;
  double? radius;
  double? paddingHorizontal;
  Color? backgroundColor;
  DefaultDialog({
    super.key,
    this.backgroundColor,
    required this.Child,
    this.paddingVerrtical,
    this.radius,
    this.paddingHorizontal,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Dialog(
          backgroundColor: backgroundColor ?? Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 25).r),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: (paddingVerrtical ?? 15).h,
                horizontal: paddingHorizontal ?? 10.w),
            child: Child,
          ),
        ));
  }
}
