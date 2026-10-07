import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/images.dart';
import '../../../core/theme/store_tokens.dart';
import '../../../core/theme/store_typography.dart';
import '../../../core/widget/store_navigation_icons.dart';
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
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final compact = viewportHeight < 720;
    return SafeArea(
      child: LayoutBuilder(
        builder:
            (context, constraints) => Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      StoreSpacing.lg,
                      compact ? StoreSpacing.xxs : StoreSpacing.sm,
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
                              Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      Images.logo,
                                      width: compact ? 104 : 126,
                                      height: compact ? 72 : 88,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                    Text(
                                      'storeBrandName'.tr,
                                      textDirection: TextDirection.ltr,
                                      style: StoreTypography.title.copyWith(
                                        color: StorePalette.navy,
                                        fontSize: compact ? 17 : 20,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: compact ? StoreSpacing.md : 30),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: StoreTypography.headline.copyWith(
                                  color: StorePalette.navy,
                                  fontSize: compact ? 24 : 28,
                                  height: 1.3,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: StoreSpacing.xxs),
                                Text(
                                  subtitle!,
                                  textAlign: TextAlign.center,
                                  style: StoreTypography.body.copyWith(
                                    color: StorePalette.textSecondary,
                                    fontSize: compact ? 14 : 16,
                                  ),
                                ),
                              ],
                              SizedBox(height: compact ? StoreSpacing.md : 28),
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
                if (showBack)
                  PositionedDirectional(
                    top: compact ? 0 : StoreSpacing.xxs,
                    start: StoreSpacing.sm,
                    child: IconButton(
                      key: const ValueKey('auth-back-button'),
                      onPressed: onBack ?? Get.back,
                      tooltip: 'storeBack'.tr,
                      icon: Icon(
                        storeBackIcon(context),
                        color: StorePalette.navy,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

class StoreAuthPrimaryButton extends StatelessWidget {
  const StoreAuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    return Semantics(
      button: true,
      label: label,
      enabled: callback != null,
      child: SizedBox(
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient:
                callback == null
                    ? null
                    : const LinearGradient(
                      colors: [Color(0xFF6257C8), Color(0xFF7468D7)],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    ),
            color: callback == null ? StorePalette.border : null,
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            boxShadow:
                callback == null
                    ? null
                    : const [
                      BoxShadow(
                        color: Color(0x246B65BD),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
          ),
          child: TextButton(
            onPressed: callback,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: StorePalette.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoreRadii.lg),
              ),
              textStyle: StoreTypography.title.copyWith(
                color: Colors.white,
                fontWeight: StoreTypography.semiBold,
              ),
            ),
            child:
                isLoading
                    ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label),
                        if (icon != null) ...[
                          const SizedBox(width: StoreSpacing.sm),
                          Icon(icon, size: 24),
                        ],
                      ],
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
