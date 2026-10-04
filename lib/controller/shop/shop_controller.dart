// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:doctor_bike/core/model/get_all_item_model.dart';
import 'package:get_storage/get_storage.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:intl/intl.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/checkout_attempt.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/functions/native_checkout.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/auth_eesponse.dart';
import '../../core/model/city_model.dart';
import '../../core/model/discount_code_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/shop/shop_repository.dart';
import '../LocalizationController.dart';

class ShopController extends GetxController {
  final CheckoutAttempt _checkoutAttempt = CheckoutAttempt();
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  final box = GetStorage();
  RxList<Item> cartItems = <Item>[].obs;
  late bool isNormail;
  String? token;
  void addToCart(Item item) {
    int index = cartItems.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      cartItems[index].count += item.count;
    } else {
      cartItems.add(item);
    }
    saveCart();
  }

  loadingIsNormail() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    update();
  }

  void removeFromCart(Item item) {
    cartItems.removeWhere((element) {
      return (element.id == item.id &&
          element.itemSizeId == item.itemSizeId &&
          element.itemSizeColorId == item.itemSizeColorId);
    });
    saveCart();
  }

  void clearCart() {
    cartItems.clear();
    box.remove('cart');
  }

  void saveCart() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    List<Map<String, dynamic>> itemsAsJson =
        cartItems.map((item) => item.toJson()).toList();
    box.write('cart', itemsAsJson);
    update();
  }

  loadCart() {
    List? savedItems = box.read<List>('cart');

    if (savedItems != null) {
      cartItems.value =
          savedItems.map((itemJson) => Item.fromJson2(itemJson)).toList();
      items = cartItems;
    }
  }

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  ShopRepository shopRepository;
  bool changeList = false;
  int quantity = 0;
  Rx<bool> isThree = false.obs;

  double priceItems = 0;
  double totalPrice = 0;
  double totalPriceWithDiscount = 0;
  double totalPriceWithOutDiscount = 0;
  double totalPriceWithOutDiscountOrders = 0;
  double totalPriceWithDiscountOrders = 0;
  List<Item> items = <Item>[].obs;

  bool isLoading = false;
  bool isVillagesLoading = false;
  bool isDeliveryLoading = false;
  bool? activeCode;
  List<Citys> cities = [];
  List<String> citiesList = [];
  List<ShiplyVillage> villages = [];
  List<String> villagesList = [];
  UserModel? userModel;
  CitiesResponse? citiesResponse;
  VillagesResponse? villagesResponse;
  CouponModel? couponModel;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController phoneNumber2Controller;
  late TextEditingController addressController;
  late TextEditingController discountCodeController;
  String? selectedCity; // Default selected city
  String? selectedCityDeliver; // Default selected city
  String? selectedCityId; // Default selected city
  String? selectedVillage;
  String? selectedVillageId;
  double selectedCityPrice = 0; // Default selected city
  int? discoundCodeId; // Default selected city
  double? discoundCodePercent; // Default selected city
  late StatusRequest statusRequest;
  String? OrderId;
  ShopController({required this.shopRepository});
  getUserById() async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await shopRepository.getUser();
        var responseCity = await shopRepository.getCity();
        if (response.statusCode == 200 && responseCity.statusCode == 200) {
          userModel = UserModel.fromJson(response.body);
          nameController.text =
              userModel!.fullName == null ? '' : userModel!.fullName.toString();
          emailController.text = userModel!.email;
          phoneNumberController.text =
              userModel!.phoneNumber == null
                  ? ''
                  : userModel!.phoneNumber.toString();
          phoneNumber2Controller.text =
              userModel!.phoneNumber2 == null
                  ? ''
                  : userModel!.phoneNumber2.toString();

          // selectedCity = userModel!.city.toString();
          addressController.text =
              userModel!.address == null ? '' : userModel!.address.toString();
          citiesResponse = CitiesResponse.fromJson(responseCity.body);
          for (int i = 0; i < citiesResponse!.rows.length; i++) {
            if (userModel!.cityId == citiesResponse!.rows[i].id) {
              selectedCityId = citiesResponse!.rows[i].id.toString();
              selectedCity =
                  localizationController.locale.languageCode == 'ar'
                      ? citiesResponse!.rows[i].cityNameAr
                      : localizationController.locale.languageCode == 'en'
                      ? citiesResponse!.rows[i].cityNameEng
                      : citiesResponse!.rows[i].cityNameAbree;
              selectedCityPrice = citiesResponse!.rows[i].deliver;
            }
          }
          createListCity();
          if (selectedCityId != null) {
            await loadVillagesForSelectedCity();
          }
        }

        Get.toNamed(RouteHelper.checkOutScreen);
      } catch (e, stackTrace) {
        debugPrint('[STORE_CHECKOUT] getUserById error=$e');
        debugPrint('[STORE_CHECKOUT] getUserById stack=$stackTrace');
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }
  // getUserById() async {
  //   if (await CheckInternet.checkInternet()) {
  //     bool isAr = localizationController.locale.languageCode == 'ar';
  //     bool isEng = localizationController.locale.languageCode == 'en';
  //     OverlayLoadingProgress.start();
  //     try {
  //       statusRequest = StatusRequest.loading;
  //       var response = await shopRepository.getUser();
  //       var responseCity = await shopRepository.getCity();
  //       if (response.statusCode == 200 && responseCity.statusCode == 200) {
  //         userModel = UserModel.fromJson(response.body);
  //         nameController.text =
  //             userModel!.fullName == null ? '' : userModel!.fullName!;
  //         emailController.text = userModel!.email;
  //         phoneNumberController.text =
  //             userModel!.phoneNumber == null
  //                 ? ''
  //                 : userModel!.phoneNumber.toString();
  //         phoneNumber2Controller.text =
  //             userModel!.phoneNumber2 == null
  //                 ? ''
  //                 : userModel!.phoneNumber2.toString();

  //         if (userModel?.city != null) {
  //           selectedCityDeliver = userModel?.city?.deliver.toString();
  //           selectedCity =
  //               isAr
  //                   ? userModel?.city?.cityNameAr
  //                   : isEng
  //                   ? userModel?.city?.cityNameEng
  //                   : userModel?.city?.cityNameAbree;
  //         } else {
  //           selectedCity = '';
  //         }

  //         addressController.text =
  //             userModel!.address == null ? '' : userModel!.address.toString();

  //         citiesResponse = CitiesResponse.fromJson(responseCity.body);
  //         createListCity();
  //       }
  //       for (var item in items) {
  //         totalPriceWithDiscount =
  //             item.isSize
  //                 ? (item.itemSizediscount != 0 || item.itemSizediscount != null
  //                     ? (((item.count * (item.itemSizeColorsprice ?? 0)) *
  //                             (1 - ((item.itemSizediscount ?? 0) / 100))) +
  //                         totalPriceWithDiscount)
  //                     : (totalPriceWithDiscount +
  //                         (item.count * (item.itemSizeColorsprice ?? 0))))
  //                 : (item.discount != 0
  //                     ? (((item.count * item.normailPrice) *
  //                             (1 - (item.discount / 100))) +
  //                         totalPriceWithDiscount)
  //                     : (totalPriceWithDiscount +
  //                         (item.count * item.normailPrice)));
  //         totalPrice =
  //             item.isSize
  //                 ? (totalPrice +
  //                     (item.count * (item.itemSizeColorsprice ?? 0)))
  //                 : (totalPrice + (item.count * item.normailPrice));
  //       }

  //       Get.toNamed(RouteHelper.checkOutScreen);
  //     } catch (e) {
  //       showCustomSnackBar(
  //         'An error occurred. Please try again.'.tr,
  //         isError: true,
  //       );
  //     } finally {
  //       OverlayLoadingProgress.stop();
  //     }
  //   } else {
  //     OverlayLoadingProgress.stop();
  //     showCustomSnackBar('Check the internet connection'.tr, isError: true);
  //   }
  // }

  getUserByIdAccount() async {
    if (await CheckInternet.checkInternet()) {
      bool isAr = localizationController.locale.languageCode == 'ar';
      bool isEng = localizationController.locale.languageCode == 'en';
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await shopRepository.getUser();
        var responseCity = await shopRepository.getCity();
        if (response.statusCode == 200 && responseCity.statusCode == 200) {
          userModel = UserModel.fromJson(response.body);
          nameController.text =
              userModel!.fullName == null ? '' : userModel!.fullName!;
          emailController.text = userModel!.email;
          phoneNumberController.text =
              userModel!.phoneNumber == null
                  ? ''
                  : userModel!.phoneNumber.toString();
          phoneNumber2Controller.text =
              userModel!.phoneNumber2 == null
                  ? ''
                  : userModel!.phoneNumber2.toString();

          if (userModel?.city != null) {
            selectedCity =
                isAr
                    ? userModel?.city?.cityNameAr
                    : isEng
                    ? userModel?.city?.cityNameEng
                    : userModel?.city?.cityNameAbree;
          } else {
            selectedCity = '';
          }
          addressController.text =
              userModel!.address == null ? '' : userModel!.address.toString();

          citiesResponse = CitiesResponse.fromJson(responseCity.body);
          createListCity();
        }
        for (var item in items) {
          totalPriceWithDiscount =
              item.isSize
                  ? (item.itemSizediscount! != 0 ||
                          item.itemSizediscount != null
                      ? (((item.count * item.itemSizeColorsprice!) *
                              (1 - (item.itemSizediscount! / 100))) +
                          totalPriceWithDiscount)
                      : (totalPriceWithDiscount +
                          (item.count * item.itemSizeColorsprice!)))
                  : (item.discount != 0
                      ? (((item.count * item.normailPrice) *
                              (1 - (item.discount / 100))) +
                          totalPriceWithDiscount)
                      : (totalPriceWithDiscount +
                          (item.count * item.normailPrice)));
          totalPrice =
              item.isSize
                  ? (totalPrice + (item.count * item.itemSizeColorsprice!))
                  : (totalPrice + (item.count * item.normailPrice));
        }

        Get.toNamed(RouteHelper.personalDetailsPage);
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  createListCity() {
    cities = citiesResponse!.rows;
    citiesList.clear();
    for (var city in cities) {
      citiesList.add(
        localizationController.locale.languageCode == 'ar'
            ? city.cityNameAr.toString()
            : localizationController.locale.languageCode == 'en'
            ? city.cityNameEng.toString()
            : city.cityNameAbree.toString(),
      );
    }
  }

  createListVillage() {
    villages = villagesResponse?.rows ?? [];
    villagesList.clear();
    for (var village in villages) {
      villagesList.add(village.name);
    }
  }

  Future<void> onCitySelected(Citys city) async {
    selectedCityId = city.id.toString();
    selectedCity =
        localizationController.locale.languageCode == 'ar'
            ? city.cityNameAr
            : localizationController.locale.languageCode == 'en'
            ? city.cityNameEng
            : city.cityNameAbree;
    selectedCityPrice = 0;
    selectedVillage = null;
    selectedVillageId = null;
    villages = [];
    villagesList.clear();
    isVillagesLoading = true;
    update();
    await loadVillagesForSelectedCity();
  }

  Future<void> onVillageSelected(ShiplyVillage village) async {
    selectedVillage = village.name;
    selectedVillageId = village.id.toString();
    selectedCityPrice = 0;
    isDeliveryLoading = true;
    update();
    await calculateDeliveryFeeForSelectedVillage();
  }

  Future<void> loadVillagesForSelectedCity() async {
    if (selectedCityId == null) return;
    isVillagesLoading = true;
    update();
    try {
      final response = await shopRepository.getVillagesByCityId(
        selectedCityId!,
      );
      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        villagesResponse = VillagesResponse.fromJson(response.body);
        createListVillage();
      }
    } catch (e) {
      debugPrint('[STORE_SHIPLY] villages error=$e');
    } finally {
      isVillagesLoading = false;
      update();
    }
  }

  Future<void> calculateDeliveryFeeForSelectedVillage() async {
    if (selectedVillageId == null) return;
    isDeliveryLoading = true;
    update();
    try {
      final response = await shopRepository.calculateDeliveryFee(
        villageId: selectedVillageId!,
        price: deliveryQuotePrice(),
      );
      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final body = response.body as Map<String, dynamic>;
        selectedCityPrice =
            (body['deliveryCost'] as num?)?.toDouble() ??
            (body['priceDelivery'] as num?)?.toDouble() ??
            ((body['fees'] is Map<String, dynamic>)
                ? (body['fees']['delivery_cost'] as num?)?.toDouble()
                : null) ??
            0;
      }
    } catch (e) {
      debugPrint('[STORE_SHIPLY] delivery fee error=$e');
    } finally {
      isDeliveryLoading = false;
      update();
    }
  }

  double deliveryQuotePrice() {
    double total = 0;
    for (final item in items) {
      final basePrice =
          item.isSize
              ? (item.itemSizeColorsprice ?? 0)
              : (token == null
                  ? item.normailPrice
                  : (isNormail ? item.normailPrice : item.wholesalePrice));
      final discount =
          item.isSize ? (item.itemSizediscount ?? 0) : item.discount;
      total += item.count * basePrice * (1 - (discount / 100));
    }
    return total;
  }

  cal() {
    quantity = 0;
    priceItems = 0;
    for (int i = 0; i < items.length; i++) {
      quantity = quantity + items[i].count;
      priceItems =
          priceItems +
          (items[i].count *
              (token == null
                  ? items[i].normailPrice
                  : (isNormail
                      ? items[i].normailPrice
                      : items[i].wholesalePrice)));
    }
  }

  deletItem(id) {
    for (int i = 0; i < items.length; i++) {
      if (id == items[i].id) {
        items.remove(items[i]);
      }
    }
    saveCart();
    update();
  }

  addItem(Item iteme) {
    bool isAdd = false;

    for (int i = 0; i < items.length; i++) {
      if (iteme.id == items[i].id) {
        if (iteme.itemSizeId == items[i].itemSizeId) {
          if (iteme.itemSizeColorId == items[i].itemSizeColorId) {
            isAdd = true;
          }
        }
      }
    }

    update();
    if (isAdd == false) {
      items.add(iteme);

      showCustomSnackBar("Product added".tr, isError: false);
      Get.back();
    } else if (isAdd == true) {
      showCustomSnackBar(
        "The product has been added previously".tr,
        isError: false,
      );

      isAdd = false;
    }

    cal();
    saveCart();

    update();
  }

  add(i) {
    for (var action in items) {
      if (action.id == i) {
        action.count++;
      }
    }
    saveCart();
    cal();
    update();
  }

  mins(id) {
    for (int i = 0; i < items.length; i++) {
      if (items[i].id == id) {
        if (items[i].count > 1) {
          items[i].count--;
        } else if (items[i].count == 1) {
          items.remove(items[i]);
          showCustomSnackBar(
            "The product has been removed.".tr,
            isError: false,
          );
        }
      }
    }
    saveCart();
    cal();
    update();
  }

  Future<String?> _resolveCheckoutAccountRole() async {
    if (userModel == null) {
      final response = await shopRepository.getUser();
      if (response.statusCode != 200 ||
          response.body is! Map<String, dynamic>) {
        showCustomSnackBar(
          'تعذر تحديث بيانات حساب المتجر. يرجى المحاولة مرة أخرى.',
          isError: true,
        );
        return null;
      }
      userModel = UserModel.fromJson(response.body);
    }

    final resolution = resolveCheckoutRoles(userModel!.accountRoles);
    if (resolution.requirement == CheckoutRoleRequirement.unavailable) {
      showCustomSnackBar(
        'لا يوجد حساب بيع معتمد مرتبط بحساب المتجر. يرجى التواصل مع الإدارة.',
        isError: true,
      );
      return null;
    }
    if (resolution.requirement == CheckoutRoleRequirement.resolved) {
      return resolution.role;
    }

    final selectedRole = await Get.dialog<String>(
      AlertDialog(
        title: const Text('اختر نوع الطلب'),
        content: const Text('هل تريد تنفيذ الطلب كتجزئة أم جملة؟'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Get.back(result: 'customer'),
            child: const Text('تجزئة'),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'seller'),
            child: const Text('جملة'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return confirmCheckoutRole(resolution, selectedRole);
  }

  createOrder() async {
    if (selectedCityId == null || selectedVillageId == null) {
      showCustomSnackBar('Choose city and village'.tr, isError: true);
      return;
    }
    if (items.any((item) => item.listingId == null)) {
      showCustomSnackBar(
        'أحد المنتجات غير متاح حاليًا للطلب عبر المتجر. يرجى تحديث السلة.',
        isError: true,
      );
      return;
    }
    final accountRole = await _resolveCheckoutAccountRole();
    if (accountRole == null) return;
    if (!_checkoutAttempt.begin()) return;

    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        OverlayLoadingProgress.start();
        await editeUser();
        totalPriceWithDiscountOrders = 0;
        totalPriceWithOutDiscountOrders = 0;
        List<Map> details =
            items.map((item) {
              totalPriceWithDiscount = 0;
              totalPriceWithOutDiscount = 0;
              if (item.isSize) {
                if (item.itemSizediscount != 0 &&
                    item.itemSizediscount != null) {
                  totalPriceWithDiscount =
                      ((item.count * item.itemSizeColorsprice!) *
                          (1 - (item.itemSizediscount! / 100)));
                  totalPriceWithOutDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      ((item.count * item.itemSizeColorsprice!) *
                          (1 - (item.itemSizediscount! / 100)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                } else {
                  totalPriceWithDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithOutDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                }
              } else {
                if (item.discount > 0) {
                  totalPriceWithDiscount =
                      ((item.count *
                              (token == null
                                  ? item.normailPrice
                                  : (isNormail
                                      ? item.normailPrice
                                      : item.wholesalePrice))) *
                          (1 - (item.discount / 100)));
                  totalPriceWithOutDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      ((item.count *
                              (token == null
                                  ? item.normailPrice
                                  : (isNormail
                                      ? item.normailPrice
                                      : item.wholesalePrice))) *
                          (1 - (item.discount / 100)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                } else {
                  totalPriceWithDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithOutDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                }
              }

              return {
                "id": 0,
                "orderId": 0,
                "itemId": item.id,
                "isOrderSize": item.isSize,
                "itemSizeId": item.itemSizeId,
                "itemSizeColorId": item.itemSizeColorId,
                "quantity": item.count,
                "itemPrice":
                    (item.isSize
                        ? item.itemSizeColorsprice
                        : (token == null
                            ? item.normailPrice
                            : (isNormail
                                ? item.normailPrice
                                : item.wholesalePrice))),
                "totalPriceWithDiscound": totalPriceWithDiscount.toDouble(),
                "totalPriceWithOutDiscound":
                    totalPriceWithOutDiscount.toDouble(),
              };
            }).toList();

        if (details.length != items.length) {
          throw StateError('Unable to prepare all checkout items.');
        }

        var response = await shopRepository.createOrder(
          body: _checkoutAttempt.attachTo(
            buildNativeCheckoutPayload(
              items: items,
              accountRole: accountRole,
              customerAddress: addressController.text,
              shiplyCityId: int.parse(selectedCityId!),
              shiplyVillageId: int.parse(selectedVillageId!),
            ),
          ),
        );

        final success = completeCheckoutAttempt(
          _checkoutAttempt,
          response.statusCode,
          response.body,
        );
        if (success != null) {
          OrderId = success.orderId;
          Get.offNamed(RouteHelper.checkOutDone);
          items = [];
          saveCart();
          clearCart();
          totalPriceWithDiscountOrders = 0;
          totalPriceWithOutDiscountOrders = 0;
          totalPriceWithDiscount = 0;
          totalPriceWithOutDiscount = 0;
          totalPrice = 0;
          priceItems = 0;
          quantity = 0;
          selectedCity = null;
          selectedCityId = null;
          selectedVillage = null;
          selectedVillageId = null;
          villages = [];
          villagesList.clear();
          selectedCityPrice = 0;
          update();
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          showCustomSnackBar(
            'تعذر تأكيد الطلب. يرجى إعادة المحاولة دون تغيير السلة.',
            isError: true,
          );
        } else if (response.statusCode == 400) {
          showCustomSnackBar(response.body["message"], isError: true);
        }
        update();
      } catch (e) {
        showCustomSnackBar(e.toString(), isError: true);
      } finally {}
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    _checkoutAttempt.finish(successful: false);
    OverlayLoadingProgress.stop();
  }

  createOrderWithCode() async {
    if (selectedCityId == null || selectedVillageId == null) {
      showCustomSnackBar('Choose city and village'.tr, isError: true);
      return;
    }
    if (items.any((item) => item.listingId == null)) {
      showCustomSnackBar(
        'أحد المنتجات غير متاح حاليًا للطلب عبر المتجر. يرجى تحديث السلة.',
        isError: true,
      );
      return;
    }
    final accountRole = await _resolveCheckoutAccountRole();
    if (accountRole == null) return;
    if (!_checkoutAttempt.begin()) return;

    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        OverlayLoadingProgress.start();
        await editeUser();
        totalPriceWithDiscountOrders = 0;
        totalPriceWithOutDiscountOrders = 0;
        List<Map> details =
            items.map((item) {
              totalPriceWithDiscount = 0;
              totalPriceWithOutDiscount = 0;
              if (item.isSize) {
                if (item.itemSizediscount != 0 &&
                    item.itemSizediscount != null) {
                  totalPriceWithDiscount =
                      ((item.count * item.itemSizeColorsprice!) *
                          (1 - (item.itemSizediscount! / 100)));
                  totalPriceWithOutDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      ((item.count * item.itemSizeColorsprice!) *
                          (1 - (item.itemSizediscount! / 100)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                } else {
                  totalPriceWithDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithOutDiscount =
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count * item.itemSizeColorsprice!);
                }
              } else {
                if (item.discount > 0) {
                  totalPriceWithDiscount =
                      ((item.count *
                              (token == null
                                  ? item.normailPrice
                                  : (isNormail
                                      ? item.normailPrice
                                      : item.wholesalePrice))) *
                          (1 - (item.discount / 100)));
                  totalPriceWithOutDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      ((item.count *
                              (token == null
                                  ? item.normailPrice
                                  : (isNormail
                                      ? item.normailPrice
                                      : item.wholesalePrice))) *
                          (1 - (item.discount / 100)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                } else {
                  totalPriceWithDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithOutDiscount =
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithDiscountOrders =
                      totalPriceWithDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                  totalPriceWithOutDiscountOrders =
                      totalPriceWithOutDiscountOrders +
                      (item.count *
                          (token == null
                              ? item.normailPrice
                              : (isNormail
                                  ? item.normailPrice
                                  : item.wholesalePrice)));
                }
              }

              return {
                "id": 0,
                "orderId": 0,
                "itemId": item.id,
                "isOrderSize": item.isSize,
                "itemSizeId": item.itemSizeId,
                "itemSizeColorId": item.itemSizeColorId,
                "quantity": item.count,
                "itemPrice":
                    (item.isSize
                        ? item.itemSizeColorsprice
                        : (token == null
                            ? item.normailPrice
                            : (isNormail
                                ? item.normailPrice
                                : item.wholesalePrice))),
                "totalPriceWithDiscound": totalPriceWithDiscount.toDouble(),
                "totalPriceWithOutDiscound":
                    totalPriceWithOutDiscount.toDouble(),
              };
            }).toList();

        if (details.length != items.length) {
          throw StateError('Unable to prepare all checkout items.');
        }

        var response = await shopRepository.createOrder(
          body: _checkoutAttempt.attachTo(
            buildNativeCheckoutPayload(
              items: items,
              accountRole: accountRole,
              customerAddress: addressController.text,
              shiplyCityId: int.parse(selectedCityId!),
              shiplyVillageId: int.parse(selectedVillageId!),
              couponCode: couponModel!.code,
            ),
          ),
        );

        final success = completeCheckoutAttempt(
          _checkoutAttempt,
          response.statusCode,
          response.body,
        );
        if (success != null) {
          OrderId = success.orderId;
          Get.offNamed(RouteHelper.checkOutDone);
          items = [];
          saveCart();
          clearCart();
          totalPriceWithDiscountOrders = 0;
          totalPriceWithOutDiscountOrders = 0;
          totalPriceWithDiscount = 0;
          totalPriceWithOutDiscount = 0;
          totalPrice = 0;
          priceItems = 0;
          quantity = 0;
          selectedCity = null;
          selectedCityId = null;
          selectedVillage = null;
          selectedVillageId = null;
          villages = [];
          villagesList.clear();
          selectedCityPrice = 0;
          couponModel = null;
          activeCode = null;
          update();
        } else if (response.statusCode == 200 || response.statusCode == 201) {
          showCustomSnackBar(
            'تعذر تأكيد الطلب. يرجى إعادة المحاولة دون تغيير السلة.',
            isError: true,
          );
        } else if (response.statusCode == 400) {
          showCustomSnackBar(response.body["message"], isError: true);
        }
        update();
      } catch (e) {
        showCustomSnackBar(e.toString(), isError: true);
      } finally {}
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    _checkoutAttempt.finish(successful: false);
    OverlayLoadingProgress.stop();
  }

  // createOrderWithCode() async {
  //   DateTime now = DateTime.now().toUtc();
  //   String formattedDate = DateFormat(
  //     "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
  //   ).format(now);

  //   if (await CheckInternet.checkInternet()) {
  //     OverlayLoadingProgress.start();
  //     try {
  //       OverlayLoadingProgress.start();
  //       await editeUser();
  //       List<Map> details =
  //           items.map((item) {
  //             totalPriceWithDiscount = 0;
  //             totalPriceWithOutDiscount = 0;
  //             if (item.isSize) {
  //               if (item.itemSizediscount != 0 &&
  //                   item.itemSizediscount != null) {
  //                 totalPriceWithDiscount =
  //                     ((item.count * item.itemSizeColorsprice!) *
  //                         (1 - (item.itemSizediscount! / 100)));
  //                 totalPriceWithOutDiscount =
  //                     (item.count * item.itemSizeColorsprice!);
  //                 totalPriceWithDiscountOrders =
  //                     totalPriceWithDiscountOrders +
  //                     ((item.count * item.itemSizeColorsprice!) *
  //                         (1 - (item.itemSizediscount! / 100)));
  //                 totalPriceWithOutDiscountOrders =
  //                     totalPriceWithOutDiscountOrders +
  //                     (item.count * item.itemSizeColorsprice!);
  //               } else {
  //                 totalPriceWithDiscount =
  //                     (item.count * item.itemSizeColorsprice!);
  //                 totalPriceWithOutDiscount =
  //                     (item.count * item.itemSizeColorsprice!);
  //                 totalPriceWithDiscountOrders =
  //                     totalPriceWithDiscountOrders +
  //                     (item.count * item.itemSizeColorsprice!);
  //                 totalPriceWithOutDiscountOrders =
  //                     totalPriceWithOutDiscountOrders +
  //                     (item.count * item.itemSizeColorsprice!);
  //               }
  //             } else {
  //               if (item.discount > 0) {
  //                 totalPriceWithDiscount =
  //                     ((item.count *
  //                             (token == null
  //                                 ? item.normailPrice
  //                                 : (isNormail
  //                                     ? item.normailPrice
  //                                     : item.wholesalePrice))) *
  //                         (1 - (item.discount / 100)));
  //                 totalPriceWithOutDiscount =
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //                 totalPriceWithDiscountOrders =
  //                     totalPriceWithDiscountOrders +
  //                     ((item.count *
  //                             (token == null
  //                                 ? item.normailPrice
  //                                 : (isNormail
  //                                     ? item.normailPrice
  //                                     : item.wholesalePrice))) *
  //                         (1 - (item.discount / 100)));
  //                 totalPriceWithOutDiscountOrders =
  //                     totalPriceWithOutDiscountOrders +
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //               } else {
  //                 totalPriceWithDiscount =
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //                 totalPriceWithOutDiscount =
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //                 totalPriceWithDiscountOrders =
  //                     totalPriceWithDiscountOrders +
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //                 totalPriceWithOutDiscountOrders =
  //                     totalPriceWithOutDiscountOrders +
  //                     (item.count *
  //                         (token == null
  //                             ? item.normailPrice
  //                             : (isNormail
  //                                 ? item.normailPrice
  //                                 : item.wholesalePrice)));
  //               }
  //             }
  //             return {
  //               "id": 0,
  //               "orderId": 0,
  //               "itemId": item.id,
  //               "isOrderSize": item.isSize,
  //               "itemSizeId": item.isSize ? item.itemSizeId : 'null',
  //               "itemSizeColorId":
  //                   item.isSize ? item.itemSizeColorId.toString() : 'null',
  //               "quantity": item.count,
  //               "itemPrice":
  //                   item.isSize
  //                       ? item.itemSizeColorsprice
  //                       : (token == null
  //                           ? item.normailPrice
  //                           : (isNormail
  //                               ? item.normailPrice
  //                               : item.wholesalePrice)),
  //               "totalPriceWithDiscound": totalPriceWithDiscount.toDouble(),
  //               "totalPriceWithOutDiscound": totalPriceWithOutDiscount,
  //             };
  //           }).toList();
  //       debugPrint("details == $details", wrapWidth: 1024);
  //       var response = await shopRepository.createOrder(
  //         body: {
  //           "id": 0,
  //           "customerId": userModel!.id,
  //           "customerName": nameController.text,
  //           "phoneNum1": phoneNumberController.text,
  //           "phoneNum2": phoneNumber2Controller.text,
  //           "cityId": selectedCityId,
  //           "address": addressController.text,
  //           "status": "New",
  //           "isWholesale":
  //               (userModel!.typeUser).toString() == "Normail" ? false : true,
  //           "priceDelivery": selectedCityPrice,
  //           "totalPriceWithDiscound": totalPriceWithDiscountOrders,
  //           "totalPriceWithOutDiscound": totalPriceWithDiscountOrders,
  //           "discoundCodeId": couponModel!.id,
  //           "discoundCodePercent": couponModel!.discountPercent,
  //           "discoundCode": couponModel!.code,
  //           "totalPriceWithDiscoundCode":
  //               totalPriceWithDiscountOrders *
  //               (1 - (couponModel!.discountPercent / 100)),
  //           "userAddId": userModel!.id,
  //           "dateAdd": formattedDate,
  //           "userUpdate": userModel!.id,
  //           "dateUpdate": formattedDate,
  //           "details": details.toList(),
  //         },
  //       );
  //       if (response.statusCode == 200) {
  //         OrderId = response.body['id'].toString();
  //         Get.toNamed(RouteHelper.checkOutDone);
  //       } else if (response.statusCode == 400) {
  //         showCustomSnackBar(response.body, isError: true);
  //       }
  //       print(response.statusCode);
  //       totalPriceWithDiscountOrders = 0;
  //       totalPriceWithOutDiscountOrders = 0;
  //       totalPriceWithDiscount = 0;
  //       totalPriceWithOutDiscount = 0;
  //       totalPrice = 0;
  //       priceItems = 0;
  //       quantity = 0;
  //       activeCode = null;
  //       selectedCity = null;
  //       selectedCityId = null;
  //       selectedCityPrice = 0;
  //       discoundCodeId = null;
  //       discoundCodePercent = null;
  //       update();
  //       // items = [];
  //       // saveCart();
  //       // clearCart();
  //     } catch (e) {
  //       showCustomSnackBar(e.toString(), isError: true);
  //       print(e);
  //     } finally {}
  //   } else {
  //     OverlayLoadingProgress.stop();
  //     showCustomSnackBar('Check the internet connection'.tr, isError: true);
  //   }
  //   OverlayLoadingProgress.stop();
  // }

  Future<void> checkCode() async {
    final code = discountCodeController.text.trim();
    if (code.isEmpty) {
      couponModel = null;
      activeCode = null;
      showCustomSnackBar('Discount code'.tr, isError: true);
      update();
      return;
    }

    isLoading = true;
    update();
    if (await CheckInternet.checkInternet()) {
      try {
        statusRequest = StatusRequest.loading;
        var response = await shopRepository.checkCode(code);

        if (response.statusCode == 200) {
          couponModel = CouponModel.fromJson(response.body);
          activeCode = couponModel!.isActive;
          if (couponModel!.isActive) {
            showCustomSnackBar("Activated".tr, isError: false);
          } else {
            showCustomSnackBar("Not activated".tr, isError: true);
          }
        } else {
          couponModel = null;
          activeCode = false;
          showCustomSnackBar(
            response.body is Map && response.body["message"] != null
                ? response.body["message"].toString()
                : "Not activated".tr,
            isError: true,
          );
        }
      } catch (e) {
        couponModel = null;
        activeCode = false;
        showCustomSnackBar("Not activated".tr, isError: true);
      } finally {
        isLoading = false;
        update();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    OverlayLoadingProgress.stop();

    isLoading = false;
    update();
  }

  editeUser() async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        if (formstate.currentState!.validate()) {
          if (userModel?.fullName != nameController.text ||
              userModel?.phoneNumber != phoneNumberController.text ||
              userModel?.phoneNumber2 != phoneNumber2Controller.text ||
              userModel?.cityId != selectedCityId ||
              userModel!.address != addressController.text) {
            statusRequest = StatusRequest.loading;
            for (int i = 0; i < cities.length; i++) {
              if (selectedCity == cities[i].cityNameAr ||
                  selectedCity == cities[i].cityNameEng ||
                  selectedCity == cities[i].cityNameAbree) {
                selectedCityId = cities[i].id.toString();
              }
            }
            var response = await shopRepository.userEdit(
              fullName: nameController.text,
              email: emailController.text,
              phoneNumber: phoneNumberController.text,
              phoneNumber2: phoneNumber2Controller.text,
              cityId: selectedCityId,
              address: addressController.text,
              block: userModel!.block,
              typeUser: userModel?.typeUser,
              userUpdate: formattedDate,
              city: selectedCity,
            );
            if (response.statusCode == 200) {
              userModel = UserModel.fromJson(response.body);
              await AppUsageService.saveUserName(userModel!.userName);
              await AppUsageService.saveUserEmail(userModel!.email);
            }
          }
        }
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  loadingToken() async {
    token = await AppUsageService.getToken();
    update();
  }

  @override
  void onInit() {
    cal();
    loadCart();
    loadingToken();
    loadingIsNormail();
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneNumberController = TextEditingController();
    phoneNumber2Controller = TextEditingController();
    addressController = TextEditingController();
    discountCodeController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    phoneNumber2Controller.dispose();
    addressController.dispose();
    discountCodeController.dispose();
    quantity = 0;
    priceItems = 0;
    activeCode = null;
    super.dispose();
  }
}
