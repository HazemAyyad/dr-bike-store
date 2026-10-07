// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_null_comparison
import 'package:doctor_bike/core/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';

import '../../core/classes/status_request.dart';
import '../../core/classes/store_view_state.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/supcategores_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../features/category/category_screen.dart';
import '../../features/category/filter_screen.dart';
import '../../repository/categories/categories_repository.dart';
import '../LocalizationController.dart';

abstract class CategoresController extends GetxController
    with GetSingleTickerProviderStateMixin {}

enum CatalogSort { recommended, newest, priceAsc, priceDesc, name }

class CatalogFilters {
  const CatalogFilters({
    this.minimumPrice,
    this.maximumPrice,
    this.availableOnly = false,
    this.onSale = false,
    this.sort = CatalogSort.recommended,
  });

  final double? minimumPrice;
  final double? maximumPrice;
  final bool availableOnly;
  final bool onSale;
  final CatalogSort sort;

  int get activeCount =>
      (minimumPrice == null ? 0 : 1) +
      (maximumPrice == null ? 0 : 1) +
      (availableOnly ? 1 : 0) +
      (onSale ? 1 : 0);

  Map<String, String> get query => {
    if (minimumPrice != null) 'minPrice': '$minimumPrice',
    if (maximumPrice != null) 'maxPrice': '$maximumPrice',
    if (availableOnly) 'availableOnly': 'true',
    if (onSale) 'onSale': 'true',
    'sort': switch (sort) {
      CatalogSort.recommended => 'recommended',
      CatalogSort.newest => 'newest',
      CatalogSort.priceAsc => 'price_asc',
      CatalogSort.priceDesc => 'price_desc',
      CatalogSort.name => 'name',
    },
  };
}

class CategoresControllerImp extends CategoresController {
  CategoresControllerImp({required this.categoriesRepository, this.titleMain});
  final CategoriesRepository categoriesRepository;
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  String? token;
  late bool isNormail;
  var selectedIndex2 = 0.obs;
  var sections = <SupCategoriesResponse>[].obs; // Stores all sections
  var filteredSections =
      <SupCategoriesResponse>[].obs; // Stores filtered sections
  var isLoading = false.obs;
  int departmentId = 0;
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  late TabController tabViewController = Get.put(
    TabController(vsync: this, length: 2, initialIndex: 0),
  );
  Rx<int> tabIndex = 0.obs;
  Rx<bool> isThree = false.obs;
  var useFiltter = false.obs;
  bool selectedCondition = false;
  double minPrice = 0;
  double maxPrice = 10000;
  RangeValues priceRange = const RangeValues(0, 10000);
  String? titleMain;
  late StatusRequest statusRequest;
  int selectedIndex = 0;
  ItemsResponse? itemList;
  final catalogState = Rx<StoreViewState<List<Item>>>(const StoreInitial());
  final filters = const CatalogFilters().obs;
  var supCategores = <Category>[].obs;
  List<Item> allProducts = <Item>[].obs;
  RxList<Item> _filteredProducts = <Item>[].obs;
  RxList<Item> get filteredProducts => _filteredProducts;
  int selectedOnlineStoreCategoryId = 0;
  int get mainCategoresId => selectedOnlineStoreCategoryId;
  set mainCategoresId(int value) => selectedOnlineStoreCategoryId = value;
  late List<Widget> widgetOption = [CategoryScreen(), const FilterPage()];
  var isGrid = false.obs;
  var isTwo = false.obs;
  var showFilter = false.obs;
  getAllCategores(int sub) async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        isLoading = true.obs;
        var response = await categoriesRepository.getCategoriesBySupId(
          supId: sub,
        );

