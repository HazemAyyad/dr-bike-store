import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/login.controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_fields.dart';
import '../widget/store_auth_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginControllerImp>(
      builder:
          (controller) => Scaffold(
            backgroundColor: StorePalette.background,
            body: StoreAuthScaffold(
              title: 'storeLoginTitle'.tr,
              subtitle: 'storeLoginSubtitle'.tr,
              showBack: true,
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'storeNoAccount'.tr,
                      style: StoreTypography.body.copyWith(
                        color: StorePalette.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.goToSignUp,
                    child: Text('storeCreateAccountAction'.tr),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
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
                      semanticLabel: 'storeIdentifierLabel'.tr,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.mail_outline,
                      height: 56,
                      borderRadius: StoreRadii.lg,
                      validator:
                          (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'storeValidationRequired'.tr
                                  : null,
                    ),
                    const SizedBox(height: StoreSpacing.md),
                    StoreTextField(
                      controller: controller.password,
                      label: 'storePassword'.tr,
                      semanticLabel: 'storePassword'.tr,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      height: 56,
                      borderRadius: StoreRadii.lg,
                      onSubmitted:
                          (_) => controller.login(_formKey.currentState),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'storeValidationRequired'.tr
                                  : null,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: controller.checkBox,
                          activeColor: StorePalette.purple,
                          onChanged:
                              controller.isSubmitting
                                  ? null
                                  : (value) =>
                                      controller.setRemember(value ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'storeRememberMe'.tr,
                            style: StoreTypography.caption,
                          ),
                        ),
                        TextButton(
                          onPressed: controller.goToForgetPassword,
                          child: Text('storeForgotPassword'.tr),
                        ),
                      ],
                    ),
                    const SizedBox(height: StoreSpacing.sm),
                    StoreAuthPrimaryButton(
                      label: 'storeLoginAction'.tr,
                      onPressed: () => controller.login(_formKey.currentState),
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
