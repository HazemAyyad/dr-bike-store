import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/dimensions.dart';
import '../../core/constants/styles.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: const SizedBox(),
        centerTitle: true,
        title: Text(
          "who we are".tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge2,
            color: Theme.of(context).hoverColor,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 12.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "who1".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                "who2".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                "who3".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "who4".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "who5".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.w),
                child: Text(
                  "who6".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.w),
                child: Text(
                  "who7".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.w),
                child: Text(
                  "who8".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 15.w),
                child: Text(
                  "who9".tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    height: 2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "who1".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                "who10".tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  height: 2,
                  color: Theme.of(context).hintColor,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
