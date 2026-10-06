import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home/home_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_chips.dart';
import '../../core/widget/store_fields.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({
    this.controller,
    this.showSearchField = true,
    this.onAddToCart,
    super.key,
  });

  final HomeControllerImp? controller;
  final bool showSearchField;
  final ValueChanged<Item>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final searchController = controller ?? Get.find<HomeControllerImp>();
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSearchField)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              StoreSpacing.md,
              StoreSpacing.sm,
              StoreSpacing.md,
              StoreSpacing.xs,
            ),
            child: StoreTextField(
              controller: searchController.search,
              hint: 'storeSearchHint'.tr,
              semanticLabel: 'storeSearchField'.tr,
              prefixIcon: Icons.search,
              suffixIcon: IconButton(
                tooltip: 'storeCloseSearch'.tr,
                onPressed: () {
                  searchController.search.clear();
                  searchController.submitSearch('');
                },
                icon: const Icon(Icons.close),
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  searchController.submitSearch('');
                }
              },
              onSubmitted: searchController.submitSearch,
            ),
          ),
        Expanded(
          child: Obx(
            () => _SearchBody(
              controller: searchController,
              state: searchController.searchState.value,
              recentSearches: searchController.recentSearches.toList(),
              categories: searchController.mainCategoresModel.toList(),
              onAddToCart: onAddToCart,
            ),
          ),
        ),
      ],
    );

    if (!showSearchField) return content;
    return Scaffold(
      appBar: AppBar(title: Text('storeSearchTitle'.tr)),
      body: SafeArea(top: false, child: content),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.controller,
    required this.state,
    required this.recentSearches,
    required this.categories,
    this.onAddToCart,
  });

  final HomeControllerImp controller;
  final StoreViewState<List<Item>> state;
  final List<String> recentSearches;
  final List<Category> categories;
  final ValueChanged<Item>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is StoreInitial<List<Item>>) {
      return _SearchDiscovery(
        controller: controller,
        recentSearches: recentSearches,
        categories: categories,
      );
    }
    if (current is StoreLoading<List<Item>>) {
      return const _SearchLoading();
    }
    if (current is StoreContent<List<Item>>) {
      return _SearchResults(
        controller: controller,
        products: current.data,
        onAddToCart: onAddToCart,
      );
    }
    if (current is StoreEmpty<List<Item>>) {
      return StoreMessageState(
        kind: StoreMessageKind.empty,
        icon: Icons.search_off_rounded,
        iconColor: StorePalette.purple,
        iconSize: 64,
        title: current.title,
        message: current.message,
        actionLabel: 'storeSearchAgain'.tr,
        actionVariant: StoreButtonVariant.primary,
        actionExpanded: true,
        onAction: () {
          controller.search.clear();
          controller.submitSearch('');
        },
      );
    }
    return StoreStateView<List<Item>>(
      state: current,
      contentBuilder:
          (_, products) => _SearchResults(
            controller: controller,
            products: products,
            onAddToCart: onAddToCart,
          ),
      onRetry: controller.retrySearch,
    );
  }
}

class _SearchDiscovery extends StatelessWidget {
  const _SearchDiscovery({
    required this.controller,
    required this.recentSearches,
    required this.categories,
  });

