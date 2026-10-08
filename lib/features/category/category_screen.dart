import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import '../../controller/favorites/favorites_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_cards.dart';
import '../../core/widget/favorite_feedback.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_product_layout_toggle.dart';
import '../../core/widget/store_skeletons.dart';
import '../../repository/categories/categories_repository.dart';
import '../../repository/shop/shop_repository.dart';
import 'filter_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  CategoresControllerImp get controller =>
      Get.isRegistered<CategoresControllerImp>()
          ? Get.find<CategoresControllerImp>()
          : Get.put(
            CategoresControllerImp(
              categoriesRepository: CategoriesRepository(apiClient: Get.find()),
            ),
          );

  ShopController get shopController =>
      Get.isRegistered<ShopController>()
          ? Get.find<ShopController>()
          : Get.put(
            ShopController(
              shopRepository: ShopRepository(apiClient: Get.find()),
            ),
          );

  ProductControllerImp get productController =>
      Get.isRegistered<ProductControllerImp>()
          ? Get.find<ProductControllerImp>()
          : Get.put(
            ProductControllerImp(
              categoriesRepository: CategoriesRepository(apiClient: Get.find()),
            ),
          );

  FavoritesController? get favoritesController =>
      Get.isRegistered<FavoritesController>()
          ? Get.find<FavoritesController>()
          : null;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: StorePalette.background,
      appBar: AppBar(
        backgroundColor: StorePalette.surface,
        foregroundColor: StorePalette.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'الرجوع',
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text('قائمة المنتجات'),
        titleTextStyle: StoreTypography.label.copyWith(fontSize: 14),
        actions: [
          Obx(
            () => StoreProductLayoutToggle(
              isGrid: controller.isGrid.value,
              onChanged: (value) => controller.isGrid.value = value,
            ),
          ),
          const SizedBox(width: StoreSpacing.xs),
        ],
      ),
      body: Obx(() => _body(context, controller.catalogState.value)),
    ),
  );

  Widget _body(BuildContext context, StoreViewState<List<Item>> state) {
    if (state is StoreLoading<List<Item>>) {
      return StoreProductCollectionSkeleton(isGrid: controller.isGrid.value);
    }
    if (state is StoreOffline<List<Item>>) {
      return _CatalogMessage(
        message: state.message,
        icon: Icons.wifi_off_rounded,
        onRetry: _reload,
      );
    }
    if (state is StoreError<List<Item>>) {
      return _CatalogMessage(
        message: state.message,
        icon: Icons.error_outline_rounded,
        onRetry: _reload,
      );
    }

    final products = switch (state) {
      StoreContent<List<Item>>(data: final data) => data,
      _ => controller.itemList?.rows ?? const <Item>[],
    };
    if (state is StoreEmpty<List<Item>> || products.isEmpty) {
      return _CatalogMessage(
        message: 'لا توجد منتجات في هذا القسم',
        icon: Icons.inventory_2_outlined,
        onRetry: _reload,
      );
    }

    return RefreshIndicator(
      color: StorePalette.purple,
      onRefresh: _reload,
      child: CustomScrollView(
        key: const PageStorageKey<String>('category-product-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _catalogHeader(context, products.length)),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 20),
            sliver:
                controller.isGrid.value
                    ? SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 270,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: products.length,
                      itemBuilder:
                          (context, index) => _gridProduct(products[index]),
                    )
                    : SliverList.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder:
                          (context, index) => _listProduct(products[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _listProduct(Item item) => Obx(() {
    favoritesController?.listingIds.length;
    shopController.cartLines.length;
    return StoreProductListCard(
      name: _name(item),
      price: item.normailPrice,
      originalPrice: item.oldPrice,
      discountPercent: item.discount,
      rating: item.rate,
      reviewCount: item.reviewCount,
      inStock: item.available && item.purchasable,
      isFavorite: favoritesController?.contains(item.listingId) ?? false,
      isInCart: shopController.containsItem(item),
      media: StoreNetworkMedia(
        url: _mainMedia(item),
        semanticLabel: _name(item),
        fit: BoxFit.contain,
      ),
      onTap: () => productController.getCategoryById(itemId: item.productId),
      onFavorite:
          favoritesController == null ? null : () => _requestFavorite(item),
      onAddToCart:
          item.itemSizes.isNotEmpty
              ? () => productController.getCategoryById(itemId: item.productId)
              : () => shopController.addToCart(item),
    );
  });

  Widget _gridProduct(Item item) => Obx(() {
    favoritesController?.listingIds.length;
    shopController.cartLines.length;
    return StoreProductCard(
      name: _name(item),
      price: item.normailPrice,
      originalPrice: item.oldPrice,
      discountPercent: item.discount > 0 ? item.discount : null,
      rating: item.rate,
      reviewCount: item.reviewCount,
      inStock: item.available && item.purchasable,
      isFavorite: favoritesController?.contains(item.listingId) ?? false,
      isInCart: shopController.containsItem(item),
      media: StoreNetworkMedia(
        url: _mainMedia(item),
        semanticLabel: _name(item),
        fit: BoxFit.contain,
      ),
      onTap: () => productController.getCategoryById(itemId: item.productId),
      onFavorite:
          favoritesController == null ? null : () => _requestFavorite(item),
      onAddToCart:
          item.itemSizes.isNotEmpty
              ? () => productController.getCategoryById(itemId: item.productId)
              : () => shopController.addToCart(item),
      compact: true,
    );
  });

  Future<void> _requestFavorite(Item item) async {
    final favorites = favoritesController;
    if (favorites == null) return;
    final outcome = await favorites.requestToggle(
      listingId: item.listingId,
      productId: item.productId,
    );
    showFavoriteFeedback(outcome);
  }

  Widget _catalogHeader(BuildContext context, int count) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _title,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: StoreTypography.title.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CatalogControl(
                label: 'تصفية (${controller.filters.value.activeCount})',
                icon: Icons.tune_rounded,
                emphasized: true,
                onTap: () => showProductFilterSheet(context, controller),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CatalogControl(
                label: 'ترتيب',
                icon: Icons.swap_vert_rounded,
                onTap: () => _showSort(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$count منتج',
          style: StoreTypography.caption.copyWith(
            color: StorePalette.textPrimary,
            fontWeight: StoreTypography.medium,
          ),
        ),
      ],
    ),
  );

  String get _title {
    final value = controller.titleMain?.trim();
    return value == null || value.isEmpty ? 'المنتجات' : value;
  }

  Future<void> _reload() => controller.getProductsByOnlineStoreCategory(
    controller.selectedOnlineStoreCategoryId,
    navigate: false,
  );

  Future<void> _showSort(BuildContext context) async {
    final selected = await showModalBottomSheet<CatalogSort>(
      context: context,
      backgroundColor: StorePalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder:
          (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: CatalogSort.values
                      .map(
                        (sort) => RadioListTile<CatalogSort>(
                          value: sort,
                          groupValue: controller.filters.value.sort,
                          title: Text(_sortLabel(sort)),
                          activeColor: StorePalette.purple,
                          onChanged: (value) => Navigator.pop(context, value),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ),
    );
    if (selected == null || selected == controller.filters.value.sort) return;
    final current = controller.filters.value;
    await controller.applyCatalogFilters(
      CatalogFilters(
        minimumPrice: current.minimumPrice,
        maximumPrice: current.maximumPrice,
        availableOnly: current.availableOnly,
        onSale: current.onSale,
        sort: selected,
      ),
    );
  }

  String _sortLabel(CatalogSort sort) => switch (sort) {
    CatalogSort.recommended => 'الترتيب المقترح',
    CatalogSort.newest => 'الأحدث أولاً',
    CatalogSort.priceAsc => 'السعر: من الأقل للأعلى',
    CatalogSort.priceDesc => 'السعر: من الأعلى للأقل',
    CatalogSort.name => 'الاسم',
  };
}

class _CatalogControl extends StatelessWidget {
  const _CatalogControl({
    required this.label,
    required this.icon,
    required this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor:
            emphasized ? StorePalette.purple : StorePalette.textSecondary,
        backgroundColor: StorePalette.surface,
        side: BorderSide(
          color: emphasized ? StorePalette.purple : StorePalette.border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StoreRadii.md),
        ),
        textStyle: StoreTypography.label.copyWith(fontSize: 12),
      ),
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _CatalogMessage extends StatelessWidget {
  const _CatalogMessage({
    required this.message,
    required this.icon,
    required this.onRetry,
  });
  final String message;
  final IconData icon;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(StoreSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: StorePalette.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: StoreTypography.body,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ),
  );
}

String _name(Item item) {
  final language = Get.locale?.languageCode ?? 'ar';
  return language == 'ar'
      ? item.nameAr
      : language == 'en'
      ? item.nameEng
      : item.nameAbree;
}

String? _mainMedia(Item item) {
  if (item.storefrontMedia.isEmpty) return null;
  return item.storefrontMedia
      .firstWhere(
        (media) => media.isMain,
        orElse: () => item.storefrontMedia.first,
      )
      .path;
}
