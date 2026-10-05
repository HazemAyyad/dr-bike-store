import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';

enum StoreButtonVariant { primary, secondary, text, destructive }

class StoreButton extends StatelessWidget {
  const StoreButton({
    required this.label,
    required this.onPressed,
    this.variant = StoreButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final StoreButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    final foreground = switch (variant) {
      StoreButtonVariant.primary => Colors.white,
      StoreButtonVariant.secondary => StorePalette.purple,
      StoreButtonVariant.text => StorePalette.purple,
      StoreButtonVariant.destructive => Colors.white,
    };
    final background = switch (variant) {
      StoreButtonVariant.primary => StorePalette.purple,
      StoreButtonVariant.secondary => StorePalette.surface,
      StoreButtonVariant.text => Colors.transparent,
      StoreButtonVariant.destructive => StorePalette.error,
    };
    final borderColor = switch (variant) {
      StoreButtonVariant.secondary => StorePalette.purple,
      _ => Colors.transparent,
    };

    final content = AnimatedSwitcher(
      duration: StoreMotion.fast,
      child:
          isLoading
              ? SizedBox.square(
                key: const ValueKey('loading'),
                dimension: StoreIconSizes.medium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
              : Row(
                key: const ValueKey('label'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: StoreIconSizes.medium),
                    const SizedBox(width: StoreSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
    );

    final button = SizedBox(
      height: StoreCalibration.controlHeight,
      width: expand ? double.infinity : null,
      child: TextButton(
        onPressed: callback,
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          backgroundColor: background,
          disabledForegroundColor: StorePalette.textDisabled,
          disabledBackgroundColor: StorePalette.border,
          padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.md),
          textStyle: StoreTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoreRadii.md),
            side: BorderSide(
              color: borderColor,
              width: StoreCalibration.outlineWidth,
            ),
          ),
        ),
        child: content,
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: callback != null,
      value: isLoading ? 'storeLoading'.tr : null,
      excludeSemantics: true,
      child: button,
    );
  }
}

class StoreIconButton extends StatelessWidget {
  const StoreIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.badgeCount,
    this.foregroundColor,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final int? badgeCount;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final count = badgeCount?.clamp(0, 99);
    return Semantics(
      button: true,
      label: semanticLabel,
      value: count == null || count == 0 ? null : '$count',
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: onPressed,
            tooltip: semanticLabel,
            icon: Icon(icon, color: foregroundColor),
          ),
          if (count != null && count > 0)
            PositionedDirectional(
              top: 2,
              end: 2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(
                  color: StorePalette.error,
                  borderRadius: BorderRadius.all(
                    Radius.circular(StoreRadii.round),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  count == 99 && badgeCount! > 99 ? '99+' : '$count',
                  style: StoreTypography.caption.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: StoreTypography.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
