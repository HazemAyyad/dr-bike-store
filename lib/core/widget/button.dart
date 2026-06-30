// ignore_for_file: file_names, non_constant_identifier_names, must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultButtom extends StatelessWidget {
  void Function()? OnTap;
  Widget Child;
  double Height;
  double Width;
  double? radius;
  double PaddingHorizontal;
  double PaddingVertical;
  double? PaddingVerticalText;
  Color? color;
  Color? colorBorder;
  Color? colorShadow;
  AlignmentGeometry? alignment;

  DefaultButtom({
    super.key,
    this.OnTap,
    required this.Child,
    required this.Height,
    required this.Width,
    this.radius,
    required this.PaddingHorizontal,
    required this.PaddingVertical,
    this.PaddingVerticalText,
    this.color,
    this.colorBorder,
    this.colorShadow,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: PaddingVertical.h, horizontal: PaddingHorizontal.w),
      child: Container(
        height: Height.h,
        width: Width.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 30).r),
            boxShadow: [
              /*  BoxShadow(
              offset: const Offset(0, 0),
              blurRadius: 15,
              spreadRadius: -5,*/

              BoxShadow(
                color: colorShadow ?? Colors.grey.withOpacity(0.4),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 1), // changes position of shadow
              ),
            ],
            border: Border.all(color: colorBorder ?? Colors.black)),
        child: ElevatedButton(
          onPressed: OnTap,
          style: ElevatedButton.styleFrom(
            shadowColor: colorShadow ?? Colors.black,
            backgroundColor: color ?? Theme.of(context).primaryColor,
            padding: EdgeInsets.all(PaddingVerticalText ?? 5).h,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 30).r),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(0),
            alignment: alignment ?? Alignment.center,
            width: Width.w,
            height: Height.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(radius ?? 30).r),
            ),
            child: Child,
          ),
        ),
      ),
    );
  }
}
