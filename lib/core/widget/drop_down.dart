// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DefaultDropdown extends StatelessWidget {
  Object? value;
  Function(Object?)? onChanged;
  List<DropdownMenuItem<Object>>? items;
  double? radius;
  double? fontSize;
  double? height;
  double? iconSize;
  double? width;
  Color colorBorder;
  Color? color;
  Color? fillColor;
  TextStyle? labelStyle;
  String? labelText;
  Widget? icon;

  DefaultDropdown({
    super.key,
    this.onChanged,
    this.items,
    required this.labelText,
    this.labelStyle,
    this.radius,
    this.height,
    this.fontSize,
    this.iconSize,
    this.width,
    required this.colorBorder,
    this.color,
    this.fillColor,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      icon: Transform.rotate(
        angle: 7.82,
        child: const Icon(Icons.arrow_back_ios, size: 17),
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 2,
        vertical: 1,
      ),

      iconSize: iconSize ?? 20,
      // menuWidth: 120.w,
      validator: (value) {
        if (value == null || value == '') {
          return "addressRequired".tr;
        }
        return null;
      },
      borderRadius: BorderRadius.circular(10.r),
      style: TextStyle(
        fontSize: 14.sp,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xffD4D4D4), width: 1.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xffD4D4D4), width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xffD4D4D4), width: 1.w),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: const Color(0xffD4D4D4), width: 1.w),
        ),
      ),
      isExpanded: true,
      hint: Center(
        child: Text(
          labelText.toString(),
          style: TextStyle(
            fontSize: fontSize ?? 12,
            color: Colors.black87,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      value: value,

      items: items,
      onChanged: onChanged,
    );
  }
}
