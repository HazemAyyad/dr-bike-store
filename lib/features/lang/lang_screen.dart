import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/LocalizationController.dart';
import '../../core/constants/dimensions.dart';

class LangScreen extends StatelessWidget {
  const LangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          body: GetBuilder<LocalizationController>(
            builder: (localizationController) {
              return Center(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select your language'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: Dimensions.fontSizeOverLarge,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      localizationController.buildConditionButton(
                        text: 'english language',
                        index: 1,
                        context: context,
                      ),
                      localizationController.buildConditionButton(
                        text: 'اللغة العربية',
                        index: 0,
                        context: context,
                      ),
                      localizationController.buildConditionButton(
                        text: 'שפה עברית',
                        index: 2,
                        context: context,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
