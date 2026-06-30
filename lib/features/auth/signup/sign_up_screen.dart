import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/auth/signupController.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_text_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpControllerImp>(
      builder: (signUpController) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: signUpController.formstate,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(width: double.infinity, height: 70.h),
                    Image.asset(
                      ThemeServices().loadThemeFromBox()
                          ? Images.logoDark
                          : Images.logo,
                      width: 150.w,
                      height: 100.h,
                      fit: BoxFit.fitWidth,
                      filterQuality: FilterQuality.high,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "welcome".tr,
                      textAlign: TextAlign.center,
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hoverColor,
                        fontSize: Dimensions.fontSizeOverLarge,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Row(
                      children: [
                        Text(
                          "email".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: "email".tr,
                      borderRadius: 11.r,
                      inputType: TextInputType.emailAddress,
                      controller: signUpController.EmailController,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "phoneNumber".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: "phoneNumber".tr,
                      borderRadius: 11.r,
                      inputType: TextInputType.phone,
                      controller: signUpController.PhoneController,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "password".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: "password".tr,
                      borderRadius: 11.r,
                      isPassword: true,
                      controller: signUpController.PasswordController,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "ConfirmPassword".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: "ConfirmPassword".tr,
                      borderRadius: 11.r,
                      isPassword: true,
                      controller: signUpController.ConfirmPassword,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      fontSize: 20.sp,
                      buttonText: "SubscribeNow".tr,
                      color:
                          !ThemeServices().loadThemeFromBox()
                              ? Theme.of(context).hoverColor
                              : Theme.of(context).primaryColor,
                      radius: 11.r,
                      textColor: Theme.of(context).scaffoldBackgroundColor,
                      onPressed: () {
                        signUpController.signUp();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account".tr,
                          style: robotoRegular.copyWith(
                            color: const Color(0xff4b4b4b),
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            signUpController.goToSignIn();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          child: Text(
                            "logIn".tr,
                            style: robotoRegular.copyWith(
                              color: const Color(0xff6b65bd),
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
