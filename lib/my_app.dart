// ignore_for_file: deprecated_member_use

import 'package:doctor_bike/core/functions/theme_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controller/LocalizationController.dart';
import 'core/bindings/mybindings.dart';
import 'core/constants/app_constants.dart';
import 'core/helper/route_helper.dart';
import 'core/locale/locale.dart';
import 'core/theme/light.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GetBuilder<LocalizationController>(
        builder: (localizeController) {
          return OverlayKit(
            child: ScreenUtilInit(
              designSize: const Size(360, 690),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, child) {
                return GetMaterialApp(
                  title: AppConstants.appName,
                  theme: light(),
                  darkTheme: dark(),
                  themeMode: ThemeServices().theme,
                  initialBinding: Mybinding(),
                  locale: localizeController.locale,
                  translations: MyLocale(),
                  navigatorKey: Get.key,
                  initialRoute: RouteHelper.initial,
                  // initialRoute: RouteHelper.homePage,
                  fallbackLocale: Locale(
                    AppConstants.languages[0].languageCode!,
                    AppConstants.languages[0].countryCode,
                  ),
                  debugShowCheckedModeBanner: false,
                  getPages: RouteHelper.routes,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