  final HomeControllerImp controller;
  final List<String> recentSearches;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.take(5).toList();
    return ListView(
      key: const ValueKey('search-discovery'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(StoreSpacing.md),
      children: [
        if (visibleCategories.isNotEmpty) ...[
          Text('storeSearchCategories'.tr, style: StoreTypography.title),
          const SizedBox(height: StoreSpacing.sm),
          SizedBox(
            height: StoreCalibration.compactControlHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visibleCategories.length + 1,
              separatorBuilder:
                  (_, _) => const SizedBox(width: StoreSpacing.xs),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return StoreFilterChip(
                    label: 'all'.tr,
                    selected: true,
                    compact: true,
                    onSelected: (_) {},
                  );
                }
                final category = visibleCategories[index - 1];
                return StoreFilterChip(
                  label: _categoryName(category),
                  selected: false,
                  compact: true,
                  onSelected:
                      (_) => controller.selectRecentSearch(
                        _categoryName(category),
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: StoreSpacing.lg),
        ],
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'storeRecentSearches'.tr,
                  style: StoreTypography.title,
                ),
              ),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: Text('storeClearAll'.tr),
              ),
            ],
          ),
          const SizedBox(height: StoreSpacing.xs),
          ...recentSearches.map(
            (query) => InkWell(
              onTap: () => controller.selectRecentSearch(query),
              borderRadius: BorderRadius.circular(StoreRadii.sm),
              child: SizedBox(
                height: StoreCalibration.compactControlHeight,
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: StoreIconSizes.small,
                      color: StorePalette.textSecondary,
                    ),
                    const SizedBox(width: StoreSpacing.sm),
                    Expanded(
                      child: Text(query, style: StoreTypography.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else
          StoreMessageState(
            kind: StoreMessageKind.empty,
            title: 'storeSearchStartTitle'.tr,
            message: 'storeSearchStartMessage'.tr,
          ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.controller,
    required this.products,
    this.onAddToCart,
  });

  final HomeControllerImp controller;
  final List<Item> products;
  final ValueChanged<Item>? onAddToCart;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('search-results'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
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
            Expanded(
              child: Text(
                'storeSearchResultsCount'.trParams({
                  'count': '${products.length}',
                }),
                style: StoreTypography.title,
              ),
            ),
            Semantics(
              label: 'storeSortUnavailable'.tr,
              button: true,
              enabled: false,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.sort),
                label: Text('storeSort'.tr),
              ),
            ),
            const SizedBox(width: StoreSpacing.xs),
            Semantics(
              label: 'storeFilterUnavailable'.tr,
              button: true,
              enabled: false,
              child: OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.tune),
                label: Text('storeFilter'.tr),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: controller.retrySearch,
          color: StorePalette.purple,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(StoreSpacing.md),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: StoreSpacing.sm),
            itemBuilder: (context, index) {
              final item = products[index];
              return _SearchResultCard(
                item: item,
                price: controller.displayPriceFor(item),
                onTap: () => _openProduct(item),
                onAddToCart:
                    () => (onAddToCart ?? _runtimeAddToCart).call(item),
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.item,
    required this.price,
    required this.onTap,
    required this.onAddToCart,
  });

  final Item item;
  final num price;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final inStock = item.stock > 0 || item.itemSizes.isNotEmpty;
    return SizedBox(
      height: StoreCalibration.searchResultCardHeight,
      child: Material(
        color: StorePalette.surface,
        borderRadius: BorderRadius.circular(StoreRadii.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: StorePalette.border),
              borderRadius: BorderRadius.circular(StoreRadii.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(StoreSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (item.discount > 0)
                              StoreDiscountChip(percent: item.discount)
                            else
                              StoreAvailabilityChip(inStock: inStock),
                            const Spacer(),
                            StoreRating(value: item.rate),
                          ],
                        ),
                        const SizedBox(height: StoreSpacing.xxs),
                        Text(
                          _itemName(item),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: StoreTypography.label,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$price ₪',
                                style: StoreTypography.title.copyWith(
                                  color: StorePalette.navy,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: StoreCalibration.compactControlHeight,
                              child: FilledButton(
                                onPressed: inStock ? onAddToCart : null,
                                style: FilledButton.styleFrom(
                                  backgroundColor: StorePalette.purple,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: StoreSpacing.sm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      StoreRadii.sm,
                                    ),
                                  ),
                                ),
                                child: Text('storeAddToCart'.tr),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 116,
                  child: StoreNetworkMedia(
                    url: _itemImage(item),
                    semanticLabel: _itemName(item),
                    fit: BoxFit.contain,
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

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    key: ValueKey('search-loading'),
    padding: EdgeInsets.all(StoreSpacing.md),
    child: Column(
      children: [
        StoreSkeletonBox(width: 180, height: 18),
        SizedBox(height: StoreSpacing.md),
        Expanded(child: StoreSkeletonList(itemCount: 5)),
      ],
    ),
  );
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

String _categoryName(Category category) {
  final language = Get.locale?.languageCode ?? 'ar';
  return language == 'ar'
      ? category.nameAr
      : language == 'en'
      ? category.nameEng
      : category.nameAbree;
}

String _itemName(Item item) {
  final language = Get.locale?.languageCode ?? 'ar';
  return language == 'ar'
      ? item.nameAr
      : language == 'en'
      ? item.nameEng
      : item.nameAbree;
}

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
