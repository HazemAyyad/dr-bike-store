import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/classes/store_view_state.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/helper/search_history_store.dart';
import '../../core/model/ads_response.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/model/notification_model.dart';
import '../../core/widget/store_bottom_navigation.dart';
import '../../repository/home/home_repository.dart';
import '../LocalizationController.dart';

enum ShellNavigationOutcome { selected, loginRequired, capabilityUnavailable }

abstract class HomeController extends GetxController {
  Future<void> getMainCategores();
  Future<void> getOnlineAds();
  Future<void> getAllItemIsMoreSales();
  Future<void> getNotifications();
  Future<void> postNotificationsIsRead();
  Future<void> getSearch(String name);
}

class HomeControllerImp extends HomeController {
  HomeControllerImp({
    required this.homeRepository,
    SearchHistoryStore? searchHistoryStore,
    Future<bool> Function()? connectivityCheck,
    Future<String?> Function()? tokenLoader,
    Future<String?> Function()? userNameLoader,
    LocalizationController? localizationController,
  }) : searchHistoryStore =
           searchHistoryStore ??
           SearchHistoryStore(preferences: Get.find<SharedPreferences>()),
       connectivityCheck =
           connectivityCheck ??
           (() async => await CheckInternet.checkInternet()),
       tokenLoader = tokenLoader ?? AppUsageService.getToken,
       userNameLoader = userNameLoader ?? AppUsageService.getUserName,
       localizationController =
           localizationController ??
           (Get.isRegistered<LocalizationController>()
               ? Get.find<LocalizationController>()
               : Get.put(
                 LocalizationController(sharedPreferences: Get.find()),
               ));

  static const shellDestinationPreferenceKey = 'store_shell_destination';

  final HomeDataSource homeRepository;
  final SearchHistoryStore searchHistoryStore;
  final Future<bool> Function() connectivityCheck;
  final Future<String?> Function() tokenLoader;
  final Future<String?> Function() userNameLoader;
  final LocalizationController localizationController;

  final CarouselSliderController carouselController =
      CarouselSliderController();
  final currentPage = 0.obs;
  final selectedDestination = StoreDestination.home.obs;
  final isSearchExpanded = false.obs;
  final recentSearches = <String>[].obs;
  final displayName = ''.obs;
  final searchState = Rx<StoreViewState<List<Item>>>(const StoreInitial());
  final categoriesState = Rx<StoreViewState<List<Category>>>(
    const StoreInitial(),
  );
  final heroState = Rx<StoreViewState<List<Ad>>>(const StoreInitial());
  final productsState = Rx<StoreViewState<List<Item>>>(const StoreInitial());

  final isLoadingSearch = false.obs;
  final isLoadingGetOnlineAds = false.obs;
  final isLoadingGetItems = false.obs;
  final isLoadingGetCategories = false.obs;
  final isTwo = false.obs;
  final mainCategoresModel = <Category>[].obs;
  final adsResponse = <Ad>[].obs;
  final itemList = <Item>[].obs;
  final itemListSearch = <Item>[].obs;
  final notificationIsNotRead = <int>[].obs;
  final isNotificationNotRead = false.obs;

  Rx<NotificationResponse>? notifications;
  late final TextEditingController search = TextEditingController();
  String? token;
  bool isNormail = true;
  bool isGrid = false;
  bool showFilter = false;
  bool _initialized = false;

  bool get isAuthenticated => token != null && token!.trim().isNotEmpty;
  int? get notificationBadgeCount =>
      notificationIsNotRead.isEmpty ? null : notificationIsNotRead.length;

  List<Item> get specialOffers =>
      itemList.where((item) => item.discount > 0).toList(growable: false);

  List<Item> get newArrivals =>
      itemList.where((item) => item.isNewItem).toList(growable: false);

  Future<void> initializeShell() async {
    token = await tokenLoader();
    displayName.value = (await userNameLoader())?.trim() ?? '';
    isNormail = await AppUsageService.getTypeUser() == 'Normail';
    recentSearches.assignAll(await searchHistoryStore.load());
    await _restoreDestination();
    _initialized = true;
    update();
  }

  Future<void> _restoreDestination() async {
    final saved = searchHistoryStore.preferences.getString(
      shellDestinationPreferenceKey,
    );
    final destination = StoreDestination.values.firstWhereOrNull(
      (candidate) => candidate.name == saved,
    );
    if (destination == null ||
        (!isAuthenticated &&
            (destination == StoreDestination.orders ||
                destination == StoreDestination.favorites))) {
      selectedDestination.value = StoreDestination.home;
      return;
    }
    selectedDestination.value = destination;
  }

