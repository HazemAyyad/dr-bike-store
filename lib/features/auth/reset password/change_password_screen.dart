import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/styles.dart';
import '../../../core/functions/theme_services.dart';
import '../../../core/widget/custom_text_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      builder: (forgetPasswordControllerImp) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'reset password'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge2,
                color: Theme.of(context).hoverColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: forgetPasswordControllerImp.formstate3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Please enter the data below.".tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 25.h),

                    Text(
                      "New Password".tr,
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: '********',
                      borderRadius: 15.r,
                      colorBorder: const Color(0xffD4D4D4),
                      isPassword: true,
                      controller: forgetPasswordControllerImp.password,
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "ConfirmPassword".tr,
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      hintText: '********',
                      borderRadius: 15.r,
                      colorBorder: const Color(0xffD4D4D4),
                      controller: forgetPasswordControllerImp.repassword,
                      isPassword: true,
                    ),
                    SizedBox(height: 25.h),
                    Text(
                      "*The password must be at least 8 numbers and 3 symbols."
                          .tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,

                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSaveButton(context, forgetPasswordControllerImp),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ForgetPasswordControllerImp forgetPasswordControllerImp,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          forgetPasswordControllerImp.resetpassword();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              !ThemeServices().loadThemeFromBox()
                  ? Theme.of(context).hoverColor
                  : Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          "save".tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
