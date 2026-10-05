import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/home/home_controller.dart';
import '../../controller/product/product_controller.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_cards.dart';
import '../../core/widget/store_fields.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({this.controller, this.showSearchField = true, super.key});

  final HomeControllerImp? controller;
  final bool showSearchField;

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
  });

  final HomeControllerImp controller;
  final StoreViewState<List<Item>> state;
  final List<String> recentSearches;
  final List<Category> categories;

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
      return _SearchResults(controller: controller, products: current.data);
    }
    return StoreStateView<List<Item>>(
      state: current,
      contentBuilder:
          (_, products) =>
              _SearchResults(controller: controller, products: products),
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
          Wrap(
            spacing: StoreSpacing.xs,
            runSpacing: StoreSpacing.xs,
            children: visibleCategories
                .map(
                  (category) => ActionChip(
                    label: Text(_categoryName(category)),
                    onPressed:
                        () => controller.selectRecentSearch(
                          _categoryName(category),
                        ),
                  ),
                )
                .toList(growable: false),
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
            (query) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(query),
              trailing: const Icon(Icons.north_west, size: 18),
              onTap: () => controller.selectRecentSearch(query),
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
  const _SearchResults({required this.controller, required this.products});

  final HomeControllerImp controller;
  final List<Item> products;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 370 ? 1 : 2;
              return GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(StoreSpacing.md),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: StoreSpacing.sm,
                  mainAxisSpacing: StoreSpacing.sm,
                  mainAxisExtent: 292,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  return StoreProductCard(
                    name: _itemName(item),
                    price:
                        controller.token == null || controller.isNormail
                            ? item.normailPrice
                            : item.wholesalePrice,
                    originalPrice: item.discount > 0 ? item.normailPrice : null,
                    discountPercent: item.discount > 0 ? item.discount : null,
                    rating: item.rate,
                    inStock: item.stock > 0 || item.itemSizes.isNotEmpty,
                    media: StoreNetworkMedia(
                      url: _itemImage(item),
                      semanticLabel: _itemName(item),
                      fit: BoxFit.contain,
                    ),
                    onTap: () => _openProduct(item),
                  );
                },
              );
            },
          ),
        ),
      ),
    ],
  );
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
