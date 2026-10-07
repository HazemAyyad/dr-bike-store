import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/categores/categores_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../controller/order/order_controller.dart';
import '../../controller/notification/notification_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_bottom_navigation.dart';
import '../../core/widget/store_media.dart';
import '../../core/widget/store_states.dart';
import '../../core/widget/store_top_bar.dart';
import '../acount/profile_screen.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../shop/shop_car_screen.dart';
import '../order/order_screen.dart';
import 'home_page.dart';
import 'widget/main_categorys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.controller,
    this.destinationPages,
    this.loadOnStart = true,
    this.onAddToCart,
    super.key,
  });

  final HomeControllerImp? controller;
  final Map<StoreDestination, Widget>? destinationPages;
  final bool loadOnStart;
  final ValueChanged<Item>? onAddToCart;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeControllerImp controller =
      widget.controller ?? Get.find<HomeControllerImp>();
  late final List<Widget> _pages = StoreDestination.values
      .map(
        (destination) =>
            widget.destinationPages?[destination] ?? _defaultPage(destination),
      )
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.initializeShell();
      if (widget.loadOnStart) await controller.loadHome();
    });
  }

  Widget _defaultPage(StoreDestination destination) => switch (destination) {
    StoreDestination.home => HomePage(
      controller: controller,
      onAddToCart: widget.onAddToCart,
    ),
    StoreDestination.categories => _CategoriesDestination(
      controller: controller,
      onBack: () => _selectDestination(StoreDestination.home),
    ),
    StoreDestination.orders => const OrderScreen(embedded: true),
    StoreDestination.favorites => const FavoritesScreen(),
    StoreDestination.profile => ProfileScreen(),
  };

  Future<void> _selectDestination(StoreDestination destination) async {
    final outcome = await controller.selectDestination(destination);
    if (!mounted) return;
    if (outcome == ShellNavigationOutcome.loginRequired) {
      await Get.toNamed(RouteHelper.intoLog);
      return;
    }
    if (destination == StoreDestination.orders &&
        Get.isRegistered<OrderController>()) {
      await Get.find<OrderController>().load();
    }
  }

  void _addToCart(Item item) {
    if (widget.onAddToCart case final callback?) {
      callback(item);
    } else if (Get.isRegistered<ShopController>()) {
      Get.find<ShopController>().addToCart(item);
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final current = controller.selectedDestination.value;
    final cartCount =
        Get.isRegistered<ShopController>()
            ? Get.find<ShopController>().cartItems.length
            : 0;
    return WillPopScope(
      onWillPop: () async => !(await controller.handleShellBack()),
      child: Scaffold(
        backgroundColor: StorePalette.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (current != StoreDestination.categories ||
                  widget.destinationPages?[StoreDestination.categories] != null)
                StoreTopBar(
                  loading:
                      current == StoreDestination.home &&
                      !controller.isSearchExpanded.value &&
                      controller.isHomeColdLoading,
                  displayName:
                      controller.displayName.value.isEmpty
                          ? 'storeGuest'.tr
                          : controller.displayName.value,
                  notificationCount:
                      Get.isRegistered<NotificationController>()
                          ? _notificationCount(
                            Get.find<NotificationController>(),
                          )
                          : controller.notificationBadgeCount,
                  cartCount: cartCount == 0 ? null : cartCount,
                  searchExpanded: controller.isSearchExpanded.value,
                  searchController: controller.search,
                  onSearchExpandedChanged: controller.setSearchExpanded,
                  onSearchChanged: (value) {
                    if (value.trim().isEmpty) controller.submitSearch('');
                  },
                  onSearch: controller.submitSearch,
                  onNotifications: () async {
                    if (!controller.isAuthenticated) {
                      await Get.toNamed(RouteHelper.intoLog);
                    } else {
                      await Get.toNamed(RouteHelper.notificationScreen);
                      if (Get.isRegistered<NotificationController>()) {
                        await Get.find<NotificationController>().load(
                          refresh: true,
                        );
                      }
                    }
                  },
                  onCart: () => Get.to(() => const ShopCarScreen()),
                ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IndexedStack(
                        key: const ValueKey('store-shell-pages'),
                        index: current.index,
                        children: _pages,
                      ),
                    ),
                    if (controller.isSearchExpanded.value)
                      Positioned.fill(
                        child: ColoredBox(
                          color: StorePalette.background,
                          child: SearchScreen(
                            controller: controller,
                            showSearchField: false,
                            onAddToCart: _addToCart,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: StoreBottomNavigation(
          current: current,
          onSelected: _selectDestination,
        ),
      ),
    );
  });
}

class _CategoriesDestination extends StatefulWidget {
  const _CategoriesDestination({
    required this.controller,
    required this.onBack,
  });

  final HomeControllerImp controller;
  final VoidCallback onBack;

  @override
  State<_CategoriesDestination> createState() => _CategoriesDestinationState();
}

class _CategoriesDestinationState extends State<_CategoriesDestination> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final state = widget.controller.categoriesState.value;
    return StoreStateView<List<Category>>(
      state: state,
      loading: const HomeLoadingSkeleton(),
      onRetry: widget.controller.getMainCategores,
      contentBuilder: (context, categories) {
        final roots = categories
            .where((category) => _matchesCategory(category, _query))
            .toList(growable: false);
        final descendants = _flattenDescendants(categories)
            .where((category) => _matchesCategory(category, _query))
            .toList(growable: false);
        return RefreshIndicator(
          onRefresh: widget.controller.getMainCategores,
          color: StorePalette.purple,
          child: CustomScrollView(
            key: const PageStorageKey<String>('store-categories-scroll'),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              if (roots.isEmpty && descendants.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'لا توجد أقسام مطابقة',
                      style: StoreTypography.body.copyWith(
                        color: StorePalette.textSecondary,
                      ),
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 12),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: StoreSpacing.xs,
                          mainAxisSpacing: StoreSpacing.xs,
                          mainAxisExtent: 92,
                        ),
                    itemCount: roots.length,
                    itemBuilder: (context, index) {
                      final category = roots[index];
                      return MainCategorys(
                        image: category.imageUrl,
                        title: _categoryName(category),
                        compact: true,
                        onTap: () => _openCategory(category),
                      );
                    },
                  ),
                ),
                if (descendants.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        4,
                        16,
                        8,
                      ),
                      child: Text(
                        'أقسام فرعية',
                        style: StoreTypography.title.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      0,
                      16,
                      20,
                    ),
                    sliver: SliverList.separated(
                      itemCount: descendants.length,
                      separatorBuilder:
                          (_, _) => const Divider(
                            height: 1,
                            color: StorePalette.border,
                          ),
                      itemBuilder:
                          (context, index) =>
                              _subcategoryRow(descendants[index]),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  });

  Widget _header(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 12),
    child: Column(
      children: [
        SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('الأقسام', style: StoreTypography.title),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  tooltip: 'الرجوع',
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 19),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: StoreSpacing.xs),
          child: SizedBox(
            height: StoreCalibration.compactControlHeight,
            child: TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value.trim()),
              textInputAction: TextInputAction.search,
              style: StoreTypography.body,
              decoration: InputDecoration(
                hintText: 'ابحث عن قسم...',
                hintStyle: StoreTypography.caption,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _query.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'مسح البحث',
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                filled: true,
                fillColor: StorePalette.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(StoreRadii.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _subcategoryRow(Category category) => Material(
    color: StorePalette.surface,
    child: InkWell(
      onTap: () => _openCategory(category),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 42,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: StoreNetworkMedia(
                  url: category.imageUrl,
                  semanticLabel: _categoryName(category),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: StoreSpacing.xs),
            Expanded(
              child: Text(
                _categoryName(category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StoreTypography.bodyMedium,
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: StorePalette.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _openCategory(Category category) async {
    if (!Get.isRegistered<CategoresControllerImp>()) return;
    final categoriesController = Get.find<CategoresControllerImp>();
    categoriesController.mainCategoresId = category.id;
    categoriesController.titleMain = _categoryName(category);
    await categoriesController.getProductsByOnlineStoreCategory(category.id);
  }
}

int? _notificationCount(NotificationController controller) =>
    controller.unreadCount == 0 ? null : controller.unreadCount;

List<Category> _flattenDescendants(List<Category> roots) {
  final result = <Category>[];
  void append(Category category) {
    result.add(category);
    for (final child in category.children) {
      append(child);
    }
  }

  for (final root in roots) {
    for (final child in root.children) {
      append(child);
    }
  }
  return result;
}

bool _matchesCategory(Category category, String query) {
  if (query.isEmpty) return true;
  final normalized = query.toLowerCase();
  return <String>[
    category.nameAr,
    category.nameEng,
    category.nameAbree,
  ].any((value) => value.toLowerCase().contains(normalized));
}

String _categoryName(Category category) {
  final language = Get.locale?.languageCode ?? 'ar';
  return language == 'ar'
      ? category.nameAr
      : language == 'en'
      ? category.nameEng
      : category.nameAbree;
}
