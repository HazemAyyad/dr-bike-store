import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    final availability = inStock ? 'storeAvailable'.tr : 'storeUnavailable'.tr;
    final semanticsLabel = 'storeProductCardSemantics'.trParams({
      'name': name,
      'price': '$price',
      'currency': currency,
      'availability': availability,
    });

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
                AspectRatio(
                  aspectRatio: StoreCalibration.productMediaAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      media,
                      if (discountPercent != null)
                        PositionedDirectional(
                          top: StoreSpacing.xs,
                          start: StoreSpacing.xs,
                          child: StoreDiscountChip(percent: discountPercent!),
                        ),
                      if (onFavorite != null)
                        PositionedDirectional(
                          top: StoreSpacing.xxs,
                          end: StoreSpacing.xxs,
                          child: IconButton.filledTonal(
                            tooltip:
                                isFavorite
                                    ? 'storeRemoveFavorite'.tr
                                    : 'storeAddFavorite'.tr,
                            onPressed: onFavorite,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isFavorite
                                      ? StorePalette.error
                                      : StorePalette.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(StoreSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.bodyMedium,
                      ),
                      const SizedBox(height: StoreSpacing.xs),
                      Wrap(
                        spacing: StoreSpacing.xs,
                        runSpacing: StoreSpacing.xxs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '$price $currency',
                            style: StoreTypography.title.copyWith(
                              color: StorePalette.navy,
                            ),
                          ),
                          if (originalPrice != null)
                            Text(
                              '$originalPrice $currency',
                              style: StoreTypography.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
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
                      if (onAddToCart != null) ...[
                        const SizedBox(height: StoreSpacing.xs),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: inStock ? onAddToCart : null,
                            icon: const Icon(Icons.add_shopping_cart_outlined),
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

class StoreCategoryCard extends StatelessWidget {
  const StoreCategoryCard({
    required this.title,
    required this.media,
    required this.onTap,
    this.itemCount,
    super.key,
  });

  final String title;
  final Widget media;
  final VoidCallback onTap;
  final int? itemCount;

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
