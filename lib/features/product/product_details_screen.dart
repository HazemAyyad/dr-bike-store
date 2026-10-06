import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/product/product_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_chips.dart';
import 'widget/commints.dart';
import 'widget/items_similar.dart';
import 'widget/view_image_and_video.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<ProductControllerImp>(
    builder:
        (controller) => Scaffold(
          backgroundColor: StorePalette.background,
          appBar: AppBar(
            backgroundColor: StorePalette.surface,
            foregroundColor: StorePalette.navy,
            elevation: 0,
            title: Text('storeProductDetails'.tr, style: StoreTypography.title),
          ),
          body: _body(controller),
          bottomNavigationBar:
              controller.productState is StoreContent<Item>
                  ? _PurchaseBar(controller: controller)
                  : null,
        ),
  );

  Widget _body(ProductControllerImp controller) => switch (controller
      .productState) {
    StoreInitial<Item>() ||
    StoreLoading<Item>() => const Center(child: CircularProgressIndicator()),
    StoreEmpty<Item>(:final message) => _ProductState(
      icon: Icons.inventory_2_outlined,
      message: message.tr,
      onRetry:
          controller.identity.hasProduct
              ? () => controller.loadProductDetail(
                productId: controller.identity.productId!,
              )
              : null,
    ),
    StoreOffline<Item>(:final message) => _ProductState(
      icon: Icons.wifi_off_outlined,
      message: message.tr,
      onRetry:
          controller.identity.hasProduct
              ? () => controller.loadProductDetail(
                productId: controller.identity.productId!,
              )
              : null,
    ),
    StoreError<Item>(:final message) => _ProductState(
      icon: Icons.error_outline,
      message: message.tr,
      onRetry:
          controller.identity.hasProduct
              ? () => controller.loadProductDetail(
                productId: controller.identity.productId!,
              )
              : null,
    ),
    StoreContent<Item>(:final data) => _ProductContent(
      item: data,
      controller: controller,
    ),
    StoreSuccess<Item>() => const SizedBox.shrink(),
  };
}

class _ProductContent extends StatelessWidget {
  const _ProductContent({required this.item, required this.controller});

  final Item item;
  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final name = _localized(item.nameAr, item.nameEng, item.nameAbree);
    final description = _localized(
      item.descriptionAr,
      item.descriptionEng,
      item.descriptionAbree,
    );
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : Directionality.of(context),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          StoreSpacing.md,
          StoreSpacing.md,
          StoreSpacing.md,
          StoreSpacing.lg,
        ),
        children: [
          ViewImageAndVideo(controllerScreen: controller),
          const SizedBox(height: StoreSpacing.md),
          Text(name, style: StoreTypography.headline),
          const SizedBox(height: StoreSpacing.xs),
          Wrap(
            spacing: StoreSpacing.xs,
            runSpacing: StoreSpacing.xs,
            children: [
              StoreAvailabilityChip(
                inStock: item.available && item.purchasable,
              ),
              if (item.isNewItem)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('storeNew'.tr),
                ),
              if (item.discount > 0) StoreDiscountChip(percent: item.discount),
            ],
          ),
          const SizedBox(height: StoreSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.normailPrice.toStringAsFixed(2)} ₪',
                key: const Key('product-retail-price'),
                style: StoreTypography.headline.copyWith(
                  color: StorePalette.navy,
                ),
              ),
              if (item.rate > 0) ...[
                const Spacer(),
                const Icon(Icons.star, color: StorePalette.warning, size: 20),
                const SizedBox(width: StoreSpacing.xxs),
                Text(
                  item.rate.toStringAsFixed(1),
                  style: StoreTypography.label,
                ),
              ],
            ],
          ),
          const SizedBox(height: StoreSpacing.sm),
          _AvailabilityPanel(item: item),
          const SizedBox(height: StoreSpacing.md),
          _QuantitySelector(controller: controller),
          if (controller.hasOptions) ...[
            const SizedBox(height: StoreSpacing.md),
            _OptionsSection(controller: controller, item: item),
          ],
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: StoreSpacing.lg),
            Text('storeDescription'.tr, style: StoreTypography.title),
            const SizedBox(height: StoreSpacing.xs),
            Text(description, style: StoreTypography.body),
          ],
          const SizedBox(height: StoreSpacing.lg),
          ProductReviewsSection(
            state: controller.reviewsState,
            onRetry: () => controller.loadReviews(item.productId),
          ),
          const SizedBox(height: StoreSpacing.lg),
          SimilarItemsSection(controller: controller),
        ],
      ),
    );
  }

  String _localized(String ar, String en, String he) => switch (Get
      .locale
      ?.languageCode) {
    'en' => en.isNotEmpty ? en : ar,
    'he' => he.isNotEmpty ? he : ar,
    _ => ar.isNotEmpty ? ar : en,
  };
}

