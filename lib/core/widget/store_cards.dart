import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../theme/store_tokens.dart';
import '../theme/store_typography.dart';
import 'store_chips.dart';

class StoreProductCard extends StatelessWidget {
  const StoreProductCard({
    required this.name,
    required this.price,
    required this.media,
    required this.onTap,
    this.originalPrice,
    this.currency = '₪',
    this.rating,
    this.reviewCount,
    this.discountPercent,
    this.inStock = true,
    this.isFavorite = false,
    this.onFavorite,
    this.onAddToCart,
    this.compact = false,
    this.homePresentation = false,
    super.key,
  });

  final String name;
  final num price;
  final Widget media;
  final VoidCallback onTap;
  final num? originalPrice;
  final String currency;
  final double? rating;
  final int? reviewCount;
  final num? discountPercent;
  final bool inStock;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;
  final bool compact;
  final bool homePresentation;

  @override
  Widget build(BuildContext context) {
    final availability = inStock ? 'storeAvailable'.tr : 'storeUnavailable'.tr;
    final semanticsLabel = 'storeProductCardSemantics'.trParams({
      'name': name,
      'price': '$price',
      'currency': currency,
      'availability': availability,
    });
    final productMedia = Stack(
      fit: StackFit.expand,
      children: [
        media,
        if (discountPercent != null)
          PositionedDirectional(
            top: StoreSpacing.xs,
            start: StoreSpacing.xs,
            child: StoreDiscountChip(percent: discountPercent!),
          ),
        if (compact &&
            discountPercent == null &&
            (!homePresentation || !inStock))
          PositionedDirectional(
            top: StoreSpacing.xs,
            start: StoreSpacing.xs,
            child: StoreAvailabilityChip(inStock: inStock),
          ),
        if (onFavorite != null)
          PositionedDirectional(
            top: StoreSpacing.xxs,
            end: StoreSpacing.xxs,
            child:
                homePresentation
                    ? SizedBox.square(
                      dimension: 32,
                      child: IconButton.filledTonal(
                        tooltip:
                            isFavorite
                                ? 'storeRemoveFavorite'.tr
                                : 'storeAddFavorite'.tr,
                        onPressed: onFavorite,
                        padding: EdgeInsets.zero,
                        iconSize: StoreIconSizes.medium,
                        style: IconButton.styleFrom(
                          backgroundColor: StorePalette.surface.withValues(
                            alpha: 0.9,
                          ),
                        ),
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavorite
                                  ? StorePalette.error
                                  : StorePalette.textPrimary,
                        ),
                      ),
                    )
                    : IconButton.filledTonal(
                      tooltip:
                          isFavorite
                              ? 'storeRemoveFavorite'.tr
                              : 'storeAddFavorite'.tr,
                      onPressed: onFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color:
                            isFavorite
                                ? StorePalette.error
                                : StorePalette.textSecondary,
                      ),
                    ),
          ),
      ],
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: StorePalette.surface,
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: StorePalette.border),
              borderRadius: BorderRadius.circular(StoreRadii.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compact)
                  Expanded(child: productMedia)
                else
                  AspectRatio(
                    aspectRatio: StoreCalibration.productMediaAspectRatio,
                    child: productMedia,
                  ),
                Padding(
                  padding: EdgeInsets.all(
                    compact ? StoreSpacing.xs : StoreSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            compact
                                ? StoreTypography.label
                                : StoreTypography.bodyMedium,
                      ),
                      SizedBox(
                        height: compact ? StoreSpacing.xxs : StoreSpacing.xs,
                      ),
                      if (compact && rating != null) ...[
                        StoreRating(value: rating!, count: reviewCount),
                        const SizedBox(height: StoreSpacing.xxs),
                      ],
                      Wrap(
                        spacing: StoreSpacing.xs,
                        runSpacing: StoreSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${homePresentation ? _formatStorePrice(price) : price} $currency',
                            style: (compact
                                    ? StoreTypography.label
                                    : StoreTypography.title)
                                .copyWith(color: StorePalette.navy),
                          ),
                          if (originalPrice != null)
                            Text(
                              '${homePresentation ? _formatStorePrice(originalPrice!) : originalPrice} $currency',
                              style: StoreTypography.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      if (!compact) ...[
                        const SizedBox(height: StoreSpacing.xs),
                        Row(
                          children: [
                            StoreAvailabilityChip(inStock: inStock),
                            if (rating != null) ...[
                              const Spacer(),
                              StoreRating(value: rating!, count: reviewCount),
                            ],
                          ],
                        ),
                      ],
                      if (onAddToCart != null) ...[
                        SizedBox(
                          height: compact ? StoreSpacing.xxs : StoreSpacing.xs,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height:
                              compact
                                  ? StoreCalibration.compactControlHeight
                                  : StoreCalibration.controlHeight,
                          child:
                              compact
                                  ? FilledButton.icon(
                                    onPressed: inStock ? onAddToCart : null,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: StoreSpacing.xxs,
                                      ),
                                      backgroundColor: StorePalette.purple,
                                      textStyle: StoreTypography.caption
                                          .copyWith(
                                            fontSize: 10.5,
                                            fontWeight:
                                                StoreTypography.semiBold,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          StoreRadii.sm,
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                      size: StoreIconSizes.small,
                                    ),
                                    label: Text(
                                      'storeAddToCart'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                  : OutlinedButton.icon(
                                    onPressed: inStock ? onAddToCart : null,
                                    icon: const Icon(
                                      Icons.add_shopping_cart_outlined,
                                    ),
                                    label: Text('storeAddToCart'.tr),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatStorePrice(num value) =>
    NumberFormat('#,##0.##', 'en_US').format(value);

class StoreCategoryCard extends StatelessWidget {
  const StoreCategoryCard({
    required this.title,
    required this.media,
    required this.onTap,
    this.itemCount,
    this.compact = false,
    super.key,
  });

  final String title;
  final Widget media;
  final VoidCallback onTap;
  final int? itemCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final countLabel =
        itemCount == null
            ? null
            : 'storeProductCount'.trParams({'count': '$itemCount'});
    final semanticsLabel =
        countLabel == null
            ? title
            : 'storeCategoryCardSemantics'.trParams({
              'title': title,
              'count': countLabel,
            });
    if (compact) {
      return Semantics(
        button: true,
        label: semanticsLabel,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(StoreRadii.md),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(StoreSpacing.xxs),
                    decoration: BoxDecoration(
                      color: StorePalette.background,
                      borderRadius: BorderRadius.circular(StoreRadii.md),
                    ),
                    child: media,
                  ),
                ),
                const SizedBox(height: StoreSpacing.xxs),
                Text(
                  title,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: StoreTypography.caption.copyWith(
                    color: StorePalette.textPrimary,
                    fontSize: 10,
                    fontWeight: StoreTypography.medium,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: StorePalette.surface,
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(StoreSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: StorePalette.border),
              borderRadius: BorderRadius.circular(StoreRadii.lg),
            ),
            child: Column(
              children: [
                Expanded(child: media),
                const SizedBox(height: StoreSpacing.xs),
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: StoreTypography.label,
                ),
                if (countLabel != null)
                  Text(countLabel, style: StoreTypography.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
