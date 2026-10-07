import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../widget/store_auth_scaffold.dart';

class SendOtpScreen extends StatelessWidget {
  const SendOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      builder:
          (controller) => StoreAuthScaffold(
            title: 'storeOtpTitle'.tr,
            subtitle: 'storeOtpDestination'.trParams({
              'destination': controller.maskedDestination,
            }),
            showBack: true,
            onBack: controller.back,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthStatusBanner(
                  status: controller.status,
                  messageKey: controller.messageKey,
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldWidth = ((constraints.maxWidth - 40) / 6).clamp(
                      40.0,
                      StoreCalibration.otpCellExtent,
                    );
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Semantics(
                        textField: true,
                        label: 'storeOtpSemantic'.tr,
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          textStyle: StoreTypography.title,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(StoreRadii.md),
                            fieldHeight: StoreCalibration.otpCellExtent,
                            fieldWidth: fieldWidth,
                            activeColor: StorePalette.purple,
                            selectedColor: StorePalette.purple,
                            inactiveColor: StorePalette.border,
                            errorBorderColor: StorePalette.error,
                            activeFillColor: StorePalette.surface,
                            selectedFillColor: StorePalette.surface,
                            inactiveFillColor: StorePalette.surface,
                          ),
                          enableActiveFill: true,
                          animationDuration: StoreMotion.standard,
                          onChanged: (_) {},
                          onCompleted: (_) => controller.checkOTP(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: StoreSpacing.md),
                StoreAuthPrimaryButton(
                  label: 'storeVerifyCode'.tr,
                  onPressed: controller.checkOTP,
                  isLoading: controller.isSubmitting,
                ),
                const SizedBox(height: StoreSpacing.sm),
                TextButton(
                  onPressed:
                      controller.canResend && !controller.isSubmitting
                          ? controller.resendOTP
                          : null,
                  child: Text(
                    controller.canResend
                        ? 'storeResendCode'.tr
                        : 'storeResendCountdown'.trParams({
                          'seconds': controller.countdown.toString().padLeft(
                            2,
                            '0',
                          ),
                        }),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
