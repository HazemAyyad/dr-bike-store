// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../core/functions/app_usage_service.dart';
import '../../core/constants/images.dart';
import '../../core/helper/route_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          _navigatetohome();
          break;
        case InternetStatus.disconnected:
          break;
      }
    });
    super.initState();
  }

  _navigatetohome() async {
    bool? first = await AppUsageService.getIsFirst();

    if (first == true) {
      await Future.delayed(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.homePage);
      });
    } else {
      await Future.delayed(const Duration(seconds: 3), () {
        Get.offNamed(RouteHelper.lang);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          Images.splash,
          width: 220.w,
          height: 220.h,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
