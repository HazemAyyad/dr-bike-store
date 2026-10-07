import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controller/favorites/favorites_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/commint_model.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../shop/shop_car_screen.dart';
import 'review_screen.dart';
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
          appBar: _ProductAppBar(controller: controller),
          body: _body(controller),
        ),
  );

  Widget _body(ProductControllerImp controller) => switch (controller
      .productState) {
    StoreInitial<Item>() || StoreLoading<Item>() => const Center(
      child: CircularProgressIndicator(color: StorePalette.purple),
    ),
    StoreEmpty<Item>(:final message) => _ProductState(
      icon: Icons.inventory_2_outlined,
      message: message.tr,
      onRetry: _retry(controller),
    ),
    StoreOffline<Item>(:final message) => _ProductState(
      icon: Icons.wifi_off_outlined,
      message: message.tr,
      onRetry: _retry(controller),
    ),
    StoreError<Item>(:final message) => _ProductState(
      icon: Icons.error_outline,
      message: message.tr,
      onRetry: _retry(controller),
    ),
    StoreContent<Item>(:final data) => _ProductContent(
      item: data,
      controller: controller,
    ),
    StoreSuccess<Item>() => const SizedBox.shrink(),
  };

  VoidCallback? _retry(ProductControllerImp controller) =>
      controller.identity.hasProduct
          ? () => controller.loadProductDetail(
            productId: controller.identity.productId!,
          )
          : null;
}

class _ProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ProductAppBar({required this.controller});

  final ProductControllerImp controller;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final item = controller.itemView;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: StorePalette.surface,
      foregroundColor: StorePalette.navy,
      elevation: 0,
      surfaceTintColor: StorePalette.surface,
      titleSpacing: StoreSpacing.xs,
      title: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            StoreIconButton(
              icon: Icons.arrow_back_ios_new,
              semanticLabel: _label(context, 'رجوع', 'Back'),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            StoreIconButton(
              icon: Icons.share_outlined,
              semanticLabel: _label(context, 'مشاركة المنتج', 'Share product'),
              onPressed: item == null ? null : () => _share(context, item),
            ),
            if (Get.isRegistered<FavoritesController>())
              Obx(() {
                final selected = Get.find<FavoritesController>().contains(
                  item?.listingId,
                );
                return StoreIconButton(
                  icon: selected ? Icons.favorite : Icons.favorite_border,
                  semanticLabel:
                      selected
                          ? 'storeRemoveFavorite'.tr
                          : 'storeAddFavorite'.tr,
                  onPressed: item == null ? null : () => _favorite(item),
                );
              })
            else
              StoreIconButton(
                icon: Icons.favorite_border,
                semanticLabel: 'storeAddFavorite'.tr,
                onPressed: item == null ? null : () => _favorite(item),
              ),
            _CartAction(onPressed: () => Get.to(() => const ShopCarScreen())),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, Item item) async {
    final language = _languageCode(context);
    final name = _localizedName(item, language);
    final lines = <String>[
      name,
      if (item.model.trim().isNotEmpty)
        '${_label(context, 'رمز المنتج', 'Product code')}: ${item.model.trim()}',
      '${item.normailPrice.toStringAsFixed(2)} ₪',
    ];
    try {
      await SharePlus.instance.share(
        ShareParams(text: lines.join('\n'), subject: name),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _label(context, 'تعذرت مشاركة المنتج', 'Unable to share product'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _favorite(Item item) async {
    if (!Get.isRegistered<FavoritesController>()) return;
    final outcome = await Get.find<FavoritesController>().requestToggle(
      listingId: item.listingId,
      productId: item.productId,
    );
    if (outcome == FavoriteActionOutcome.loginRequired) {
      await Get.toNamed(RouteHelper.intoLog);
      return;
    }
    if (outcome == FavoriteActionOutcome.failed ||
        outcome == FavoriteActionOutcome.invalidIdentity) {
      Get.snackbar(
        'storeFavoritesUnavailableTitle'.tr,
        'storeFavoritesUnavailableMessage'.tr,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(StoreSpacing.md),
      );
    }
  }
}

class _CartAction extends StatelessWidget {
  const _CartAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShopController>()) {
      return StoreIconButton(
        icon: Icons.shopping_cart_outlined,
        semanticLabel: 'storeCart'.tr,
        onPressed: onPressed,
      );
    }
    return GetBuilder<ShopController>(
      builder: (shop) {
        final count = shop.cartItems.length;
        return StoreIconButton(
          icon: Icons.shopping_cart_outlined,
          semanticLabel: 'storeCart'.tr,
          badgeCount: count == 0 ? null : count,
          onPressed: onPressed,
        );
      },
    );
  }
}

class _ProductContent extends StatelessWidget {
  const _ProductContent({required this.item, required this.controller});

  final Item item;
  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final language = _languageCode(context);
    final name = _localizedName(item, language);
    final description = _localized(
      language,
      item.descriptionAr,
      item.descriptionEng,
      item.descriptionAbree,
    );
    return Directionality(
      textDirection:
          language == 'ar' ? TextDirection.rtl : Directionality.of(context),
      child: ListView(
        key: const Key('product-details-scroll'),
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
        children: [
          ViewImageAndVideo(controllerScreen: controller),
          const SizedBox(height: StoreSpacing.sm),
          _ProductIdentity(item: item, name: name, controller: controller),
          if (_quickSpecs(item).isNotEmpty) ...[
            const SizedBox(height: StoreSpacing.sm),
            _QuickSpecifications(item: item),
          ],
          if (controller.hasOptions) ...[
            const SizedBox(height: StoreSpacing.sm),
            _OptionsSection(controller: controller, item: item),
          ],
          const SizedBox(height: StoreSpacing.sm),
          _PurchaseSection(controller: controller, item: item),
          const SizedBox(height: StoreSpacing.sm),
          _DetailsSections(item: item, description: description),
          const SizedBox(height: StoreSpacing.md),
          ProductReviewsSection(
            state: controller.reviewsState,
            onRetry: () => controller.loadReviews(item.productId),
          ),
          const SizedBox(height: StoreSpacing.xs),
          TextButton.icon(
            onPressed:
                () => Get.to(() => ReviewScreen(productId: item.productId)),
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(_label(context, 'عرض وكتابة التقييمات', 'Reviews')),
          ),
          const SizedBox(height: StoreSpacing.md),
          SimilarItemsSection(controller: controller),
        ],
      ),
    );
  }
}

