import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/helper/route_helper.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';

enum StoreUpdateRequirement { required, recommended }

class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({
    required this.requirement,
    this.authoritativeMessage,
    this.updateUri,
    this.onRetry,
    this.onContinue,
    super.key,
  });

  final StoreUpdateRequirement requirement;
  final String? authoritativeMessage;
  final Uri? updateUri;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  factory UpdateRequiredScreen.fromArguments(dynamic arguments) {
    final values = arguments is Map ? arguments : const <Object?, Object?>{};
    final isRequired = values['required'] != false;
    final uriText = values['updateUri']?.toString();
    final uri = uriText == null ? null : Uri.tryParse(uriText);
    return UpdateRequiredScreen(
      requirement:
          isRequired
              ? StoreUpdateRequirement.required
              : StoreUpdateRequirement.recommended,
      authoritativeMessage: values['message']?.toString(),
      updateUri: uri?.hasScheme == true ? uri : null,
      onRetry: () => Get.offAllNamed(RouteHelper.initial),
      onContinue:
          isRequired ? null : () => Get.offAllNamed(RouteHelper.homePage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final required = requirement == StoreUpdateRequirement.required;
    return Scaffold(
      backgroundColor: StorePalette.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(StoreSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: StoreCalibration.authContentMaxWidth,
              ),
              child: Column(
                children: [
                  Container(
                    width: StoreCalibration.authStateIconExtent,
                    height: StoreCalibration.authStateIconExtent,
                    decoration: const BoxDecoration(
                      color: StorePalette.lightPurple,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt,
                      size: StoreCalibration.updateIconSize,
                      color: StorePalette.purple,
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  Text(
                    required
                        ? 'storeUpdateRequiredTitle'.tr
                        : 'storeUpdateRecommendedTitle'.tr,
                    textAlign: TextAlign.center,
                    style: StoreTypography.headline,
                  ),
                  const SizedBox(height: StoreSpacing.xs),
                  Text(
                    authoritativeMessage?.trim().isNotEmpty == true
                        ? authoritativeMessage!.trim()
                        : required
                        ? 'storeUpdateRequiredMessage'.tr
                        : 'storeUpdateRecommendedMessage'.tr,
                    textAlign: TextAlign.center,
                    style: StoreTypography.body.copyWith(
                      color: StorePalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: StoreSpacing.lg),
                  if (updateUri != null)
                    StoreButton(
                      label: 'storeUpdateAction'.tr,
                      icon: Icons.open_in_new,
                      onPressed:
                          () => launchUrl(
                            updateUri!,
                            mode: LaunchMode.externalApplication,
                          ),
                    ),
                  if (updateUri == null && onRetry != null)
                    StoreButton(
                      label: 'storeRetry'.tr,
                      onPressed: onRetry,
                      variant: StoreButtonVariant.secondary,
                    ),
                  if (!required && onContinue != null) ...[
                    const SizedBox(height: StoreSpacing.sm),
                    StoreButton(
                      label: 'storeContinue'.tr,
                      onPressed: onContinue,
                      variant: StoreButtonVariant.text,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