  Future<ShellNavigationOutcome> selectDestination(
    StoreDestination destination,
  ) async {
    if ((destination == StoreDestination.orders ||
            destination == StoreDestination.favorites) &&
        !isAuthenticated) {
      return ShellNavigationOutcome.loginRequired;
    }

    closeSearch(clearQuery: false);
    selectedDestination.value = destination;
    await searchHistoryStore.preferences.setString(
      shellDestinationPreferenceKey,
      destination.name,
    );
    update();

    if (destination == StoreDestination.favorites) {
      return ShellNavigationOutcome.capabilityUnavailable;
    }
    return ShellNavigationOutcome.selected;
  }

  void openSearch() {
    isSearchExpanded.value = true;
    update();
  }

  void closeSearch({bool clearQuery = true}) {
    isSearchExpanded.value = false;
    if (clearQuery) {
      search.clear();
      searchState.value = const StoreInitial();
    }
    update();
  }

  void setSearchExpanded(bool expanded) {
    if (expanded) {
      openSearch();
    } else {
      closeSearch();
    }
  }

  Future<bool> handleShellBack() async {
    if (isSearchExpanded.value) {
      closeSearch();
      return true;
    }
    if (selectedDestination.value != StoreDestination.home) {
      await selectDestination(StoreDestination.home);
      return true;
    }
    return false;
  }

  Future<void> loadHome({bool refresh = false}) async {
    if (!await connectivityCheck()) {
      _setHomeOffline();
      return;
    }
    await Future.wait<void>([
      getOnlineAds(),
      getAllItemIsMoreSales(),
      getMainCategores(),
      if (isAuthenticated) getNotifications(),
    ]);
  }

  void _setHomeOffline() {
    categoriesState.value = StoreOffline(
      message: 'storeOfflineMessage'.tr,
      previousData:
          mainCategoresModel.isEmpty ? null : mainCategoresModel.toList(),
    );
    heroState.value = StoreOffline(
      message: 'storeOfflineMessage'.tr,
      previousData: adsResponse.isEmpty ? null : adsResponse.toList(),
    );
    productsState.value = StoreOffline(
      message: 'storeOfflineMessage'.tr,
      previousData: itemList.isEmpty ? null : itemList.toList(),
    );
    update();
  }

  @override
  Future<void> getMainCategores() async {
    isLoadingGetCategories.value = true;
    categoriesState.value = StoreLoading(
      previousData:
          mainCategoresModel.isEmpty ? null : mainCategoresModel.toList(),
    );
    try {
      final response = await homeRepository.getMainCategories();
      if (response.statusCode != 200) {
        throw const FormatException('category-response-status');
      }
      final categories = _rows(response.body)
          .map(Category.fromJson)
          .where((category) => category.isShow)
          .toList(growable: false);
      mainCategoresModel.assignAll(categories);
      categoriesState.value =
          categories.isEmpty
              ? StoreEmpty(message: 'storeNoCategoriesMessage'.tr)
              : StoreContent(categories);
    } catch (_) {
      categoriesState.value = StoreError(
        message: 'storeHomeSectionError'.tr,
        previousData:
            mainCategoresModel.isEmpty ? null : mainCategoresModel.toList(),
      );
    } finally {
      isLoadingGetCategories.value = false;
      update();
    }
  }

  @override
  Future<void> getAllItemIsMoreSales() async {
    isLoadingGetItems.value = true;
    productsState.value = StoreLoading(
      previousData: itemList.isEmpty ? null : itemList.toList(),
    );
    try {
      final response = await homeRepository.getAllItemIsMoreSales();
      if (response.statusCode != 200) {
        throw const FormatException('product-response-status');
      }
      final products = _rows(
        response.body,
      ).map(Item.fromJson).where((item) => item.isShow).toList(growable: false);
      itemList.assignAll(products);
      productsState.value =
          products.isEmpty
              ? StoreEmpty(message: 'storeNoProductsMessage'.tr)
              : StoreContent(products);
    } catch (_) {
      productsState.value = StoreError(
        message: 'storeHomeSectionError'.tr,
        previousData: itemList.isEmpty ? null : itemList.toList(),
      );
    } finally {
      isLoadingGetItems.value = false;
      update();
    }
  }