class _ProductIdentity extends StatelessWidget {
  const _ProductIdentity({
    required this.item,
    required this.name,
    required this.controller,
  });

  final Item item;
  final String name;
  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final loadedReviewCount = switch (controller.reviewsState) {
      StoreContent<List<Review>>(:final data) => data.length,
      _ => 0,
    };
    final reviewCount =
        item.reviewCount > 0 ? item.reviewCount : loadedReviewCount;
    final selectedPrice = item.itemSizeColorsprice ?? item.normailPrice;
    final selectedDiscount = item.itemSizediscount ?? item.discount;
    final oldPrice =
        item.itemSizeColorsprice != null && selectedDiscount > 0
            ? selectedPrice / (1 - (selectedDiscount.clamp(0, 99.99) / 100))
            : item.oldPrice;
    final brand = _presentationText(item, 'brand_translations', context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: StoreTypography.headline.copyWith(fontSize: 19),
                  ),
                  if (item.model.trim().isNotEmpty) ...[
                    const SizedBox(height: StoreSpacing.xxs),
                    Text(
                      '${_label(context, 'رمز المنتج', 'Product code')}: ${item.model.trim()}',
                      key: const Key('product-code'),
                      style: StoreTypography.caption,
                    ),
                  ],
                  const SizedBox(height: StoreSpacing.xxs),
                  Text(
                    brand.isNotEmpty ? brand : 'storeBrandName'.tr,
                    style: StoreTypography.caption.copyWith(
                      color: StorePalette.purple,
                      fontWeight: StoreTypography.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isNewItem)
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text('storeNew'.tr),
              ),
          ],
        ),
        const SizedBox(height: StoreSpacing.sm),
        Wrap(
          spacing: StoreSpacing.sm,
          runSpacing: StoreSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${selectedPrice.toStringAsFixed(2)} ₪',
              key: const Key('product-retail-price'),
              textDirection: TextDirection.ltr,
              style: StoreTypography.headline.copyWith(
                color: StorePalette.navy,
              ),
            ),
            if (oldPrice != null && oldPrice > selectedPrice)
              Text(
                '${oldPrice.toStringAsFixed(2)} ₪',
                textDirection: TextDirection.ltr,
                style: StoreTypography.body.copyWith(
                  color: StorePalette.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            if (selectedDiscount > 0) _DiscountBadge(percent: selectedDiscount),
            if (item.rate > 0)
              _Rating(
                rate: item.rate,
                reviewCount: reviewCount > 0 ? reviewCount : null,
              ),
          ],
        ),
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final num percent;

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100);
    final formatted =
        value == value.roundToDouble()
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StoreSpacing.xs,
        vertical: StoreSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: StorePalette.derivedErrorSurface,
        borderRadius: BorderRadius.circular(StoreRadii.sm),
      ),
      child: Text(
        _languageCode(context) == 'ar' ? 'خصم $formatted%' : '$formatted% off',
        style: StoreTypography.caption.copyWith(color: StorePalette.error),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rate, required this.reviewCount});

  final double rate;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.star_rounded, color: StorePalette.warning, size: 20),
      const SizedBox(width: StoreSpacing.xxs),
      Text(
        rate.toStringAsFixed(1),
        style: StoreTypography.label,
        textDirection: TextDirection.ltr,
      ),
      if (reviewCount != null) ...[
        const SizedBox(width: StoreSpacing.xxs),
        Text('($reviewCount)', style: StoreTypography.caption),
      ],
    ],
  );
}

