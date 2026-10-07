import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import '../../controller/favorites/favorites_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/ads_response.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/model/online_store_home_model.dart';
import '../../core/helper/route_helper.dart';
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
      final configuredSections = switch (homeController
          .homeSectionsState
          .value) {
        StoreContent<List<OnlineStoreHomeSection>>(data: final data) => data,
        StoreLoading<List<OnlineStoreHomeSection>>(previousData: final data?) =>
          data,
        StoreOffline<List<OnlineStoreHomeSection>>(previousData: final data?) =>
          data,
        StoreError<List<OnlineStoreHomeSection>>(previousData: final data?) =>
          data,
        _ => const <OnlineStoreHomeSection>[],
      };
      if (homeController.isHomeColdLoading) {
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
            StoreSpacing.md,
          ),
          children: [
            if (homeController.isRefreshingHome.value) ...[
              const _HomeRefreshPanel(),
              const SizedBox(height: StoreSpacing.sm),
            ],
            ..._homeSections(
              homeController,
              configuredSections,
              hero: hero,
              categories: categories,
              products: products,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _homeSections(
    HomeControllerImp homeController,
    List<OnlineStoreHomeSection> sections, {
    required StoreViewState<List<Ad>> hero,
    required StoreViewState<List<Category>> categories,
    required StoreViewState<List<Item>> products,
  }) {
    if (sections.isNotEmpty) {
      return _configuredSections(homeController, sections);
    }

    final widgets = <Widget>[];
    void add(Widget widget) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: StoreSpacing.sm));
      }
      widgets.add(widget);
    }

    add(_HeroSection(state: hero, controller: homeController));
    add(
      _CategorySection(
        title: 'storeQuickCategories'.tr,
        state: categories,
        compact: true,
        onSelected: _openCategory,
        onViewAll:
            () => homeController.selectDestination(StoreDestination.categories),
      ),
    );
    add(
      _ProductSection(
        title: 'storeBestSellers'.tr,
        state: products,
        controller: homeController,
        onSelected: _openProduct,
        onAddToCart: onAddToCart ?? _runtimeAddToCart,
        onViewAll:
            () => homeController.selectDestination(StoreDestination.categories),
      ),
    );
    add(
      _MaintenanceSection(
        title: 'storeMaintenancePromoTitle'.tr,
        onPressed: () => Get.toNamed(RouteHelper.contactUsPage),
      ),
    );
    add(
      _CategorySection(
        title: 'storeStoreCategories'.tr,
        state: categories,
        compact: false,
        onSelected: _openCategory,
        onViewAll:
            () => homeController.selectDestination(StoreDestination.categories),
      ),
    );
    if (homeController.specialOffers.isNotEmpty) {
      add(
        _OfferSection(
          title: 'storeSpecialOffers'.tr,
          products: homeController.specialOffers,
          controller: homeController,
          onSelected: _openProduct,
          onViewAll:
              () =>
                  homeController.selectDestination(StoreDestination.categories),
        ),
      );
    }
    if (homeController.newArrivals.isNotEmpty) {
      add(
        _ProductSection(
          title: 'storeNewArrivals'.tr,
          products: homeController.newArrivals,
          controller: homeController,
          onSelected: _openProduct,
          onAddToCart: onAddToCart ?? _runtimeAddToCart,
          onViewAll:
              () =>
                  homeController.selectDestination(StoreDestination.categories),
        ),
      );
    }
    return widgets;
  }

  List<Widget> _configuredSections(
    HomeControllerImp homeController,
    List<OnlineStoreHomeSection> sections,
  ) {
    final language = Get.locale?.languageCode ?? 'ar';
    final widgets = <Widget>[];
    var categorySectionIndex = 0;

    void add(OnlineStoreHomeSection section, Widget widget) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: StoreSpacing.sm));
      }
      widgets.add(
        KeyedSubtree(
          key: ValueKey('home-admin-section-${section.id}'),
          child: widget,
        ),
      );
    }

    for (final section in sections) {
      switch (section.type) {
        case 'hero':
          if (section.banners.isNotEmpty) {
            add(
              section,
              _ConfiguredHeroSection(
                banners: section.banners,
                controller: homeController,
              ),
            );
          }
        case 'categories':
          if (section.categories.isNotEmpty) {
            final compact = categorySectionIndex++ == 0;
            add(
              section,
              _CategorySection(
                title: section.title(language),
                categories: section.categories,
                compact: compact,
                showHeader: true,
                onSelected: _openCategory,
                onViewAll:
                    () => homeController.selectDestination(
                      StoreDestination.categories,
                    ),
              ),
            );
          }
        case 'best_sellers':
        case 'recent':
        case 'custom':
          if (section.products.isNotEmpty) {
            add(
              section,
              _ProductSection(
                title: section.title(language),
                products: section.products,
                controller: homeController,
                onSelected: _openProduct,
                onAddToCart: onAddToCart ?? _runtimeAddToCart,
                onViewAll:
                    () => homeController.selectDestination(
                      StoreDestination.categories,
                    ),
              ),
            );
          }
        case 'offers':
          if (section.products.isNotEmpty) {
            add(
              section,
              _OfferSection(
                title: section.title(language),
                products: section.products,
                controller: homeController,
                onSelected: _openProduct,
                onViewAll:
                    () => homeController.selectDestination(
                      StoreDestination.categories,
                    ),
              ),
            );
          }
        case 'maintenance':
          add(
            section,
            _MaintenanceSection(
              title: section.title(language),
              onPressed: () => Get.toNamed(RouteHelper.contactUsPage),
            ),
          );
      }
    }
    return widgets;
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

