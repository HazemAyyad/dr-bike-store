import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/helper/route_helper.dart';
import '../../../core/widget/custom_button.dart';

class PromoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String buttonText;

  const PromoCard({super.key, 
    required this.imageUrl,
    required this.title,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  buttonText: buttonText,
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.sp,
                  width: 70.w,
                  isBold: false,
                  height: 35.h,
                  radius: 15.r,
                  onPressed: () {
                    Get.offAndToNamed(RouteHelper.homePage);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Image.asset(
              imageUrl,
              fit: BoxFit.fill,
              width: 80.w,
              height: 50.h,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}
