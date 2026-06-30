// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultDropdown extends StatelessWidget {
  Object? value;
  Function(Object?)? onChanged;
  List<DropdownMenuItem<Object>>? items;
  String? Function(Object?)? validator;
  double? radius;
  double? height;
  double? width;
  Color? colorBorder;
  Color? color;
  TextStyle? labelStyle;

  DefaultDropdown({
    super.key,
    this.onChanged,
    this.items,
    this.labelStyle,
    this.validator,
    this.radius,
    this.height,
    this.width,
    this.colorBorder,
    this.color,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      icon: Transform.rotate(
        angle: 7.82,
        child: const Icon(Icons.arrow_back_ios, size: 17),
      ),
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
      value: value,
      borderRadius: BorderRadius.circular(10.r),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