class _ConfiguredHeroSection extends StatelessWidget {
  const _ConfiguredHeroSection({
    required this.banners,
    required this.controller,
  });

  final List<OnlineStoreHomeBanner> banners;
  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();
    final language = Get.locale?.languageCode ?? 'ar';
    return SizedBox(
      key: const ValueKey('home-configured-hero'),
      height: StoreCalibration.homeHeroHeight,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: banners.length,
            onPageChanged: (index) => controller.currentPage.value = index,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return PromoCard(
                imageUrl: banner.imagePath,
                title: banner.title(language),
                description: banner.content(language),
                buttonText: 'storeShopNow'.tr,
                onPressed: () {
                  if (banner.actionType == 'url' &&
                      banner.actionUrl?.trim().isNotEmpty == true) {
                    controller.openWeb(banner.actionUrl!);
                  }
                },
              );
            },
          ),
          if (banners.length > 1)
            PositionedDirectional(
              bottom: StoreSpacing.xs,
              start: 0,
              end: 0,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) => AnimatedContainer(
                      duration: StoreMotion.fast,
                      width: controller.currentPage.value == index ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color:
                            controller.currentPage.value == index
                                ? StorePalette.purple
                                : StorePalette.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(StoreRadii.round),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MaintenanceSection extends StatelessWidget {
  const _MaintenanceSection({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('home-maintenance-banner'),
    height: 112,
    child: Material(
      color: const Color(0xFFFFF0CF),
      borderRadius: BorderRadius.circular(StoreRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              width: 132,
              child: Image.asset(
                'assets/images/splash3.png',
                fit: BoxFit.contain,
                alignment: Alignment.center,
                cacheWidth: 264,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.68,
                child: Padding(
                  padding: const EdgeInsets.all(StoreSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.title.copyWith(fontSize: 16),
                      ),
                      Text(
                        'storeMaintenancePromoBody'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.caption,
                      ),
                      const SizedBox(height: StoreSpacing.xs),
                      FilledButton.tonalIcon(
                        onPressed: onPressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: StorePalette.surface,
                          foregroundColor: StorePalette.purple,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: StoreSpacing.sm,
                          ),
                        ),
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: Text('storeBookNow'.tr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
    required this.compact,
    required this.onSelected,
    required this.onViewAll,
    this.showHeader = false,
    this.state,
    this.categories,
  });

  final String title;
  final StoreViewState<List<Category>>? state;
  final List<Category>? categories;
  final bool compact;
  final bool showHeader;
  final ValueChanged<Category> onSelected;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final resolvedCategories =
        categories ??
        switch (state) {
          StoreContent<List<Category>>(data: final data) => data,
          StoreLoading<List<Category>>(previousData: final data?) => data,
          StoreOffline<List<Category>>(previousData: final data?) => data,
          StoreError<List<Category>>(previousData: final data?) => data,
          _ => const <Category>[],
        };
    if (resolvedCategories.isEmpty) {
      return state == null
          ? const SizedBox.shrink()
          : _SectionState(title: title, state: state!);
    }

    final visible =
        compact
            ? resolvedCategories.take(5).toList()
            : resolvedCategories.take(8).toList();
    return Column(
      key: ValueKey(
        compact ? 'home-quick-categories' : 'home-store-categories',
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader || !compact) ...[
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
              final favorites =
                  Get.isRegistered<FavoritesController>()
                      ? Get.find<FavoritesController>()
                      : null;
              final shop =
                  Get.isRegistered<ShopController>()
                      ? Get.find<ShopController>()
                      : null;
              Widget card() => StoreProductCard(
                name: _itemName(item, Get.locale?.languageCode ?? 'ar'),
                price: controller.displayPriceFor(item),
                discountPercent: item.discount > 0 ? item.discount : null,
                rating: item.rate > 0 ? item.rate : null,
                inStock: item.available && item.purchasable,
                isFavorite: favorites?.contains(item.listingId) ?? false,
                isInCart: shop?.containsItem(item) ?? false,
                media: StoreNetworkMedia(
                  url: _itemImage(item),
                  semanticLabel: _itemName(
                    item,
                    Get.locale?.languageCode ?? 'ar',
                  ),
                  fit: BoxFit.contain,
                ),
                onTap: () => onSelected(item),
                onFavorite: () => _requestFavorite(item),
                onAddToCart: () => onAddToCart(item),
                compact: true,
                homePresentation: true,
              );
              return SizedBox(
                width: StoreCalibration.homeProductCardWidth,
                child:
                    favorites == null && shop == null
                        ? card()
                        : Obx(() {
                          favorites?.listingIds.length;
                          shop?.cartLines.length;
                          return card();
                        }),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OfferSection extends StatelessWidget {
  const _OfferSection({
    required this.title,
    required this.products,
    required this.controller,
    required this.onSelected,
    required this.onViewAll,
  });

  final String title;
  final List<Item> products;
  final HomeControllerImp controller;
  final ValueChanged<Item> onSelected;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('home-special-offers'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionHeader(title: title, onViewAll: onViewAll),
      const SizedBox(height: StoreSpacing.xs),
      SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: StoreSpacing.xs),
          itemBuilder: (context, index) {
            final item = products[index];
            return SizedBox(
              width: 208,
              child: Material(
                color:
                    index.isEven
                        ? StorePalette.purple
                        : const Color(0xFF39C7A3),
                borderRadius: BorderRadius.circular(StoreRadii.md),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelected(item),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PositionedDirectional(
                        end: 0,
                        top: 0,
                        bottom: 0,
                        width: 92,
                        child: StoreNetworkMedia(
                          url: _itemImage(item),
                          semanticLabel: _itemName(
                            item,
                            Get.locale?.languageCode ?? 'ar',
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SizedBox(
                          width: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(StoreSpacing.sm),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.discount > 0)
                                  Text(
                                    '${item.discount.toStringAsFixed(item.discount % 1 == 0 ? 0 : 1)}% ${'storeDiscount'.tr}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: StoreTypography.title.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                Text(
                                  _itemName(
                                    item,
                                    Get.locale?.languageCode ?? 'ar',
                                  ),
                                  maxLines: item.discount > 0 ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: StoreTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: StoreTypography.medium,
                                  ),
                                ),
                                if (item.discount <= 0)
                                  Text(
                                    '${controller.displayPriceFor(item)} ₪',
                                    style: StoreTypography.label.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

class _HomeRefreshPanel extends StatelessWidget {
  const _HomeRefreshPanel();

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'storeRefreshingHome'.tr,
    child: Container(
      key: const ValueKey('home-refresh-panel'),
      height: 88,
      decoration: BoxDecoration(
        color: StorePalette.lightPurple.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: StorePalette.purple,
            ),
          ),
          const SizedBox(height: StoreSpacing.xs),
          Text(
            'storeRefreshingHome'.tr,
            style: StoreTypography.body.copyWith(
              color: StorePalette.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
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
    padding: const EdgeInsetsDirectional.fromSTEB(
      StoreSpacing.md,
      StoreSpacing.xs,
      StoreSpacing.md,
      StoreSpacing.md,
    ),
    children: const [
      StoreSkeletonBox(
        height: StoreCalibration.homeHeroHeight,
        borderRadius: StoreRadii.lg,
      ),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          Expanded(child: _HomeCategorySkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeCategorySkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeCategorySkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeCategorySkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeCategorySkeleton()),
        ],
      ),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          StoreSkeletonBox(width: 116, height: 18),
          Spacer(),
          StoreSkeletonBox(width: 64, height: 14),
        ],
      ),
      SizedBox(height: StoreSpacing.sm),
      Row(
        children: [
          Expanded(child: _HomeProductSkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeProductSkeleton()),
          SizedBox(width: StoreSpacing.xs),
          Expanded(child: _HomeProductSkeleton()),
        ],
      ),
      SizedBox(height: StoreSpacing.sm),
      StoreSkeletonBox(height: 112, borderRadius: StoreRadii.lg),
    ],
  );
}

class _HomeCategorySkeleton extends StatelessWidget {
  const _HomeCategorySkeleton();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const StoreSkeletonBox(height: 54, borderRadius: StoreRadii.md),
      const SizedBox(height: StoreSpacing.xxs),
      Center(child: StoreSkeletonBox(width: 42, height: 9)),
    ],
  );
}

class _HomeProductSkeleton extends StatelessWidget {
  const _HomeProductSkeleton();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: StoreCalibration.homeProductCardHeight,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: StorePalette.surface,
        border: Border.all(color: StorePalette.border),
        borderRadius: BorderRadius.circular(StoreRadii.lg),
      ),
      child: const Padding(
        padding: EdgeInsets.all(StoreSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: StoreSkeletonBox(borderRadius: StoreRadii.md)),
            SizedBox(height: StoreSpacing.xs),
            StoreSkeletonBox(height: 11),
            SizedBox(height: StoreSpacing.xxs),
            StoreSkeletonBox(width: 64, height: 9),
            SizedBox(height: StoreSpacing.xs),
            StoreSkeletonBox(
              height: StoreCalibration.compactControlHeight,
              borderRadius: StoreRadii.sm,
            ),
          ],
        ),
      ),
    ),
  );
}

String _categoryName(Category category, String languageCode) =>
    languageCode == 'ar'
        ? category.nameAr
        : languageCode == 'en'
        ? category.nameEng
        : category.nameAbree;

Future<void> _requestFavorite(Item item) async {
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
