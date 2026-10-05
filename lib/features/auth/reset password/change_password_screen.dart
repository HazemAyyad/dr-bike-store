import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_fields.dart';
import '../widget/store_auth_scaffold.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      builder:
          (controller) => StoreAuthScaffold(
            title: 'storeNewPasswordTitle'.tr,
            subtitle: 'storeNewPasswordBody'.tr,
            showBack: true,
            onBack: controller.back,
            child: Form(
              key: controller.formstate3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthStatusBanner(
                    status: controller.status,
                    messageKey: controller.messageKey,
                  ),
                  StoreTextField(
                    controller: controller.password,
                    label: 'storeNewPassword'.tr,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_outline,
                    helperText: 'storePasswordRequirement'.tr,
                  ),
                  const SizedBox(height: StoreSpacing.md),
                  StoreTextField(
                    controller: controller.repassword,
                    label: 'storeConfirmPassword'.tr,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_reset_outlined,
                    onSubmitted: (_) => controller.resetpassword(),
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  StoreButton(
                    label: 'storeResetPasswordAction'.tr,
                    onPressed: controller.resetpassword,
                    isLoading: controller.isSubmitting,
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
