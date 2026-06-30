import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:overlay_kit/overlay_kit.dart';
import 'package:intl/intl.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/otp_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/auth/auth_repository.dart';

abstract class ForgetPasswordController extends GetxController {
  checkEmail();
  next();
  back();
  goToLogin();
  resetpassword();
}

class ForgetPasswordControllerImp extends ForgetPasswordController {
  ForgetPasswordControllerImp({required this.authRepository});

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  GlobalKey<FormState> formstate2 = GlobalKey<FormState>();
  GlobalKey<FormState> formstate3 = GlobalKey<FormState>();

  late TextEditingController password;
  late TextEditingController repassword;
  late PageController pageController;
  late TextEditingController email;
  final AuthRepository authRepository;
  bool change = false;
  int currentPage = 0;
  late StatusRequest statusRequest;
  OtpModel? otpAuth;
  TextEditingController otpController = TextEditingController();
  int countdown = 50;
  late Timer timer;
  bool canResend = false;

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      if (countdown > 0) {
        countdown--;
        update();
      } else {
        canResend = true;
        t.cancel();
        update();
      }
    });
  }

  resendOTP() async {
    OverlayLoadingProgress.start();
    if (await CheckInternet.checkInternet()) {
      try {
        var response = await authRepository.forgotPassword(email: email.text);
        if (response.statusCode == 200) {
          otpAuth = OtpModel.fromJson(response.body);
          AppUsageService.saveUserId(otpAuth!.userId);
          AppUsageService.saveUserEmail(otpAuth!.email);

          countdown = 50;
          canResend = false;
          startTimer();
        }
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    update();
  }

  @override
  resetpassword() async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    OverlayLoadingProgress.start();
    if (await CheckInternet.checkInternet()) {
      try {
        var response = await authRepository.resetPassword(
          userId: otpAuth!.userId,
          confirmPassword: repassword.text,
          newPassword: password.text,
          dateUpdate: formattedDate,
        );

        if (response.statusCode == 200) {
          next();
        }
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  goToLogin() {
    Get.offAllNamed(RouteHelper.signIn);
  }

  @override
  checkEmail() async {
    OverlayLoadingProgress.start();
    if (await CheckInternet.checkInternet()) {
      try {
        var formdata = formstate2.currentState;
        if (formdata == null || !formdata.validate()) {
          showCustomSnackBar(
            'Please fill in all required fields'.tr,
            isError: true,
          );
          return;
        }

        statusRequest = StatusRequest.loading;

        var response = await authRepository.forgotPassword(email: email.text);
        if (response.statusCode == 200) {
          otpAuth = OtpModel.fromJson(response.body);
          AppUsageService.saveUserId(otpAuth!.userId);
          AppUsageService.saveUserEmail(otpAuth!.email);

          if (currentPage == 0) {
            next();
            startTimer();
          }
        } else {
          showCustomSnackBar('ThisEmailNotFound.'.tr, isError: true);
        }
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  checkOTP() {
    OverlayLoadingProgress.start();
    if (otpAuth?.otp.toString() == otpController.text) {
      next();
      OverlayLoadingProgress.stop();
    } else {
      showCustomSnackBar(
        "The verification code is incorrect, please try again.".tr,
        isError: true,
      );
      OverlayLoadingProgress.stop();
    }
  }

  @override
  back() {
    if (currentPage > 0) {
      currentPage--;
    }

    pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
    update();
  }

  @override
  next() async {
    if (currentPage < 3) {
      currentPage++;
    }

    pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 10),
      curve: Curves.easeInOut,
    );
    update();
  }

  isLog() {
    AppUsageService.saveIsLogin(true);
  }

  @override
  void onInit() {
    pageController = PageController();
    email = TextEditingController();

    otpController = TextEditingController();
    password = TextEditingController();
    repassword = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    timer.cancel();
    password.dispose();
    repassword.dispose();
    otpController.dispose();
    super.dispose();
  }
}
