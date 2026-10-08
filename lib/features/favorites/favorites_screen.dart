import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/favorites/favorites_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/widget/store_cards.dart';
import '../../core/widget/favorite_feedback.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_product_layout_toggle.dart';
import '../../core/widget/store_skeletons.dart';
import '../../core/widget/store_states.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    return ColoredBox(
      color: StorePalette.background,
      child: Obx(() {
        switch (controller.status.value) {
          case FavoritesStatus.initial:
          case FavoritesStatus.loading:
            return StoreProductCollectionSkeleton(
              isGrid: _isGrid,
              showHeader: true,
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    StoreSpacing.md,
                    StoreSpacing.xs,
                    StoreSpacing.md,
                    StoreSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'المنتجات المفضلة',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      StoreProductLayoutToggle(
                        isGrid: _isGrid,
                        onChanged: (value) => setState(() => _isGrid = value),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.load,
                    color: StorePalette.purple,
                    child:
                        _isGrid
                            ? GridView.builder(
                              padding: const EdgeInsets.all(StoreSpacing.sm),
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 260,
                                    crossAxisSpacing: StoreSpacing.sm,
                                    mainAxisSpacing: StoreSpacing.sm,
                                  ),
                              itemCount: controller.items.length,
                              itemBuilder:
                                  (_, index) => _FavoriteCard(
                                    item: controller.items[index],
                                    controller: controller,
                                    grid: true,
                                  ),
                            )
                            : ListView.separated(
                              padding: const EdgeInsets.all(StoreSpacing.sm),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.items.length,
                              separatorBuilder:
                                  (_, _) =>
                                      const SizedBox(height: StoreSpacing.sm),
                              itemBuilder:
                                  (_, index) => _FavoriteCard(
                                    item: controller.items[index],
                                    controller: controller,
                                    grid: false,
                                  ),
                            ),
                  ),
                ),
              ],
            );
        }
      }),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.item,
    required this.controller,
    required this.grid,
  });

  final Item item;
  final FavoritesController controller;
  final bool grid;

  @override
  Widget build(BuildContext context) {
    final shop = Get.find<ShopController>();
    return Obx(() {
      shop.cartLines.length;
      final media = StoreNetworkMedia(
        url: _mainMedia(item),
        semanticLabel: _name(item),
        fit: BoxFit.contain,
      );
      void open() => Get.find<ProductControllerImp>().getCategoryById(
        itemId: item.productId,
      );
      Future<void> favorite() async {
        final outcome = await controller.requestToggle(
          listingId: item.listingId,
          productId: item.productId,
        );
        showFavoriteFeedback(outcome);
      }

      if (!grid) {
        return StoreProductListCard(
          name: _name(item),
          price: item.normailPrice,
          originalPrice: item.oldPrice,
          discountPercent: item.discount,
          rating: item.rate,
          reviewCount: item.reviewCount,
          inStock: item.available && item.purchasable,
          isFavorite: controller.contains(item.listingId),
          isInCart: shop.containsItem(item),
          media: media,
          onTap: open,
          onFavorite: favorite,
          onAddToCart: () => shop.addToCart(item),
        );
      }
      return StoreProductCard(
        name: _name(item),
        price: item.normailPrice,
        originalPrice: item.oldPrice,
        discountPercent: item.discount > 0 ? item.discount : null,
        rating: item.rate,
        reviewCount: item.reviewCount,
        inStock: item.available && item.purchasable,
        isFavorite: controller.contains(item.listingId),
        isInCart: shop.containsItem(item),
        media: media,
        onTap: open,
        onFavorite: favorite,
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