  @override
  Future<void> getOnlineAds() async {
    isLoadingGetOnlineAds.value = true;
    heroState.value = StoreLoading(
      previousData: adsResponse.isEmpty ? null : adsResponse.toList(),
    );
    try {
      final response = await homeRepository.getOnlineAds();
      if (response.statusCode != 200) {
        throw const FormatException('ad-response-status');
      }
      final ads = _rows(
        response.body,
      ).map(Ad.fromJson).where((ad) => ad.isShow).toList(growable: false);
      adsResponse.assignAll(ads);
      heroState.value =
          ads.isEmpty
              ? StoreEmpty(message: 'storeNoPromotionsMessage'.tr)
              : StoreContent(ads);
    } catch (_) {
      heroState.value = StoreError(
        message: 'storeHomeSectionError'.tr,
        previousData: adsResponse.isEmpty ? null : adsResponse.toList(),
      );
    } finally {
      isLoadingGetOnlineAds.value = false;
      update();
    }
  }

  @override
  Future<void> getSearch(String name) => submitSearch(name);

  Future<void> submitSearch(String query) async {
    final normalized = query.trim();
    search.text = normalized;
    if (normalized.isEmpty) {
      itemListSearch.clear();
      searchState.value = const StoreInitial();
      update();
      return;
    }

    recentSearches.assignAll(await searchHistoryStore.add(normalized));
    if (!await connectivityCheck()) {
      isLoadingSearch.value = false;
      searchState.value = StoreOffline(message: 'storeOfflineMessage'.tr);
      update();
      return;
    }

    isLoadingSearch.value = true;
    searchState.value = StoreLoading(
      previousData: itemListSearch.isEmpty ? null : itemListSearch.toList(),
    );
    update();
    try {
      final response = await homeRepository.search(
        normalized,
        localizationController.locale.languageCode,
      );
      if (response.statusCode != 200) {
        throw const FormatException('search-response-status');
      }
      final products = _rows(
        response.body,
      ).map(Item.fromJson).where((item) => item.isShow).toList(growable: false);
      itemListSearch.assignAll(products);
      searchState.value =
          products.isEmpty
              ? StoreEmpty(
                title: 'storeSearchNoResultsTitle'.tr,
                message: 'storeSearchNoResultsMessage'.trParams({
                  'query': normalized,
                }),
              )
              : StoreContent(products);
    } catch (_) {
      searchState.value = StoreError(message: 'storeSearchFailureMessage'.tr);
    } finally {
      isLoadingSearch.value = false;
      update();
    }
  }

  Future<void> retrySearch() => submitSearch(search.text);

  Future<void> clearRecentSearches() async {
    await searchHistoryStore.clear();
    recentSearches.clear();
    update();
  }

  void selectRecentSearch(String query) {
    search.text = query;
    submitSearch(query);
  }

  @override
  Future<void> getNotifications() async {
    if (!isAuthenticated || !await connectivityCheck()) return;
    try {
      final response = await homeRepository.getNotification();
      if (response.statusCode != 200) return;
      notifications = NotificationResponse.fromJson(response.body).obs;
      notificationIsNotRead.assignAll(
        notifications!.value.rows
            .where((notification) => !notification.isRead)
            .map((notification) => notification.id),
      );
      isNotificationNotRead.value = notificationIsNotRead.isNotEmpty;
    } catch (_) {
      // Notification failure is optional Home content and remains omitted.
    }
    update();
  }

  @override
  Future<void> postNotificationsIsRead() async {
    if (!isAuthenticated || notificationIsNotRead.isEmpty) return;
    final confirmed = <int>[];
    for (final id in notificationIsNotRead) {
      try {
        final response = await homeRepository.postNotificationIsRead(id);
        if (response.statusCode == 200) confirmed.add(id);
      } catch (_) {
        // Keep unconfirmed notifications unread.
      }
    }
    notificationIsNotRead.removeWhere(confirmed.contains);
    isNotificationNotRead.value = notificationIsNotRead.isNotEmpty;
    update();
  }

  String formatDate(DateTime date) => DateFormat('MMMM d, yyyy').format(date);

  Future<void> openWeb(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> loadingToken() async {
    token = await tokenLoader();
    update();
  }

  Future<void> loadingIsNormail() async {
    isNormail = await AppUsageService.getTypeUser() == 'Normail';
    update();
  }

  List<Map<String, dynamic>> _rows(dynamic body) {
    if (body is! Map || body['rows'] is! List) {
      throw const FormatException('rows');
    }
    return (body['rows'] as List)
        .map((row) {
          if (row is! Map) throw const FormatException('row');
          return Map<String, dynamic>.from(row);
        })
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    if (!_initialized) initializeShell();
  }

  @override
  void onClose() {
    search.dispose();
    super.onClose();
  }
}
