import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../reset password/change_password_screen.dart';
import 'done_screen.dart';
import 'otp_page.dart';
import 'send_otp_screen.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({this.initialIdentifier, super.key});

  final String? initialIdentifier;

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<ForgetPasswordControllerImp>();
    final identifier = widget.initialIdentifier?.trim();
    if (controller.email.text.isEmpty &&
        identifier != null &&
        identifier.isNotEmpty) {
      controller.email.text = identifier;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      autoRemove: false,
      builder:
          (controller) => Scaffold(
            backgroundColor: StorePalette.background,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              children: const [
                OtpPage(),
                SendOtpScreen(),
                ResetPasswordScreen(),
                DoneScreen(),
              ],
            ),
          ),
    );
  }
}
