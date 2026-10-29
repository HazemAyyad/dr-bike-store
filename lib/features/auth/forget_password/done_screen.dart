import 'package:doctor_bike/core/theme/store_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth/forgetpassword.controller.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../widget/store_auth_scaffold.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordControllerImp>(
      autoRemove: false,
      builder:
          (controller) => StoreAuthScaffold(
            title: 'storeRecoveryCompleteTitle'.tr,
            subtitle: 'storeRecoveryCompleteMessage'.tr,
            child: Column(
              children: [
                Container(
                  width: StoreCalibration.authStateIconExtent,
                  height: StoreCalibration.authStateIconExtent,
                  decoration: BoxDecoration(
                    color: StoreColors.resolve(
                      context,
                      StorePalette.derivedSuccessSurface,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: StorePalette.success,
                    size: StoreCalibration.authSuccessIconSize,
                  ),
                ),
                const SizedBox(height: StoreSpacing.md),
                Text(
                  'storeRecoverySuccessHint'.tr,
                  textAlign: TextAlign.center,
                  style: StoreColors.text(
                    context,
                    StoreTypography.body,
                  ).copyWith(
                    color: StoreColors.resolve(
                      context,
                      StorePalette.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: StoreSpacing.lg),
                StoreAuthPrimaryButton(
                  label: 'storeBackToLogin'.tr,
                  onPressed: controller.goToLogin,
                ),
              ],
            ),
          ),
    );
  }
}
