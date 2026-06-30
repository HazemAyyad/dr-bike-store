import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';

class SendOtpScreen extends StatelessWidget {
  const SendOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      builder: (controller) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    "Verify OTP".tr,
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      color: Theme.of(context).hoverColor,
                      fontSize: Dimensions.fontSizeOverLarge,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  SizedBox(
                    width: 270.w,
                    child: Text(
                      "Please enter the verification code".tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        color: const Color(0xff091133),
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),

                  // OTP Input Fields
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: PinCodeTextField(
                      appContext: context,
                      textStyle: TextStyle(color: Theme.of(context).hintColor),
                      length: 4,
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeLarge,
                        ),
                        fieldHeight: 60.h,
                        fieldWidth: 60.w,
                        activeColor: Colors.blue,
                        selectedColor:
                            !ThemeServices().loadThemeFromBox()
                                ? Theme.of(context).hoverColor
                                : Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey,
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                      onChanged: (value) {},
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.checkOTP();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ThemeServices().loadThemeFromBox()
                                ? Theme.of(context).hoverColor
                                : Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radiusDefault,
                          ),
                        ),
                      ),
                      child: Text(
                        "verification".tr,
                        style: robotoBold.copyWith(
                          fontSize: 20.sp,
                          color:
                              !ThemeServices().loadThemeFromBox()
                                  ? Colors.white
                                  : Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Resend OTP Section
                  Text(
                    "verification code".tr,
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        controller.canResend ? controller.resendOTP : null,
                    child: Text(
                      controller.canResend
                          ? "Resend".tr
                          : "${"Resend during".tr} 00:${controller.countdown.toString().padLeft(2, '0')}",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color:
                            controller.canResend
                                ? Colors.blue
                                : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
