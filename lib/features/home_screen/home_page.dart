import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/ads_response.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_bottom_navigation.dart';
import '../../core/widget/store_cards.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';
import 'widget/main_categorys.dart';
import 'widget/promo.dart';

class HomePage extends StatelessWidget {
  const HomePage({this.controller, this.onAddToCart, super.key});

  final HomeControllerImp? controller;
  final ValueChanged<Item>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final homeController = controller ?? Get.find<HomeControllerImp>();
    return Obx(() {
      final categories = homeController.categoriesState.value;
      final hero = homeController.heroState.value;
      final products = homeController.productsState.value;
      final isInitial =
          categories is StoreInitial &&
          hero is StoreInitial &&
          products is StoreInitial;
      final isLoading =
          categories is StoreLoading &&
          hero is StoreLoading &&
          products is StoreLoading;

      if (isInitial || isLoading) {
        return const HomeLoadingSkeleton(key: ValueKey('home-skeleton'));
      }

      return StoreRefreshWrapper(
        onRefresh: () => homeController.loadHome(refresh: true),
        child: ListView(
          key: const PageStorageKey<String>('store-home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(
            StoreSpacing.md,
            StoreSpacing.xs,
            StoreSpacing.md,
            StoreSpacing.xl,
          ),
          children: [
            _HeroSection(state: hero, controller: homeController),
            const SizedBox(height: StoreSpacing.md),
            _CategorySection(
              title: 'storeQuickCategories'.tr,
              state: categories,
              compact: true,
              onSelected: (category) => _openCategory(category),
              onViewAll:
                  () => homeController.selectDestination(
                    StoreDestination.categories,
                  ),
            ),
            const SizedBox(height: StoreSpacing.md),
            _ProductSection(
              title: 'storeBestSellers'.tr,
              state: products,
              controller: homeController,
              onSelected: _openProduct,
              onAddToCart: onAddToCart ?? _runtimeAddToCart,
              onViewAll:
                  () => homeController.selectDestination(
                    StoreDestination.categories,
                  ),
            ),
            const SizedBox(height: StoreSpacing.md),
            _CategorySection(
              title: 'storeStoreCategories'.tr,
              state: categories,
              compact: false,
              onSelected: (category) => _openCategory(category),
              onViewAll:
                  () => homeController.selectDestination(
                    StoreDestination.categories,
                  ),
            ),
            if (homeController.specialOffers.isNotEmpty) ...[
              const SizedBox(height: StoreSpacing.md),
              _ProductSection(
                title: 'storeSpecialOffers'.tr,
                products: homeController.specialOffers,
                controller: homeController,
                onSelected: _openProduct,
                onAddToCart: onAddToCart ?? _runtimeAddToCart,
                onViewAll:
                    () => homeController.selectDestination(
                      StoreDestination.categories,
                    ),
              ),
            ],
            if (homeController.newArrivals.isNotEmpty) ...[
              const SizedBox(height: StoreSpacing.md),
              _ProductSection(
                title: 'storeNewArrivals'.tr,
                products: homeController.newArrivals,
                controller: homeController,
                onSelected: _openProduct,
                onAddToCart: onAddToCart ?? _runtimeAddToCart,
                onViewAll:
                    () => homeController.selectDestination(
                      StoreDestination.categories,
                    ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _openCategory(Category category) async {
    if (!Get.isRegistered<CategoresControllerImp>()) return;
    final controller = Get.find<CategoresControllerImp>();
    controller.mainCategoresId = category.id;
    controller.titleMain = _categoryName(
      category,
      Get.locale?.languageCode ?? 'ar',
    );
    await controller.getProductsByOnlineStoreCategory(category.id);
  }

  Future<void> _openProduct(Item item) async {
    if (!Get.isRegistered<ProductControllerImp>()) return;
    await Get.find<ProductControllerImp>().getCategoryById(itemId: item.id);
  }

  void _runtimeAddToCart(Item item) {
    if (Get.isRegistered<ShopController>()) {
      Get.find<ShopController>().addToCart(item);
    }
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.state, required this.controller});

  final StoreViewState<List<Ad>> state;
  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    if (state case StoreContent<List<Ad>>(data: final ads)) {
      if (ads.isEmpty) return const SizedBox.shrink();
      final ad = ads.first;
      return SizedBox(
        key: const ValueKey('home-hero'),
        height: StoreCalibration.homeHeroHeight,
        child: PromoCard(
          imageUrl: ad.imgUrl,
          title: ad.title,
          description: ad.description,
          buttonText: 'storeShopNow'.tr,
          onPressed: () {
            if (ad.urlAds.trim().isNotEmpty) controller.openWeb(ad.urlAds);
          },
        ),
      );
    }
    if (state case StoreLoading<List<Ad>>()) {
      return const StoreSkeletonBox(
        height: StoreCalibration.homeHeroHeight,
        borderRadius: StoreRadii.lg,
      );
    }
    // Hero/promotional content is optional and is omitted when its feed is
    // unavailable instead of inventing a local campaign.
    return const SizedBox.shrink();
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.state,
    required this.compact,
    required this.onSelected,
    required this.onViewAll,
  });

  final String title;
  final StoreViewState<List<Category>> state;
  final bool compact;
  final ValueChanged<Category> onSelected;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final categories = switch (state) {
      StoreContent<List<Category>>(data: final data) => data,
      StoreLoading<List<Category>>(previousData: final data?) => data,
      StoreOffline<List<Category>>(previousData: final data?) => data,
      StoreError<List<Category>>(previousData: final data?) => data,
      _ => const <Category>[],
    };
    if (categories.isEmpty) {
      return _SectionState(title: title, state: state);
    }

    final visible =
        compact ? categories.take(5).toList() : categories.take(8).toList();
    return Column(
      key: ValueKey(
        compact ? 'home-quick-categories' : 'home-store-categories',
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          _SectionHeader(title: title, onViewAll: onViewAll),
          const SizedBox(height: StoreSpacing.xs),
        ],
        SizedBox(
          height:
              compact
                  ? StoreCalibration.homeQuickCategoryHeight
                  : StoreCalibration.homeStoreCategoryHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (_, _) => const SizedBox(width: StoreSpacing.xs),
            itemBuilder: (context, index) {
              final category = visible[index];
              return SizedBox(
                width:
                    compact
                        ? StoreCalibration.homeQuickCategoryWidth
                        : StoreCalibration.homeStoreCategoryWidth,
                child: MainCategorys(
                  image: category.imageUrl,
                  title: _categoryName(
                    category,
                    Get.locale?.languageCode ?? 'ar',
                  ),
                  onTap: () => onSelected(category),
                  compact: compact,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  const _ProductSection({
    required this.title,
    required this.controller,
    required this.onSelected,
    required this.onAddToCart,
    required this.onViewAll,
    this.state,
    this.products,
  });

  final String title;
  final HomeControllerImp controller;
  final ValueChanged<Item> onSelected;
  final ValueChanged<Item> onAddToCart;
  final VoidCallback onViewAll;
  final StoreViewState<List<Item>>? state;
  final List<Item>? products;

  @override
  Widget build(BuildContext context) {
    final resolvedProducts =
        products ??
        switch (state) {
          StoreContent<List<Item>>(data: final data) => data,
          StoreLoading<List<Item>>(previousData: final data?) => data,
          StoreOffline<List<Item>>(previousData: final data?) => data,
          StoreError<List<Item>>(previousData: final data?) => data,
          _ => const <Item>[],
        };
    if (resolvedProducts.isEmpty) {
      return state == null
          ? const SizedBox.shrink()
          : _SectionState(title: title, state: state!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: title, onViewAll: onViewAll),
        const SizedBox(height: StoreSpacing.xs),
        SizedBox(
          height: StoreCalibration.homeProductCardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: resolvedProducts.length,
            separatorBuilder: (_, _) => const SizedBox(width: StoreSpacing.xs),
            itemBuilder: (context, index) {
              final item = resolvedProducts[index];
              return SizedBox(
                width: StoreCalibration.homeProductCardWidth,
                child: StoreProductCard(
                  name: _itemName(item, Get.locale?.languageCode ?? 'ar'),
                  price: controller.displayPriceFor(item),
                  discountPercent: item.discount > 0 ? item.discount : null,
                  rating: item.rate,
                  inStock: item.stock > 0 || item.itemSizes.isNotEmpty,
                  media: StoreNetworkMedia(
                    url: _itemImage(item),
                    semanticLabel: _itemName(
                      item,
                      Get.locale?.languageCode ?? 'ar',
                    ),
                    fit: BoxFit.contain,
                  ),
                  onTap: () => onSelected(item),
                  onAddToCart: () => onAddToCart(item),
                  compact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionState<T> extends StatelessWidget {
  const _SectionState({required this.title, required this.state});

  final String title;
  final StoreViewState<T> state;

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (state) {
      StoreOffline<T>() => (Icons.wifi_off_outlined, 'storeOfflineMessage'.tr),
      StoreError<T>() => (Icons.error_outline, 'storeHomeSectionError'.tr),
      StoreEmpty<T>() => (
        Icons.inventory_2_outlined,
        'storeNoProductsMessage'.tr,
      ),
      _ => (Icons.hourglass_empty, 'storeLoading'.tr),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: title),
        const SizedBox(height: StoreSpacing.sm),
        Container(
          height: 92,
          padding: const EdgeInsets.all(StoreSpacing.md),
          decoration: BoxDecoration(
            color: StorePalette.surface,
            border: Border.all(color: StorePalette.border),
            borderRadius: BorderRadius.circular(StoreRadii.lg),
          ),
          child: Row(
            children: [
              Icon(icon, color: StorePalette.textSecondary),
              const SizedBox(width: StoreSpacing.sm),
              Expanded(child: Text(message, style: StoreTypography.caption)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StoreTypography.title,
        ),
      ),
      if (onViewAll != null)
        TextButton.icon(
          onPressed: onViewAll,
          icon: const Icon(Icons.chevron_left, size: StoreIconSizes.small),
          label: Text('storeViewAll'.tr),
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: StoreTypography.caption,
          ),
        ),
    ],
  );
}

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(StoreSpacing.md),
    children: const [
      StoreSkeletonBox(
        height: StoreCalibration.homeHeroHeight,
        borderRadius: StoreRadii.lg,
      ),
      SizedBox(height: StoreSpacing.md),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: StoreSkeletonBox(width: 140, height: 18),
      ),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          Expanded(child: StoreSkeletonBox(height: 88)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 88)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 88)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 88)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 88)),
        ],
      ),
      SizedBox(height: StoreSpacing.md),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: StoreSkeletonBox(width: 120, height: 18),
      ),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          Expanded(child: StoreSkeletonBox(height: 220)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 220)),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: StoreSkeletonBox(height: 220)),
        ],
      ),
    ],
  );
}

String _categoryName(Category category, String languageCode) =>
    languageCode == 'ar'
        ? category.nameAr
        : languageCode == 'en'
        ? category.nameEng
        : category.nameAbree;

String _itemName(Item item, String languageCode) =>
    languageCode == 'ar'
        ? item.nameAr
        : languageCode == 'en'
        ? item.nameEng
        : item.nameAbree;

String? _itemImage(Item item) {
  if (item.viewImagesItems.isNotEmpty) {
    final value = item.viewImagesItems.first.imageUrl.trim();
    if (value.isNotEmpty) return value;
  }
  final normal = item.normalImagesItems;
  if (normal != null && normal.isNotEmpty) {
    final value = normal.first.imageUrl.trim();
    if (value.isNotEmpty) return value;
  }
  return null;
}