        if (titleMain != null && mainCategoresId != null) {
          if (response.statusCode == 200) {
            itemList = ItemsResponse.fromJson(response.body);

            if (itemList!.rows.isNotEmpty) {
              allProducts = itemList!.rows;

              Get.toNamed(RouteHelper.categoryScreen);
              // filteredProducts!.value = itemList!.rows;
              // filteredProducts2?.value.assignAll(allProducts!);
            } else {
              Get.toNamed(RouteHelper.categoryScreen);
            }
          }
        }
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        isLoading = false.obs;
        OverlayLoadingProgress.stop();
      }
    } else {
      isLoading = false.obs;
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  Future<void> getProductsByOnlineStoreCategory(
    int categoryId, {
    bool navigate = true,
  }) async {
    selectedOnlineStoreCategoryId = categoryId;
    final previous = itemList?.rows;
    catalogState.value = StoreLoading(previousData: previous);
    isLoading.value = true;
    if (!await CheckInternet.checkInternet()) {
      catalogState.value = StoreOffline(
        message: 'Check the internet connection'.tr,
        previousData: previous,
      );
      isLoading.value = false;
      return;
    }
    try {
      final response = await categoriesRepository
          .getListingsByOnlineStoreCategory(
            categoryId: categoryId,
            filters: filters.value.query,
          );
      if (response.statusCode != 200 ||
          response.body is! Map<String, dynamic>) {
        throw const FormatException('catalog response is incompatible');
      }
      final parsed = ItemsResponse.fromJson(
        response.body as Map<String, dynamic>,
      );
      itemList = parsed;
      allProducts = parsed.rows;
      _filteredProducts.assignAll(parsed.rows);
      catalogState.value =
          parsed.rows.isEmpty
              ? StoreEmpty(message: 'No Item Found'.tr)
              : StoreContent(List<Item>.unmodifiable(parsed.rows));
      if (navigate) Get.toNamed(RouteHelper.categoryScreen);
    } on FormatException catch (error) {
      catalogState.value = StoreError(
        message: error.message,
        previousData: previous,
        code: 'malformed_catalog',
      );
    } catch (_) {
      catalogState.value = StoreError(
        message: 'An error occurred. Please try again.'.tr,
        previousData: previous,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> applyCatalogFilters(CatalogFilters value) async {
    filters.value = value;
    await getProductsByOnlineStoreCategory(
      selectedOnlineStoreCategoryId,
      navigate: false,
    );
  }

  Future<void> clearCatalogFilters() =>
      applyCatalogFilters(const CatalogFilters());

  @Deprecated('Use getProductsByOnlineStoreCategory')
  Future<void> getProductsByStoreSection(int storeSectionId) async {
    await getProductsByOnlineStoreCategory(storeSectionId);
  }

  RxList<Item> filtter() {
    _filteredProducts = <Item>[].obs;
    _filteredProducts.value =
        itemList!.rows.where((product) {
          return product.normailPrice >= priceRange.start &&
              product.normailPrice <= priceRange.end;
        }).toList();
    return _filteredProducts;
  }

  getSupCategoresByMainCategoresId(int mainCategoresId) async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        isLoading = true.obs;
        var response = await categoriesRepository
            .getSupCategorysByMainCategoresId(mainCategoresId: mainCategoresId);

        if (response.statusCode == 200) {
          // filterProducts();
          supCategores.value = List<Category>.from(
            response.body["rows"].map((x) => Category.fromJson(x)),
          );

          if (supCategores.isNotEmpty) {
            // allProducts = itemList!.rows;

            Get.toNamed(RouteHelper.supcategoryScreen);
            // filteredProducts!.value = itemList!.rows;
            // filteredProducts2?.value.assignAll(allProducts!);
          } else {
            Get.toNamed(RouteHelper.supcategoryScreen);
          }
        }

        update();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        isLoading = false.obs;
        OverlayLoadingProgress.stop();
      }
      // filterProducts();
      update();
    } else {
      isLoading = false.obs;
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    update();
  }

  getCategoryBySupId({required int supId}) async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        _filteredProducts.value = [];
        statusRequest = StatusRequest.loading;
        var response = await categoriesRepository.getCategoriesBySupId(
          supId: supId,
        );
        if (response.statusCode == 200) {
          List<Item> list;
          list = List<Item>.from(
            response.body["rows"].map((x) => Item.fromJson(x)),
          );
          for (var item in list) {
            if ((selectedCondition == item.isNewItem &&
                    (priceRange.start <= item.normailPrice ||
                        item.normailPrice >= priceRange.end)) ||
                (modelController.text == item.model ||
                    yearController.text == item.manufactureYear)) {
              _filteredProducts.add(item);
            }
          }

          // _filteredProducts.value = list;
        }

        OverlayLoadingProgress.stop();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  loadingIsNormail() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    update();
  }

  loadingToken() async {
    token = await AppUsageService.getToken();
    update();
  }

  @override
  void onInit() {
    loadingToken();
    loadingIsNormail();
    tabViewController.index = 0;
    modelController = TextEditingController();
    yearController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    modelController.clear();
    yearController.clear();
    useFiltter = false.obs;
    super.dispose();
  }
}
