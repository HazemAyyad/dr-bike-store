import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';

enum StoreStatusTone { neutral, info, success, warning, error }

class StoreStatusChip extends StatelessWidget {
  const StoreStatusChip({
    required this.label,
    this.tone = StoreStatusTone.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final StoreStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StoreStatusTone.neutral => (
        StorePalette.textSecondary,
        StorePalette.background,
      ),
      StoreStatusTone.info => (
        StorePalette.info,
        StorePalette.derivedInfoSurface,
      ),
      StoreStatusTone.success => (
        StorePalette.success,
        StorePalette.derivedSuccessSurface,
      ),
      StoreStatusTone.warning => (
        StorePalette.warning,
        StorePalette.derivedWarningSurface,
      ),
      StoreStatusTone.error => (
        StorePalette.error,
        StorePalette.derivedErrorSurface,
      ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: StoreSpacing.xs,
          vertical: StoreSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(StoreRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: StoreIconSizes.small, color: foreground),
              const SizedBox(width: StoreSpacing.xxs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StoreTypography.caption.copyWith(
                  color: foreground,
                  fontWeight: StoreTypography.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreAvailabilityChip extends StatelessWidget {
  const StoreAvailabilityChip({required this.inStock, super.key});

  final bool inStock;

  @override
  Widget build(BuildContext context) => StoreStatusChip(
    label: inStock ? 'storeAvailable'.tr : 'storeUnavailable'.tr,
    tone: inStock ? StoreStatusTone.success : StoreStatusTone.error,
  );
}

class StoreDiscountChip extends StatelessWidget {
  const StoreDiscountChip({required this.percent, super.key});

  final num percent;

  @override
  Widget build(BuildContext context) => StoreStatusChip(
    label: '-${percent.clamp(0, 100)}%',
    tone: StoreStatusTone.error,
  );
}

class StoreRating extends StatelessWidget {
  const StoreRating({required this.value, this.count, super.key});

  final double value;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0, 5).toStringAsFixed(1);
    final semanticsLabel =
        count == null
            ? 'storeRating'.trParams({'value': safeValue})
            : 'storeRatingWithReviews'.trParams({
              'value': safeValue,
              'count': '$count',
            });
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: StoreIconSizes.small,
            color: StorePalette.warning,
          ),
          const SizedBox(width: StoreSpacing.xxs),
          Text(safeValue, style: StoreTypography.caption),
          if (count != null) Text(' ($count)', style: StoreTypography.caption),
        ],
      ),
    );
  }
}

class StoreFilterChip extends StatelessWidget {
  const StoreFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final int? count;

  @override
  Widget build(BuildContext context) => FilterChip(
    selected: selected,
    onSelected: onSelected,
    label: Text(count == null ? label : '$label ($count)'),
    labelStyle: StoreTypography.label.copyWith(
      color: selected ? StorePalette.navy : StorePalette.textPrimary,
    ),
    backgroundColor: StorePalette.surface,
    selectedColor: StorePalette.lightPurple,
    checkmarkColor: StorePalette.purple,
    side: BorderSide(
      color: selected ? StorePalette.purple : StorePalette.border,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(StoreRadii.pill),
    ),
  );
}
