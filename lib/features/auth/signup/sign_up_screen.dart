import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/signupController.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_buttons.dart';
import '../../../core/widget/store_fields.dart';
import '../widget/store_auth_scaffold.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpControllerImp>(
      builder:
          (controller) => Scaffold(
            backgroundColor: StorePalette.background,
            body: StoreAuthScaffold(
              title: 'storeRegisterTitle'.tr,
              subtitle: 'storeRegisterSubtitle'.tr,
              showBack: true,
              onBack: controller.goToSignIn,
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'storeAlreadyAccount'.tr,
                      style: StoreTypography.body.copyWith(
                        color: StorePalette.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goToSignIn,
                    child: Text('storeLoginAction'.tr),
                  ),
                ],
              ),
              child: Form(
                key: controller.formstate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthStatusBanner(
                      status: controller.status,
                      messageKey: controller.messageKey,
                    ),
                    StoreTextField(
                      controller: controller.EmailController,
                      label: 'storeEmail'.tr,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.mail_outline,
                    ),
                    const SizedBox(height: StoreSpacing.md),
                    StoreTextField(
                      controller: controller.PhoneController,
                      label: 'storePhone'.tr,
                      hint: 'storePhoneHint'.tr,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: StoreSpacing.md),
                    StoreTextField(
                      controller: controller.PasswordController,
                      label: 'storePassword'.tr,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                      helperText: 'storePasswordRequirement'.tr,
                    ),
                    const SizedBox(height: StoreSpacing.md),
                    StoreTextField(
                      controller: controller.ConfirmPassword,
                      label: 'storeConfirmPassword'.tr,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_reset_outlined,
                      onSubmitted: (_) => controller.signUp(),
                    ),
                    const SizedBox(height: StoreSpacing.lg),
                    StoreButton(
                      label: 'storeCreateAccountAction'.tr,
                      onPressed: controller.signUp,
                      isLoading: controller.isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
