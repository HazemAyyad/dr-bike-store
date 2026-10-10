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
import '../search/store_search_action.dart';

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
    return Scaffold(
      backgroundColor: StorePalette.background,
      appBar: AppBar(
        backgroundColor: StorePalette.surface,
        foregroundColor: StorePalette.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text('المنتجات المفضلة'),
        actions: [
          const StoreSearchAction(),
          StoreProductLayoutToggle(
            isGrid: _isGrid,
            onChanged: (value) => setState(() => _isGrid = value),
          ),
          const SizedBox(width: StoreSpacing.xs),
        ],
      ),
      body: Obx(() {
        switch (controller.status.value) {
          case FavoritesStatus.initial:
          case FavoritesStatus.loading:
            return StoreProductCollectionSkeleton(
              isGrid: _isGrid,
              showHeader: false,
            );
          case FavoritesStatus.error:
            return _refreshableState(
              controller: controller,
              child: StoreMessageState(
                kind: StoreMessageKind.error,
                icon: Icons.error_outline,
                title: 'تعذر تحميل المفضلة',
                message: 'تحقق من الاتصال ثم أعد المحاولة.',
                actionLabel: 'إعادة المحاولة',
                onAction: controller.load,
              ),
            );
          case FavoritesStatus.empty:
            return _refreshableState(
              controller: controller,
              child: const StoreMessageState(
                kind: StoreMessageKind.empty,
                icon: Icons.favorite_border,
                title: 'المفضلة فارغة',
                message: 'اضغط على رمز القلب لحفظ المنتجات هنا.',
              ),
            );
          case FavoritesStatus.content:
            return RefreshIndicator(
              onRefresh: controller.load,
              color: StorePalette.purple,
              child:
                  _isGrid
                      ? GridView.builder(
                        padding: const EdgeInsets.all(StoreSpacing.sm),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent:
                                  StoreCalibration.denseProductCardHeight,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
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
                            (_, _) => const SizedBox(height: StoreSpacing.sm),
                        itemBuilder:
                            (_, index) => _FavoriteCard(
                              item: controller.items[index],
                              controller: controller,
                              grid: false,
                            ),
                      ),
            );
        }
      }),
    );
  }

  Widget _refreshableState({
    required FavoritesController controller,
    required Widget child,
  }) => RefreshIndicator(
    onRefresh: controller.load,
    color: StorePalette.purple,
    child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    ),
  );
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
          rating: item.hasPublishedRating ? item.rate : null,
          reviewCount: item.hasPublishedRating ? item.reviewCount : null,
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
        rating: item.hasPublishedRating ? item.rate : null,
        reviewCount: item.hasPublishedRating ? item.reviewCount : null,
        inStock: item.available && item.purchasable,
        isFavorite: controller.contains(item.listingId),
        isInCart: shop.containsItem(item),
        media: media,
        onTap: open,
        onFavorite: favorite,
        onAddToCart: () => shop.addToCart(item),
        compact: true,
        denseGrid: true,
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
