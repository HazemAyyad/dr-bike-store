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
                  decoration: const BoxDecoration(
                    color: StorePalette.derivedSuccessSurface,
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
                  style: StoreTypography.body.copyWith(
                    color: StorePalette.textSecondary,
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
