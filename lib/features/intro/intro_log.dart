import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/helper/route_helper.dart';

class IntroLog extends StatefulWidget {
  const IntroLog({super.key});

  @override
  State<IntroLog> createState() => _IntroLogState();
}

class _IntroLogState extends State<IntroLog> {
  int selectedCondition = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              // height: 20,
              width: double.infinity,
            ),
            Image.asset(
              Images.onBoarding1,
              height: 280.h,
              filterQuality: FilterQuality.high,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                "intro2".tr,
                style: TextStyle(
                  fontSize: 27.sp,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).hoverColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              children: [
                buildConditionButton(
                  text: "createAccount".tr,
                  page: RouteHelper.signUp,
                  index: 0,
                  context: context,
                ),
                buildConditionButton(
                  text: "logIn".tr,
                  page: RouteHelper.signIn,
                  index: 1,
                  context: context,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConditionButton({
    required String text,
    required String page,
    required int index,
    required BuildContext context,
  }) {
    bool isSelected = selectedCondition == index;
    return GestureDetector(
      onTap: () {
        selectedCondition = index;

        Get.offNamed(page);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
        height: 45.h,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).primaryColor,
            width: 1.5.w,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.fontSizeExtraLarge,
              color:
                  isSelected
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
