import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/constants/images.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/widget/store_fields.dart';
import '../widget/store_auth_scaffold.dart';

/// Recovery request step. The legacy file name is retained for route
/// compatibility; OTP entry is rendered by [SendOtpScreen].
class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      builder:
          (controller) => StoreAuthScaffold(
            title: 'storeRecoveryRequestTitle'.tr,
            subtitle: 'storeRecoveryRequestBody'.tr,
            showBack: true,
            onBack: controller.back,
            child: Form(
              key: controller.formstate2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthStatusBanner(
                    status: controller.status,
                    messageKey: controller.messageKey,
                  ),
                  StoreTextField(
                    controller: controller.email,
                    label: 'storeIdentifierLabel'.tr,
                    hint: 'storeIdentifierHint'.tr,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.mail_outline,
                    height: 56,
                    borderRadius: StoreRadii.lg,
                    onSubmitted: (_) => controller.checkEmail(),
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  StoreAuthPrimaryButton(
                    label: 'storeSendVerification'.tr,
                    onPressed: controller.checkEmail,
                    isLoading: controller.isSubmitting,
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  Semantics(
                    image: true,
                    label: 'storeRecoveryRequestTitle'.tr,
                    child: Image.asset(
                      Images.passwordRecoveryIllustration,
                      height: 250,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
