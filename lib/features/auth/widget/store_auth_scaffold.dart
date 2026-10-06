import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/images.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../repository/auth/auth_repository.dart';

class StoreAuthScaffold extends StatelessWidget {
  const StoreAuthScaffold({
    required this.title,
    required this.child,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.footer,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder:
            (context, constraints) => SingleChildScrollView(
              padding: EdgeInsetsDirectional.fromSTEB(
                StoreSpacing.lg,
                StoreSpacing.sm,
                StoreSpacing.lg,
                StoreSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight -
                      StoreCalibration.authViewportInsetAdjustment,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: StoreCalibration.authContentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showBack)
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: IconButton(
                              onPressed: onBack ?? Get.back,
                              tooltip: 'storeBack'.tr,
                              icon: Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.arrow_forward_ios
                                    : Icons.arrow_back_ios,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: StoreSpacing.sm),
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                Images.logo,
                                width: StoreCalibration.authLogoWidth,
                                height: StoreCalibration.authLogoHeight,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                              Text(
                                'storeBrandName'.tr,
                                textDirection: TextDirection.ltr,
                                style: StoreTypography.title.copyWith(
                                  color: StorePalette.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: StoreSpacing.md),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: StoreTypography.headline,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: StoreSpacing.xxs),
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: StoreTypography.body.copyWith(
                              color: StorePalette.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: StoreSpacing.lg),
                        child,
                        if (footer != null) ...[
                          const SizedBox(height: StoreSpacing.md),
                          footer!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}

class AuthStatusBanner extends StatelessWidget {
  const AuthStatusBanner({
    required this.status,
    required this.messageKey,
    super.key,
  });

  final AuthUiStatus status;
  final String? messageKey;

  @override
  Widget build(BuildContext context) {
    if (messageKey == null ||
        status == AuthUiStatus.idle ||
        status == AuthUiStatus.submitting) {
      return const SizedBox.shrink();
    }
    final isSuccess = status == AuthUiStatus.success;
    final color = isSuccess ? StorePalette.success : StorePalette.error;
    final surface =
        isSuccess
            ? StorePalette.derivedSuccessSurface
            : StorePalette.derivedErrorSurface;
    return Semantics(
      liveRegion: true,
      label: messageKey!.tr,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: StoreSpacing.sm),
        padding: const EdgeInsets.all(StoreSpacing.sm),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(StoreRadii.sm),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: color,
            ),
            const SizedBox(width: StoreSpacing.xs),
            Expanded(
              child: Text(
                messageKey!.tr,
                style: StoreTypography.caption.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
