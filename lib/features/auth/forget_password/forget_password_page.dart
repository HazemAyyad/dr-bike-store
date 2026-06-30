import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../reset password/change_password_screen.dart';
import 'done_screen.dart';
import 'otp_page.dart';
import 'send_otp_screen.dart';

class ForgetPasswordPage extends StatelessWidget {
  final TextEditingController email;
  const ForgetPasswordPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    List tabs = [
      OtpPage(email: email),
      const SendOtpScreen(),
      ResetPasswordScreen(),
      const DoneScreen(),
    ];
    return GetBuilder<ForgetPasswordControllerImp>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          body: Center(
            child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              itemCount: tabs.length,
              itemBuilder: (context, i) => tabs[i],
            ),
          ),
        );
      },
    );
  }
}
