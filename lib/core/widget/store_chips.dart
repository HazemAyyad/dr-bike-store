import 'package:doctor_bike/core/theme/store_colors.dart';
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
        StoreColors.resolve(context, StorePalette.textSecondary),
        StoreColors.resolve(context, StorePalette.background),
      ),
      StoreStatusTone.info => (
        StorePalette.info,
        StoreColors.resolve(context, StorePalette.derivedInfoSurface),
      ),
      StoreStatusTone.success => (
        StorePalette.success,
        StoreColors.resolve(context, StorePalette.derivedSuccessSurface),
      ),
      StoreStatusTone.warning => (
        StorePalette.warning,
        StoreColors.resolve(context, StorePalette.derivedWarningSurface),
      ),
      StoreStatusTone.error => (
        StorePalette.error,
        StoreColors.resolve(context, StorePalette.derivedErrorSurface),
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
                style: StoreColors.text(
                  context,
                  StoreTypography.caption,
                ).copyWith(
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
  const StoreRating({
    required this.value,
    this.count,
    this.compact = false,
    super.key,
  });

  final double value;
  final int? count;
  final bool compact;

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
          Icon(
            Icons.star_rounded,
            size: compact ? 13 : StoreIconSizes.small,
            color: StorePalette.warning,
          ),
          SizedBox(width: compact ? 2 : StoreSpacing.xxs),
          Text(
            safeValue,
            style:
                compact
                    ? StoreColors.text(
                      context,
                      StoreTypography.caption,
                    ).copyWith(fontSize: 10)
                    : StoreColors.text(context, StoreTypography.caption),
          ),
          if (count != null)
            Text(
              ' ($count)',
              style:
                  compact
                      ? StoreColors.text(
                        context,
                        StoreTypography.caption,
                      ).copyWith(fontSize: 10)
                      : StoreColors.text(context, StoreTypography.caption),
            ),
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
    this.compact = false,
    this.solidSelected = false,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final int? count;
  final bool compact;
  final bool solidSelected;

  @override
  Widget build(BuildContext context) => FilterChip(
    selected: selected,
    onSelected: onSelected,
    label: Text(count == null ? label : '$label ($count)'),
    labelStyle: StoreColors.text(context, StoreTypography.label).copyWith(
      color:
          selected && solidSelected
              ? Colors.white
              : selected
              ? StoreColors.resolve(context, StorePalette.navy)
              : StoreColors.resolve(context, StorePalette.textPrimary),
    ),
    backgroundColor: StoreColors.resolve(context, StorePalette.surface),
    selectedColor:
        solidSelected
            ? StorePalette.purple
            : StoreColors.resolve(context, StorePalette.lightPurple),
    checkmarkColor: StorePalette.purple,
    showCheckmark: !solidSelected,
    side: BorderSide(
      color:
          selected
              ? StorePalette.purple
              : StoreColors.resolve(context, StorePalette.border),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(StoreRadii.pill),
    ),
    materialTapTargetSize: compact ? MaterialTapTargetSize.shrinkWrap : null,
    visualDensity: compact ? VisualDensity.compact : null,
    labelPadding:
        compact
            ? const EdgeInsets.symmetric(horizontal: StoreSpacing.xxs)
            : null,
    padding: compact ? EdgeInsets.zero : null,
  );
}
