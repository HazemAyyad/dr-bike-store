// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../core/functions/app_usage_service.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/images.dart';
import '../../core/constants/styles.dart';
import '../../core/helper/route_helper.dart';
import '../../core/widget/button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;

  List<Map<String, String>> onboardingData = [
    {
      "image": Images.onBoarding1,
      "title": "${"intro".tr} ${"nameApp".tr}",
      "description": "bodySplash1".tr,
    },
    {
      "image": Images.onBoarding2,
      "title": "titleSplash2".tr,
      "description": "bodySplash2".tr,
    },
    {
      "image": Images.onBoarding3,
      "title": "titleSplash3".tr,
      "description": "bodySplash3".tr,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Dimensions.paddingSizeDefault.w,
        ),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.only(top: 45.h),
                child: DefaultButtom(
                  color: const Color(0xffeeeeee),
                  Child: Text(
                    "skip".tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                  colorShadow: Colors.transparent,
                  colorBorder: Colors.white,
                  radius: Dimensions.radiusExtraLarge,
                  Height: 30.h,
                  Width: 65.w,
                  PaddingHorizontal: 0,
                  PaddingVertical: 0,
                  OnTap: () {
                    // await CacheHelper.savedata(
                    //     key: AppConstants.FirstLog, value: true);
                    AppUsageService.isFirstTime();
                    AppUsageService.saveIsFirst(true);
                    Get.offAndToNamed(RouteHelper.homePage);
                  },
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  _currentPage.value = index;
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    image: onboardingData[index]["image"]!,
                    title: onboardingData[index]["title"]!,
                    description: onboardingData[index]["description"]!,
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => buildDot(index),
              ),
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Obx(
                    () => CircularPercentIndicator(
                      animation: true,
                      radius: 30.w,
                      animateFromLastPercent: true,
                      lineWidth: 4,
                      animationDuration: 300,
                      percent:
                          _currentPage.value == 0
                              ? 0.33
                              : _currentPage.value == 1
                              ? 0.66
                              : 1,
                      progressColor: Theme.of(context).primaryColor,
                      backgroundColor: const Color.fromARGB(255, 206, 205, 205),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                  InkWell(
                    radius: 20.r,
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linear,
                      );
                      if (_currentPage.value == onboardingData.length - 1) {
                        // await CacheHelper.savedata(
                        //     key: AppConstants.FirstLog, value: true);
                        AppUsageService.isFirstTime();
                        AppUsageService.saveIsFirst(true);
                        Get.offAndToNamed(RouteHelper.homePage);
                      }
                    },
                    child: Container(
                      height: 40.h,
                      width: 45.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeExtremeLarge.r,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: const Icon(Icons.arrow_forward_ios, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return Obx(
      () => AnimatedContainer(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        width: _currentPage.value == index ? 34.w : 8,
        height: 8.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          color:
              _currentPage.value == index
                  ? Theme.of(context).primaryColor
                  : const Color(0xffa9a9a9),
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image, title, description;
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              image,
              height: 300.h,
              filterQuality: FilterQuality.high,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).hoverColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeExtraLarge,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