class _AvailabilityPanel extends StatelessWidget {
  const _AvailabilityPanel({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final purchasable = item.available && item.purchasable && item.stock > 0;
    return Container(
      key: const Key('product-availability'),
      padding: const EdgeInsets.all(StoreSpacing.sm),
      decoration: BoxDecoration(
        color:
            purchasable
                ? StorePalette.derivedSuccessSurface
                : StorePalette.derivedWarningSurface,
        borderRadius: BorderRadius.circular(StoreRadii.md),
      ),
      child: Row(
        children: [
          Icon(
            purchasable
                ? Icons.check_circle_outline
                : Icons.remove_shopping_cart_outlined,
            color: purchasable ? StorePalette.success : StorePalette.warning,
          ),
          const SizedBox(width: StoreSpacing.xs),
          Expanded(
            child: Text(
              purchasable
                  ? 'storeAvailableQuantity'.trParams({
                    'count': '${item.stock}',
                  })
                  : 'storeOutOfStock'.tr,
              style: StoreTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.controller});

  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text('storeQuantity'.tr, style: StoreTypography.title)),
      IconButton.outlined(
        key: const Key('quantity-decrement'),
        tooltip: 'storeDecreaseQuantity'.tr,
        onPressed:
            controller.quantity.canDecrement
                ? controller.decrementQuantity
                : null,
        icon: const Icon(Icons.remove),
      ),
      SizedBox(
        width: 48,
        child: Text(
          '${controller.quantity.value}',
          key: const Key('quantity-value'),
          textAlign: TextAlign.center,
          style: StoreTypography.title,
        ),
      ),
      IconButton.outlined(
        key: const Key('quantity-increment'),
        tooltip: 'storeIncreaseQuantity'.tr,
        onPressed:
            controller.quantity.canIncrement
                ? controller.incrementQuantity
                : null,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({required this.controller, required this.item});

  final ProductControllerImp controller;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final selectedSize = controller.options.selectedSizeIndex;
    final colors =
        selectedSize == null
            ? const <ItemSizeColor>[]
            : item.itemSizes[selectedSize].itemSizeColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('storeOptions'.tr, style: StoreTypography.title),
        const SizedBox(height: StoreSpacing.xs),
        Wrap(
          spacing: StoreSpacing.xs,
          children: List.generate(item.itemSizes.length, (index) {
            final size = item.itemSizes[index];
            return ChoiceChip(
              label: Text(size.size),
              selected: selectedSize == index,
              onSelected: (_) => controller.selectSize(index),
            );
          }),
        ),
        if (colors.isNotEmpty) ...[
          const SizedBox(height: StoreSpacing.xs),
          Wrap(
            spacing: StoreSpacing.xs,
            children: List.generate(colors.length, (index) {
              final color = colors[index];
              return ChoiceChip(
                label: Text(color.colorAr),
                selected: controller.options.selectedColorIndex == index,
                onSelected: (_) => controller.selectColor(index),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({required this.controller});

  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.all(StoreSpacing.sm),
      decoration: const BoxDecoration(
        color: StorePalette.surface,
        border: Border(top: BorderSide(color: StorePalette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('product-add-to-cart'),
              onPressed: controller.canPurchase ? controller.addToCart : null,
              icon: const Icon(Icons.add_shopping_cart_outlined),
              label: Text('storeAddToCart'.tr),
            ),
          ),
          const SizedBox(width: StoreSpacing.sm),
          Expanded(
            child: FilledButton(
              key: const Key('product-buy-now'),
              onPressed: controller.canPurchase ? controller.buyNow : null,
              style: FilledButton.styleFrom(
                backgroundColor: StorePalette.purple,
              ),
              child: Text('storeBuyNow'.tr),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProductState extends StatelessWidget {
  const _ProductState({
    required this.icon,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(StoreSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: StorePalette.textSecondary),
          const SizedBox(height: StoreSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: StoreTypography.body,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: StoreSpacing.sm),
            FilledButton(onPressed: onRetry, child: Text('storeRetry'.tr)),
          ],
        ],
      ),
    ),
  );
}
