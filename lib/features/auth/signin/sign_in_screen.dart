import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controller/auth/login.controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/images.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginControllerImp>(
      builder: (loginController) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: loginController.formstate,
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
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "welcomeBack".tr,
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).hoverColor,
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Row(
                      children: [
                        Text(
                          "email".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
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
                      controller: loginController.email,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          "password".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        Text(
                          "*",
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Colors.red,
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
                      controller: loginController.password,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: loginController.checkBox,
                              side: BorderSide(
                                color: Theme.of(context).hintColor,
                              ),
                              onChanged: (value) {
                                loginController.checkBox = value!;
                                loginController.update();
                              },
                            ),
                            Text(
                              "Remember me".tr,
                              style: TextStyle(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              loginController.goToForgetPassword();
                            },
                            child: Text(
                              "forgetPassword".tr,
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      buttonText: "logIn".tr,
                      fontSize: 20.sp,
                      color:
                          !ThemeServices().loadThemeFromBox()
                              ? Theme.of(context).hoverColor
                              : Theme.of(context).primaryColor,
                      radius: 11.r,
                      textColor: Theme.of(context).scaffoldBackgroundColor,
                      onPressed: () {
                        loginController.login();
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account".tr,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraLarge,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                          ),
                          onPressed: () {
                            loginController.goToSignUp();
                          },
                          child: Text(
                            "subscription".tr,
                            style: robotoRegular.copyWith(
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