class _QuickSpecifications extends StatelessWidget {
  const _QuickSpecifications({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final specs = _quickSpecs(item)
        .map(
          (raw) => _QuickSpec(
            icon: _quickSpecIcon('${raw['icon'] ?? 'custom'}'),
            label: _translatedMap(raw['label_translations'], context),
            value: _translatedMap(raw['value_translations'], context),
          ),
        )
        .toList(growable: false);
    return Row(
      key: const Key('product-quick-specifications'),
      children: [
        for (var i = 0; i < specs.length; i++) ...[
          if (i > 0) const SizedBox(width: StoreSpacing.xs),
          Expanded(child: _QuickSpecCard(spec: specs[i])),
        ],
      ],
    );
  }
}

class _QuickSpec {
  const _QuickSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _QuickSpecCard extends StatelessWidget {
  const _QuickSpecCard({required this.spec});

  final _QuickSpec spec;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 60),
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.md),
      border: Border.all(color: StorePalette.border),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(spec.icon, color: StorePalette.purple, size: 20),
        const SizedBox(height: StoreSpacing.xxs),
        Text(
          spec.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StoreTypography.caption,
        ),
        Text(
          spec.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StoreTypography.label,
        ),
      ],
    ),
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
    return Container(
      padding: const EdgeInsets.all(StoreSpacing.xs),
      decoration: BoxDecoration(
        color: StorePalette.surface,
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        border: Border.all(color: StorePalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('storeOptions'.tr, style: StoreTypography.title),
          const SizedBox(height: StoreSpacing.xs),
          Wrap(
            spacing: StoreSpacing.xs,
            runSpacing: StoreSpacing.xs,
            children: List.generate(item.itemSizes.length, (index) {
              final size = item.itemSizes[index];
              return ChoiceChip(
                key: ValueKey('product-size-$index'),
                label: Text(size.size),
                selected: selectedSize == index,
                onSelected: (_) => controller.selectSize(index),
              );
            }),
          ),
          if (colors.isNotEmpty) ...[
            const SizedBox(height: StoreSpacing.sm),
            Text(
              _label(context, 'اللون', 'Color'),
              style: StoreTypography.label,
            ),
            const SizedBox(height: StoreSpacing.xs),
            Wrap(
              spacing: StoreSpacing.xs,
              runSpacing: StoreSpacing.xs,
              children: List.generate(colors.length, (index) {
                final color = colors[index];
                return ChoiceChip(
                  key: ValueKey('product-color-$index'),
                  avatar: const Icon(Icons.circle_outlined, size: 18),
                  label: Text(_colorName(context, color)),
                  selected: controller.options.selectedColorIndex == index,
                  onSelected: (_) => controller.selectColor(index),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  String _colorName(
    BuildContext context,
    ItemSizeColor color,
  ) => switch (_languageCode(context)) {
    'en' => color.colorEn?.isNotEmpty == true ? color.colorEn! : color.colorAr,
    'he' =>
      color.colorAbbr?.isNotEmpty == true ? color.colorAbbr! : color.colorAr,
    _ => color.colorAr,
  };
}

class _PurchaseSection extends StatelessWidget {
  const _PurchaseSection({required this.controller, required this.item});

  final ProductControllerImp controller;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final purchasable = item.available && item.purchasable && item.stock > 0;
    return GetBuilder<ShopController>(
      init: controller.shopController,
      builder: (shop) {
        final inCart = shop.containsItem(item);
        return Container(
          padding: const EdgeInsets.all(StoreSpacing.xs),
          decoration: BoxDecoration(
            color: StorePalette.surface,
            borderRadius: BorderRadius.circular(StoreRadii.lg),
            border: Border.all(color: StorePalette.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      key: const Key('product-availability'),
                      children: [
                        Icon(
                          purchasable
                              ? Icons.check_circle
                              : Icons.remove_shopping_cart_outlined,
                          color:
                              purchasable
                                  ? StorePalette.success
                                  : StorePalette.warning,
                          size: 20,
                        ),
                        const SizedBox(width: StoreSpacing.xs),
                        Flexible(
                          child: Text(
                            purchasable
                                ? 'storeAvailableQuantity'.trParams({
                                  'count': '${item.stock}',
                                })
                                : 'storeOutOfStock'.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: StoreTypography.label.copyWith(
                              color:
                                  purchasable
                                      ? StorePalette.success
                                      : StorePalette.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: StoreSpacing.xs),
                  _QuantitySelector(controller: controller),
                ],
              ),
              const SizedBox(height: StoreSpacing.xs),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: StoreButton(
                      key: const Key('product-add-to-cart'),
                      label: inCart ? 'في السلة' : 'storeAddToCart'.tr,
                      height: 42,
                      icon:
                          inCart
                              ? Icons.check_circle_rounded
                              : Icons.shopping_cart_outlined,
                      onPressed:
                          controller.canPurchase ? controller.addToCart : null,
                    ),
                  ),
                  const SizedBox(width: StoreSpacing.xs),
                  Expanded(
                    flex: 2,
                    child: StoreButton(
                      key: const Key('product-buy-now'),
                      label: 'storeBuyNow'.tr,
                      height: 42,
                      variant: StoreButtonVariant.secondary,
                      onPressed:
                          controller.canPurchase ? controller.buyNow : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.controller});

  final ProductControllerImp controller;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: StorePalette.background,
      borderRadius: BorderRadius.circular(StoreRadii.md),
      border: Border.all(color: StorePalette.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('quantity-decrement'),
          tooltip: 'storeDecreaseQuantity'.tr,
          visualDensity: VisualDensity.compact,
          onPressed:
              controller.quantity.canDecrement
                  ? controller.decrementQuantity
                  : null,
          icon: const Icon(Icons.remove, size: 18),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${controller.quantity.value}',
            key: const Key('quantity-value'),
            textAlign: TextAlign.center,
            style: StoreTypography.label,
          ),
        ),
        IconButton(
          key: const Key('quantity-increment'),
          tooltip: 'storeIncreaseQuantity'.tr,
          visualDensity: VisualDensity.compact,
          onPressed:
              controller.quantity.canIncrement
                  ? controller.incrementQuantity
                  : null,
          icon: const Icon(Icons.add, size: 18),
        ),
      ],
    ),
  );
}

class _DetailsSections extends StatelessWidget {
  const _DetailsSections({required this.item, required this.description});

  final Item item;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: StorePalette.surface,
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      border: Border.all(color: StorePalette.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        ExpansionTile(
          key: const Key('product-specifications-section'),
          leading: const Icon(Icons.description_outlined),
          title: Text(
            _label(context, 'مواصفات المنتج', 'Product specifications'),
            style: StoreTypography.label,
          ),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(
            StoreSpacing.md,
            0,
            StoreSpacing.md,
            StoreSpacing.md,
          ),
          children: [
            if (description.trim().isNotEmpty)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(description, style: StoreTypography.body),
              ),
            if (description.trim().isEmpty)
              _UnavailablePolicy(
                text: _label(
                  context,
                  'لم يتم توفير مواصفات إضافية لهذا المنتج.',
                  'No additional product specifications were provided.',
                ),
              ),
          ],
        ),
        const Divider(height: 1),
        ExpansionTile(
          key: const Key('shipping-warranty-section'),
          leading: const Icon(Icons.local_shipping_outlined),
          title: Text(
            _label(context, 'الشحن والضمان', 'Shipping and warranty'),
            style: StoreTypography.label,
          ),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(
            StoreSpacing.md,
            0,
            StoreSpacing.md,
            StoreSpacing.md,
          ),
          children: [
            _UnavailablePolicy(
              text:
                  _presentationText(
                        item,
                        'shipping_warranty_translations',
                        context,
                      ).isNotEmpty
                      ? _presentationText(
                        item,
                        'shipping_warranty_translations',
                        context,
                      )
                      : _label(
                        context,
                        'تفاصيل الشحن والضمان غير متوفرة لهذا المنتج.',
                        'Shipping and warranty details are unavailable for this product.',
                      ),
            ),
          ],
        ),
        const Divider(height: 1),
        ExpansionTile(
          key: const Key('return-policy-section'),
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(
            _label(context, 'سياسة الإرجاع', 'Return policy'),
            style: StoreTypography.label,
          ),
          childrenPadding: const EdgeInsetsDirectional.fromSTEB(
            StoreSpacing.md,
            0,
            StoreSpacing.md,
            StoreSpacing.md,
          ),
          children: [
            _UnavailablePolicy(
              text:
                  _presentationText(
                        item,
                        'return_policy_translations',
                        context,
                      ).isNotEmpty
                      ? _presentationText(
                        item,
                        'return_policy_translations',
                        context,
                      )
                      : _label(
                        context,
                        'تفاصيل سياسة الإرجاع غير متوفرة لهذا المنتج.',
                        'Return policy details are unavailable for this product.',
                      ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _UnavailablePolicy extends StatelessWidget {
  const _UnavailablePolicy({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      text,
      style: StoreTypography.caption.copyWith(
        color: StorePalette.textSecondary,
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

String _localizedName(Item item, String language) =>
    _localized(language, item.nameAr, item.nameEng, item.nameAbree);

String _localized(String language, String ar, String en, String he) =>
    switch (language) {
      'en' => en.isNotEmpty ? en : ar,
      'he' => he.isNotEmpty ? he : ar,
      _ => ar.isNotEmpty ? ar : en,
    };

String _label(BuildContext context, String ar, String en) =>
    _languageCode(context) == 'ar' ? ar : en;

String _languageCode(BuildContext context) =>
    Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode;

List<Map<String, dynamic>> _quickSpecs(Item item) {
  final raw = item.storePresentation['quick_specs'];
  final configured =
      raw is List
          ? raw
              .whereType<Map>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .where(
                (entry) =>
                    entry['label_translations'] is Map &&
                    entry['value_translations'] is Map,
              )
              .take(3)
              .toList(growable: false)
          : <Map<String, dynamic>>[];
  if (configured.isNotEmpty) return configured;

  return <Map<String, dynamic>>[
    {
      'icon': 'stock',
      'label_translations': {'ar': 'المتوفر', 'en': 'Available'},
      'value_translations': {'ar': '${item.stock}', 'en': '${item.stock}'},
    },
    if (item.manufactureYear != null)
      {
        'icon': 'year',
        'label_translations': {'ar': 'سنة الصنع', 'en': 'Year'},
        'value_translations': {
          'ar': '${item.manufactureYear}',
          'en': '${item.manufactureYear}',
        },
      },
    if (item.model.trim().isNotEmpty)
      {
        'icon': 'model',
        'label_translations': {'ar': 'الموديل', 'en': 'Model'},
        'value_translations': {
          'ar': item.model.trim(),
          'en': item.model.trim(),
        },
      },
  ];
}

String _presentationText(Item item, String key, BuildContext context) =>
    _translatedMap(item.storePresentation[key], context);

String _translatedMap(dynamic value, BuildContext context) {
  if (value is! Map) return '';
  final language = _languageCode(context);
  final map = Map<String, dynamic>.from(value);
  return '${map[language] ?? map['ar'] ?? map['en'] ?? map['he'] ?? ''}'.trim();
}

IconData _quickSpecIcon(String icon) => switch (icon) {
  'speed' => Icons.speed_outlined,
  'battery' => Icons.battery_charging_full_outlined,
  'motor' => Icons.electric_bolt_outlined,
  'range' => Icons.route_outlined,
  'weight' => Icons.scale_outlined,
  'warranty' => Icons.verified_user_outlined,
  'stock' => Icons.inventory_2_outlined,
  'year' => Icons.calendar_month_outlined,
  'model' => Icons.qr_code_2,
  _ => Icons.tune_outlined,
};
