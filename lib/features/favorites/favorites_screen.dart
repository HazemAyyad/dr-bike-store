import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/favorites/favorites_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_cards.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    return ColoredBox(
      color: StorePalette.background,
      child: Obx(() {
        switch (controller.status.value) {
          case FavoritesStatus.initial:
          case FavoritesStatus.loading:
            return const Center(
              child: CircularProgressIndicator(color: StorePalette.purple),
            );
          case FavoritesStatus.error:
            return StoreMessageState(
              kind: StoreMessageKind.error,
              icon: Icons.error_outline,
              title: 'تعذر تحميل المفضلة',
              message: 'تحقق من الاتصال ثم أعد المحاولة.',
              actionLabel: 'إعادة المحاولة',
              onAction: controller.load,
            );
          case FavoritesStatus.empty:
            return const StoreMessageState(
              kind: StoreMessageKind.empty,
              icon: Icons.favorite_border,
              title: 'المفضلة فارغة',
              message: 'اضغط على رمز القلب لحفظ المنتجات هنا.',
            );
          case FavoritesStatus.content:
            return RefreshIndicator(
              onRefresh: controller.load,
              color: StorePalette.purple,
              child: GridView.builder(
                padding: const EdgeInsets.all(StoreSpacing.sm),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: 260,
                  crossAxisSpacing: StoreSpacing.sm,
                  mainAxisSpacing: StoreSpacing.sm,
                ),
                itemCount: controller.items.length,
                itemBuilder: (_, index) {
                  final item = controller.items[index];
                  return _FavoriteCard(item: item, controller: controller);
                },
              ),
            );
        }
      }),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.item, required this.controller});

  final Item item;
  final FavoritesController controller;

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Obx(() {
      shop.cartLines.length;
      return StoreProductCard(
        name: _name(item),
        price: item.normailPrice,
        originalPrice: item.oldPrice,
        discountPercent: item.discount > 0 ? item.discount : null,
        inStock: item.available && item.purchasable,
        isFavorite: controller.contains(item.listingId),
        isInCart: shop.containsItem(item),
        media: StoreNetworkMedia(
          url: _mainMedia(item),
          semanticLabel: _name(item),
          fit: BoxFit.contain,
        ),
        onTap:
            () => Get.find<ProductControllerImp>().getCategoryById(
              itemId: item.productId,
            ),
        onFavorite:
            () => controller.requestToggle(
              listingId: item.listingId,
              productId: item.productId,
            ),
        onAddToCart: () => shop.addToCart(item),
        compact: true,
      );
    });
  }

  String _name(Item item) => switch (Get.locale?.languageCode) {
    'en' => item.nameEng,
    'he' => item.nameAbree,
    _ => item.nameAr,
  };

  String? _mainMedia(Item item) {
    if (item.storefrontMedia.isEmpty) return null;
    return item.storefrontMedia
        .firstWhere(
          (media) => media.isMain,
          orElse: () => item.storefrontMedia.first,
        )
        .path;
  }
}
