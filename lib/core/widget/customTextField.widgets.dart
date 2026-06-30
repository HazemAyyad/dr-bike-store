// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants/images.dart';

class CustomTextFieldChat extends StatelessWidget {
  final Function()? onPress;
  CustomTextFieldChat({super.key, this.onPress, required this.controller});
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      height: 40.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Row(
                children: [
                  TextField(
                    controller: controller,
                    onChanged: (data) {},
                    decoration: InputDecoration(
                      hintText: "Add an opinion".tr,
                      border: InputBorder.none,
                    ),
                  ).box.width(context.screenWidth / 1.7).height(40.h).make(),
                ],
              ),
            ],
          ).box.padding(EdgeInsets.symmetric(horizontal: 10)).rounded.make(),
          // 5.widthBox,
          InkWell(
            onTap: onPress,
            child: Column(
              children: [
                SvgPicture.asset(
                  Images.iconSend,
                  width: 25.w,
                  height: 25.h,
                ).box.rounded.padding(const EdgeInsets.all(8)).make(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
