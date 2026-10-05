import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/account/account_controller.dart';
import '../../controller/categores/categores_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/shop/shop_controller.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/theme/store_tokens.dart';
import '../../core/theme/store_typography.dart';
import '../../core/widget/store_bottom_navigation.dart';
import '../../core/widget/store_buttons.dart';
import '../../core/widget/store_states.dart';
import '../../core/widget/store_top_bar.dart';
import '../acount/profile_screen.dart';
import '../search/search_screen.dart';
import '../shop/shop_car_screen.dart';
import 'home_page.dart';
import 'widget/main_categorys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    this.controller,
    this.destinationPages,
    this.loadOnStart = true,
    super.key,
  });

  final HomeControllerImp? controller;
  final Map<StoreDestination, Widget>? destinationPages;
  final bool loadOnStart;

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
    StoreDestination.home => HomePage(controller: controller),
    StoreDestination.categories => _CategoriesDestination(
      controller: controller,
    ),
    StoreDestination.orders => const _OrdersDestination(),
    StoreDestination.favorites => const _FavoritesUnavailable(),
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
        Get.isRegistered<AccountControllerImp>()) {
      await Get.find<AccountControllerImp>().getAllOrders();
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
              StoreTopBar(
                displayName:
                    controller.displayName.value.isEmpty
                        ? 'storeGuest'.tr
                        : controller.displayName.value,
                notificationCount: controller.notificationBadgeCount,
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

class _CategoriesDestination extends StatelessWidget {
  const _CategoriesDestination({required this.controller});

  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) => Obx(() {
    final state = controller.categoriesState.value;
    return StoreStateView<List<Category>>(
      state: state,
      loading: const HomeLoadingSkeleton(),
      onRetry: controller.getMainCategores,
      contentBuilder:
          (context, categories) => RefreshIndicator(
            onRefresh: controller.getMainCategores,
            color: StorePalette.purple,
            child: GridView.builder(
              key: const PageStorageKey<String>('store-categories-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(StoreSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: StoreSpacing.sm,
                mainAxisSpacing: StoreSpacing.sm,
                mainAxisExtent: 164,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return MainCategorys(
                  image: category.imageUrl,
                  title: _categoryName(category),
                  onTap: () => _openCategory(category),
                );
              },
            ),
          ),
    );
  });

  Future<void> _openCategory(Category category) async {
    if (!Get.isRegistered<CategoresControllerImp>()) return;
    final categoriesController = Get.find<CategoresControllerImp>();
    categoriesController.mainCategoresId = category.id;
    categoriesController.titleMain = _categoryName(category);
    await categoriesController.getProductsByStoreSection(category.id);
  }
}

class _OrdersDestination extends StatelessWidget {
  const _OrdersDestination();

  @override
  Widget build(BuildContext context) => _ShellGateway(
    icon: Icons.receipt_long_outlined,
    title: 'storeOrdersGatewayTitle'.tr,
    message: 'storeOrdersGatewayMessage'.tr,
    action: 'storeOpenOrders'.tr,
    onPressed: () async {
      if (Get.isRegistered<AccountControllerImp>()) {
        await Get.find<AccountControllerImp>().getAllOrders();
      }
    },
  );
}

class _FavoritesUnavailable extends StatelessWidget {
  const _FavoritesUnavailable();

  @override
  Widget build(BuildContext context) => StoreMessageState(
    kind: StoreMessageKind.empty,
    title: 'storeFavoritesUnavailableTitle'.tr,
    message: 'storeFavoritesUnavailableMessage'.tr,
  );
}

class _ShellGateway extends StatelessWidget {
  const _ShellGateway({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(StoreSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: StorePalette.purple),
          const SizedBox(height: StoreSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: StoreTypography.title,
          ),
          const SizedBox(height: StoreSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: StoreTypography.body.copyWith(
              color: StorePalette.textSecondary,
            ),
          ),
          const SizedBox(height: StoreSpacing.md),
          StoreButton(label: action, onPressed: onPressed, expand: false),
        ],
      ),
    ),
  );
}

String _categoryName(Category category) {
  final language = Get.locale?.languageCode ?? 'ar';
  return language == 'ar'
      ? category.nameAr
      : language == 'en'
      ? category.nameEng
      : category.nameAbree;
}
