import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../controller/categores/categores_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_navigation_icons.dart';
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
          icon: Icon(storeBackIcon(context), size: 19),
        ),
        title: const Text('قائمة المنتجات'),
        titleTextStyle: StoreTypography.label.copyWith(fontSize: 14),
      ),
      body: Obx(() => _body(context, controller.catalogState.value)),
    ),
  );

  Widget _body(BuildContext context, StoreViewState<List<Item>> state) {
    if (state is StoreLoading<List<Item>>) {
      return const Center(child: CircularProgressIndicator());
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
            sliver: SliverList.separated(
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder:
                  (context, index) => Obx(
                    () => _ProductListCard(
                      item: products[index],
                      isInCart: shopController.containsItem(products[index]),
                      requiresOptions: products[index].itemSizes.isNotEmpty,
                      onOpen:
                          () => productController.getCategoryById(
                            itemId: products[index].productId,
                          ),
                      onAdd:
                          products[index].itemSizes.isNotEmpty
                              ? () => productController.getCategoryById(
                                itemId: products[index].productId,
                              )
                              : () => shopController.addToCart(products[index]),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
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

class _ProductListCard extends StatelessWidget {
  const _ProductListCard({
    required this.item,
    required this.requiresOptions,
    required this.onOpen,
    required this.onAdd,
    required this.isInCart,
  });

  final Item item;
  final bool requiresOptions;
  final VoidCallback onOpen;
  final VoidCallback onAdd;
  final bool isInCart;

  @override
  Widget build(BuildContext context) {
    final discount = item.discount.clamp(0, 100);
    final hasDiscount = discount > 0;
    final currentPrice =
        item.normailPrice * (1 - (hasDiscount ? discount / 100 : 0));
    return SizedBox(
      height: 184,
      child: Material(
        color: StorePalette.surface,
        borderRadius: BorderRadius.circular(StoreRadii.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: StorePalette.border),
              borderRadius: BorderRadius.circular(StoreRadii.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 118,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      StoreNetworkMedia(
                        url: _mainMedia(item),
                        semanticLabel: _name(item),
                        fit: BoxFit.contain,
                      ),
                      if (hasDiscount)
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: StorePalette.error,
                              borderRadius: BorderRadius.circular(
                                StoreRadii.sm,
                              ),
                            ),
                            child: Text(
                              'خصم ${_number(discount)}%',
                              style: StoreTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: StoreTypography.semiBold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _AvailabilityBadge(available: item.available),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _name(item),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StoreTypography.bodyMedium.copyWith(
                          height: 1.35,
                        ),
                      ),
                      if (item.model.trim().isNotEmpty)
                        Text(
                          'موديل ${item.model}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.caption,
                        ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${_price(currentPrice)} ₪',
                            style: StoreTypography.title.copyWith(
                              color: StorePalette.navy,
                              fontSize: 16,
                            ),
                          ),
                          if (hasDiscount)
                            Text(
                              '${_price(item.normailPrice)} ₪',
                              style: StoreTypography.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: FilledButton(
                          onPressed: item.purchasable ? onAdd : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: StorePalette.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                StoreRadii.sm,
                              ),
                            ),
                            textStyle: StoreTypography.label.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          child: Text(
                            requiresOptions
                                ? 'اختر الخيارات'
                                : isInCart
                                ? 'تمت الإضافة للسلة'
                                : 'أضف للسلة',
                          ),
                        ),
                      ),
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

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});
  final bool available;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color:
          available
              ? StorePalette.derivedSuccessSurface
              : StorePalette.derivedErrorSurface,
      borderRadius: BorderRadius.circular(StoreRadii.pill),
    ),
    child: Text(
      available ? 'متوفر' : 'غير متوفر',
      style: StoreTypography.caption.copyWith(
        color: available ? StorePalette.success : StorePalette.error,
        fontSize: 10,
        fontWeight: StoreTypography.semiBold,
      ),
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

String _number(num value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

String _price(num value) =>
    intl.NumberFormat('#,##0.##', 'en_US').format(value);
