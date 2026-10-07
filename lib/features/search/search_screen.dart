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
import '../../core/widget/store_cards.dart';
import '../../core/widget/store_chips.dart';
import '../../core/widget/store_fields.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_product_layout_toggle.dart';
import '../../core/widget/store_states.dart';

class SearchScreen extends StatefulWidget {
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
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isGrid = false;

  @override
  Widget build(BuildContext context) {
    final searchController = widget.controller ?? Get.find<HomeControllerImp>();
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSearchField)
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
              onChanged: searchController.searchAsYouType,
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
              onAddToCart: widget.onAddToCart,
              isGrid: _isGrid,
              onLayoutChanged: (value) => setState(() => _isGrid = value),
            ),
          ),
        ),
      ],
    );

    if (!widget.showSearchField) return content;
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
    required this.isGrid,
    required this.onLayoutChanged,
    this.onAddToCart,
  });

  final HomeControllerImp controller;
  final StoreViewState<List<Item>> state;
  final List<String> recentSearches;
  final List<Category> categories;
  final bool isGrid;
  final ValueChanged<bool> onLayoutChanged;
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
        isGrid: isGrid,
        onLayoutChanged: onLayoutChanged,
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
            isGrid: isGrid,
            onLayoutChanged: onLayoutChanged,
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
    final visibleCategories = categories.take(4).toList();
    return ListView(
      key: const ValueKey('search-discovery'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsetsDirectional.fromSTEB(
        StoreSpacing.md,
        StoreSpacing.xs,
        StoreSpacing.md,
        StoreSpacing.md,
      ),
      children: [
        if (visibleCategories.isNotEmpty) ...[
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
                    solidSelected: true,
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
          const SizedBox(height: StoreSpacing.sm),
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
                height: 36,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(query, style: StoreTypography.bodyMedium),
                    ),
                    const SizedBox(width: StoreSpacing.sm),
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: StoreIconSizes.small,
                      color: StorePalette.textSecondary,
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
    required this.isGrid,
    required this.onLayoutChanged,
    this.onAddToCart,
  });

  final HomeControllerImp controller;
  final List<Item> products;
  final bool isGrid;
  final ValueChanged<bool> onLayoutChanged;
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
            StoreProductLayoutToggle(
              isGrid: isGrid,
              onChanged: onLayoutChanged,
            ),
          ],
        ),
      ),
      SizedBox(
        height: 38,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.md),
          scrollDirection: Axis.horizontal,
          itemCount: products.take(6).length,
          separatorBuilder: (_, _) => const SizedBox(width: StoreSpacing.xs),
          itemBuilder: (_, index) {
            final item = products[index];
            return ActionChip(
              avatar: const Icon(Icons.north_west_rounded, size: 15),
              label: Text(
                _itemName(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () => _openProduct(item),
            );
          },
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: controller.retrySearch,
          color: StorePalette.purple,
          child:
              isGrid
                  ? GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(StoreSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 260,
                          crossAxisSpacing: StoreSpacing.sm,
                          mainAxisSpacing: StoreSpacing.sm,
                        ),
                    itemCount: products.length,
                    itemBuilder:
                        (_, index) => _SearchProductCard(
                          item: products[index],
                          price: controller.displayPriceFor(products[index]),
                          grid: true,
                          onAddToCart: onAddToCart,
                        ),
                  )
                  : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(StoreSpacing.md),
                    itemCount: products.length,
                    separatorBuilder:
                        (_, _) => const SizedBox(height: StoreSpacing.sm),
                    itemBuilder:
                        (_, index) => _SearchProductCard(
                          item: products[index],
                          price: controller.displayPriceFor(products[index]),
                          grid: false,
                          onAddToCart: onAddToCart,
                        ),
                  ),
        ),
      ),
    ],
  );
}

class _SearchProductCard extends StatelessWidget {
  const _SearchProductCard({
    required this.item,
    required this.price,
    required this.grid,
    this.onAddToCart,
  });

  final Item item;
  final num price;
  final bool grid;
  final ValueChanged<Item>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final shop =
        Get.isRegistered<ShopController>() ? Get.find<ShopController>() : null;
    Widget card() {
      final inCart = shop?.containsItem(item) ?? false;
      final media = StoreNetworkMedia(
        url: _itemImage(item),
        semanticLabel: _itemName(item),
        fit: BoxFit.contain,
      );
      void add() => (onAddToCart ?? _runtimeAddToCart).call(item);
      if (!grid) {
        return StoreProductListCard(
          name: _itemName(item),
          price: price,
          originalPrice: item.oldPrice,
          inStock: item.available && item.purchasable,
          isInCart: inCart,
          media: media,
          onTap: () => _openProduct(item),
          onAddToCart: add,
        );
      }
      return StoreProductCard(
        name: _itemName(item),
        price: price,
        originalPrice: item.oldPrice,
        discountPercent: item.discount > 0 ? item.discount : null,
        inStock: item.available && item.purchasable,
        isInCart: inCart,
        media: media,
        onTap: () => _openProduct(item),
        onAddToCart: add,
        compact: true,
      );
    }

    if (shop == null) return card();
    return Obx(() {
      shop.cartLines.length;
      return card();
    });
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
