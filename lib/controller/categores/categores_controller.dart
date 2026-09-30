// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_null_comparison
import 'package:doctor_bike/core/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';

import '../../core/classes/status_request.dart';
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
  var supCategores = <Category>[].obs;
  List<Item> allProducts = <Item>[].obs;
  RxList<Item> _filteredProducts = <Item>[].obs;
  RxList<Item> get filteredProducts => _filteredProducts;
  int mainCategoresId = 0;
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

  Future<void> getProductsByStoreSection(int storeSectionId) async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (!await CheckInternet.checkInternet()) {
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
      return;
    }

    OverlayLoadingProgress.start();
    try {
      statusRequest = StatusRequest.loading;
      isLoading.value = true;
      final response = await categoriesRepository
          .getAllCategoriesByMainCategoresId(mainCategoresId: storeSectionId);

      if (response.statusCode == 200) {
        itemList = ItemsResponse.fromJson(response.body);
        allProducts = itemList!.rows;
        Get.toNamed(RouteHelper.categoryScreen);
      }
    } catch (e) {
      showCustomSnackBar(
        'An error occurred. Please try again.'.tr,
        isError: true,
      );
    } finally {
      isLoading.value = false;
      OverlayLoadingProgress.stop();
    }
  }

  RxList<Item> filtter() {
    _filteredProducts = <Item>[].obs;
    _filteredProducts.value =
        itemList!.rows.where((product) {
          return (token == null
                      ? product.normailPrice
                      : (isNormail
                          ? product.normailPrice
                          : product.wholesalePrice)) >=
                  priceRange.start &&
              (token == null
                      ? product.normailPrice
                      : (isNormail
                          ? product.normailPrice
                          : product.wholesalePrice)) <=
                  priceRange.end;
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
