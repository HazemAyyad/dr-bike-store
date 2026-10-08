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
    this.isInCart = false,
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
  final bool isInCart;
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
        if (onFavorite != null || (!compact && onAddToCart != null))
          PositionedDirectional(
            top: StoreSpacing.xxs,
            end: StoreSpacing.xxs,
            child: _StoreProductActions(
              inStock: inStock,
              isFavorite: isFavorite,
              isInCart: isInCart,
              onFavorite: onFavorite,
              onAddToCart: compact ? null : onAddToCart,
              dimension: homePresentation ? 30 : 36,
              iconSize:
                  homePresentation
                      ? StoreIconSizes.small
                      : StoreIconSizes.medium,
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
                      if (compact && onAddToCart != null) ...[
                        const SizedBox(height: StoreSpacing.xs),
                        SizedBox(
                          height: 32,
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: inStock ? onAddToCart : null,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  isInCart
                                      ? StorePalette.success
                                      : StorePalette.purple,
                              disabledBackgroundColor: StorePalette.border,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  StoreRadii.sm,
                                ),
                              ),
                              textStyle: StoreTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: StoreTypography.semiBold,
                              ),
                            ),
                            icon: Icon(
                              isInCart
                                  ? Icons.shopping_cart_rounded
                                  : Icons.add_shopping_cart_rounded,
                              size: 16,
                            ),
                            label: Text(
                              inStock
                                  ? isInCart
                                      ? 'في السلة'
                                      : 'أضف للسلة'
                                  : 'غير متوفر',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
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

class StoreProductListCard extends StatelessWidget {
  const StoreProductListCard({
    required this.name,
    required this.price,
    required this.media,
    required this.onTap,
    this.originalPrice,
    this.discountPercent,
    this.rating,
    this.reviewCount,
    this.inStock = true,
    this.isFavorite = false,
    this.isInCart = false,
    this.onFavorite,
    this.onAddToCart,
    super.key,
  });

  final String name;
  final num price;
  final num? originalPrice;
  final num? discountPercent;
  final double? rating;
  final int? reviewCount;
  final Widget media;
  final VoidCallback onTap;
  final bool inStock;
  final bool isFavorite;
  final bool isInCart;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 132,
    child: Material(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: StorePalette.border),
            borderRadius: BorderRadius.circular(StoreRadii.md),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    media,
                    if (discountPercent != null && discountPercent! > 0)
                      PositionedDirectional(
                        top: StoreSpacing.xs,
                        start: StoreSpacing.xs,
                        child: StoreDiscountChip(percent: discountPercent!),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(StoreSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: StoreTypography.bodyMedium,
                            ),
                          ),
                          if (onFavorite != null || onAddToCart != null)
                            _StoreProductActions(
                              inStock: inStock,
                              isFavorite: isFavorite,
                              isInCart: isInCart,
                              onFavorite: onFavorite,
                              onAddToCart: onAddToCart,
                              dimension: 34,
                              iconSize: StoreIconSizes.small,
                            ),
                        ],
                      ),
                      if (rating != null) ...[
                        const SizedBox(height: StoreSpacing.xxs),
                        StoreRating(value: rating!, count: reviewCount),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: StoreSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${_formatStorePrice(price)} ₪',
                                  style: StoreTypography.title.copyWith(
                                    color: StorePalette.navy,
                                  ),
                                ),
                                if (originalPrice != null)
                                  Text(
                                    '${_formatStorePrice(originalPrice!)} ₪',
                                    style: StoreTypography.caption.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

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
                  maxLines: 2,
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
                  maxLines: 3,
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

class _StoreProductActions extends StatelessWidget {
  const _StoreProductActions({
    required this.inStock,
    required this.isFavorite,
    required this.isInCart,
    required this.dimension,
    required this.iconSize,
    this.onFavorite,
    this.onAddToCart,
  });

  final bool inStock;
  final bool isFavorite;
  final bool isInCart;
  final double dimension;
  final double iconSize;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (onAddToCart != null)
        SizedBox.square(
          dimension: dimension,
          child: IconButton.filled(
            tooltip: isInCart ? 'تمت الإضافة للسلة' : 'storeAddToCart'.tr,
            onPressed: inStock ? onAddToCart : null,
            padding: EdgeInsets.zero,
            iconSize: iconSize,
            style: IconButton.styleFrom(
              backgroundColor:
                  isInCart ? StorePalette.success : StorePalette.purple,
              disabledBackgroundColor: StorePalette.border,
              foregroundColor: Colors.white,
            ),
            icon: Icon(
              isInCart
                  ? Icons.shopping_cart_rounded
                  : Icons.add_shopping_cart_rounded,
            ),
          ),
        ),
      if (onAddToCart != null && onFavorite != null)
        const SizedBox(width: StoreSpacing.xxs),
      if (onFavorite != null)
        SizedBox.square(
          dimension: dimension,
          child: IconButton.filledTonal(
            tooltip:
                isFavorite ? 'storeRemoveFavorite'.tr : 'storeAddFavorite'.tr,
            onPressed: onFavorite,
            padding: EdgeInsets.zero,
            iconSize: iconSize,
            style: IconButton.styleFrom(
              backgroundColor: StorePalette.surface.withValues(alpha: 0.92),
            ),
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color:
                  isFavorite ? StorePalette.error : StorePalette.textSecondary,
            ),
          ),
        ),
    ],
  );
}
