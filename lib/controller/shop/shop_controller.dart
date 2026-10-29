// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/functions/store_session_boundary.dart';
import '../../core/functions/store_cart_storage.dart';
import '../../core/functions/store_address_book.dart';
import '../../core/functions/store_delivery_quotes.dart';

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
import '../../core/model/cart_line_model.dart';
import '../../core/model/checkout_flow_model.dart';
import '../../core/model/discount_code_model.dart';
import '../../core/model/store_address_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/shop/shop_repository.dart';
import '../LocalizationController.dart';
import '../order/order_controller.dart';

class ShopController extends GetxController with StoreSessionAware {
  static const cartStorageKey = StoreCartStorage.cartKey;
  static const couponIntentStorageKey = StoreCartStorage.couponKey;
  late final StoreCartStorage _cartStorage = StoreCartStorage(box);
  late final StoreAddressBook _addressBook = StoreAddressBook(
    shopRepository.getStoreAddresses,
  );
  late final StoreDeliveryQuotes _deliveryQuotes = StoreDeliveryQuotes(
    shopRepository.calculateDeliveryFee,
  );
  CheckoutAttempt _checkoutAttempt = CheckoutAttempt();
  CheckoutFlowState checkoutState = const CheckoutFlowState();
  CheckoutPaymentCapability get paymentCapability =>
      CheckoutPaymentCapability.cash;
  String? get checkoutAttemptId => _checkoutAttempt.currentId;
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  final GetStorage box;
  final RxList<CartLine> cartLines = <CartLine>[].obs;
  final RxList<Item> items = <Item>[].obs;
  List<CartLine>? _buyNowCheckoutLines;
  RxList<Item> get cartItems => items;
  bool get isBuyNowCheckout => _buyNowCheckoutLines != null;
  List<CartLine> get checkoutLines =>
      List<CartLine>.unmodifiable(_buyNowCheckoutLines ?? cartLines);
  late bool isNormail;
  String? token;
  String couponIntent = '';

  bool addToCart(Item item) => addItem(item, closeAfterAdd: false);

  bool containsItem(Item item) {
    try {
      final identity = CartLineIdentity.fromItem(item);
      return cartLines.any((line) => line.identity == identity);
    } on FormatException {
      return false;
    }
  }

  int quantityFor(Item item) {
    try {
      final identity = CartLineIdentity.fromItem(item);
      return cartLines
              .firstWhereOrNull((line) => line.identity == identity)
              ?.quantity ??
          0;
    } on FormatException {
      return 0;
    }
  }

  loadingIsNormail() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    update();
  }

  void removeFromCart(Item item) {
    try {
      removeLine(CartLineIdentity.fromItem(item));
    } on FormatException {
      return;
    }
  }

  void clearCart() {
    cartLines.clear();
    items.clear();
    selectedVillage = null;
    selectedVillageId = null;
    selectedCityPrice = 0;
    hasAuthoritativeDeliveryQuote = false;
    deliveryQuoteMessage = null;
    couponIntent = '';
    couponModel = null;
    activeCode = null;
    if (discountCodeController.text.isNotEmpty) {
      discountCodeController.clear();
    }
    box.remove(cartStorageKey);
    box.remove('cart');
    box.remove(couponIntentStorageKey);
    update();
  }

  void saveCart() {
    _syncLinesFromItems();
    _cartStorage.save(cartLines, couponIntent);
    update();
  }

  void loadCart() {
    final snapshot = _cartStorage.load();
    cartLines.assignAll(snapshot.lines);
    _syncItemsFromLines();
    couponIntent = snapshot.couponIntent;
  }

  Future<void> refreshCart() async {
    loadCart();
    cal();
    update();
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

  bool isLoading = false;
  bool isVillagesLoading = false;
  bool isDeliveryLoading = false;
  bool hasAuthoritativeDeliveryQuote = false;
  String? deliveryQuoteMessage;
  bool? activeCode;
  List<Citys> cities = [];
  List<String> citiesList = [];
  List<ShiplyVillage> villages = [];
  List<String> villagesList = [];
  List<StoreAddress> checkoutAddresses = const [];
  StoreAddress? selectedStoreAddress;
  bool checkoutAddressesLoading = false;
  String? checkoutAddressesMessage;
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
  ShopController({required this.shopRepository, GetStorage? storage})
    : box = storage ?? GetStorage();

  @override
  void clearSessionData() {
    _checkoutAttempt = CheckoutAttempt();
    checkoutState = const CheckoutFlowState();
    couponModel = null;
    activeCode = null;
    discoundCodeId = null;
    discoundCodePercent = null;
    token = null;
    userModel = null;
    checkoutAddresses = const [];
    selectedStoreAddress = null;
    selectedVillage = null;
    selectedVillageId = null;
    selectedCity = null;
    selectedCityId = null;
    checkoutAddressesLoading = false;
    checkoutAddressesMessage = null;
    _buyNowCheckoutLines = null;
    _invalidateDeliveryQuote();
    for (final field in [
      nameController,
      emailController,
      phoneNumberController,
      phoneNumber2Controller,
      addressController,
    ]) {
      field.clear();
    }
    update();
  }

  Future<void> getUserById() async {
    _buyNowCheckoutLines = null;
    await _openCheckout();
  }

  bool prepareBuyNowCheckout(Item item) {
    try {
      _buyNowCheckoutLines = <CartLine>[CartLine.fromItem(item)];
      _invalidateDeliveryQuote();
      update();
      return true;
    } on FormatException {
      showCustomSnackBar('storeCartInvalidListing'.tr, isError: true);
      return false;
    }
  }

  bool startBuyNowCheckout(Item item) {
    if (!prepareBuyNowCheckout(item)) return false;
    unawaited(_openPreparedBuyNowCheckout());
    return true;
  }

  Future<void> _openPreparedBuyNowCheckout() async {
    if (await _openCheckout()) return;
    _buyNowCheckoutLines = null;
    update();
  }

  Future<bool> _openCheckout() async {
    final generation = sessionGeneration;
    checkoutAddresses = const [];
    selectedStoreAddress = null;
    checkoutAddressesMessage = null;
    selectedVillage = null;
    selectedVillageId = null;
    _invalidateDeliveryQuote();
    checkoutState = checkoutState.copyWith(stage: CheckoutStage.loadingProfile);
    update();
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await shopRepository.getUser();
        var responseCity = await shopRepository.getCity();
        if (!sessionIsCurrent(generation)) return false;
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
          await loadCheckoutAddresses(notify: false);
          if (selectedStoreAddress == null && selectedCityId != null) {
            await loadVillagesForSelectedCity();
          }
        }

        final resolution = resolveCheckoutRoles(
          userModel?.accountRoles ?? const [],
        );
        checkoutState = CheckoutFlowState(
          stage: CheckoutStage.address,
          selectedRole: resolution.role,
          availableRoles: resolution.availableRoles,
        );
        Get.toNamed(RouteHelper.checkOutScreen);
        return true;
      } catch (e, stackTrace) {
        checkoutState = const CheckoutFlowState(stage: CheckoutStage.error);
        debugPrint('[STORE_CHECKOUT] getUserById error=$e');
        debugPrint('[STORE_CHECKOUT] getUserById stack=$stackTrace');
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        return false;
      } finally {
        OverlayLoadingProgress.stop();
      }
    } else {
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
      return false;
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
    selectedStoreAddress = null;
    selectedCityId = city.id.toString();
    selectedCity =
        localizationController.locale.languageCode == 'ar'
            ? city.cityNameAr
            : localizationController.locale.languageCode == 'en'
            ? city.cityNameEng
            : city.cityNameAbree;
    selectedCityPrice = 0;
    hasAuthoritativeDeliveryQuote = false;
    deliveryQuoteMessage = null;
    selectedVillage = null;
    selectedVillageId = null;
    villages = [];
    villagesList.clear();
    isVillagesLoading = true;
    update();
    await loadVillagesForSelectedCity();
  }

  Future<void> onVillageSelected(ShiplyVillage village) async {
    selectedStoreAddress = null;
    selectedVillage = village.name;
    selectedVillageId = village.id.toString();
    selectedCityPrice = 0;
    hasAuthoritativeDeliveryQuote = false;
    deliveryQuoteMessage = null;
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

  Future<void> loadCheckoutAddresses({bool notify = true}) async {
    final generation = sessionGeneration;
    checkoutAddressesLoading = true;
    checkoutAddressesMessage = null;
    if (notify) update();
    try {
      final addresses = await _addressBook.load();
      if (!sessionIsCurrent(generation)) return;
      checkoutAddresses = addresses;
      selectedStoreAddress = null;
      final preferred = StoreAddressBook.preferred(checkoutAddresses);
      if (preferred != null) {
        await selectCheckoutAddress(preferred, notify: false);
      }
    } catch (_) {
      if (!sessionIsCurrent(generation)) return;
      checkoutAddressesMessage = 'تعذر تحميل العناوين المحفوظة.'.tr;
    } finally {
      checkoutAddressesLoading = false;
      if (notify) update();
    }
  }

  Future<void> selectCheckoutAddress(
    StoreAddress address, {
    bool notify = true,
  }) async {
    if (!address.isDeliveryReady) {
      checkoutAddressesMessage =
          'هذا العنوان غير مكتمل. عدّله وحدد المدينة والقرية.'.tr;
      if (notify) update();
      return;
    }
    selectedStoreAddress = address;
    addressController.text = address.streetAddress;
    selectedCityId = address.shiplyCityId.toString();
    selectedCity = address.shiplyCityName;
    selectedVillageId = address.shiplyVillageId.toString();
    selectedVillage = address.shiplyVillageName;
    await loadVillagesForSelectedCity();
    await calculateDeliveryFeeForSelectedVillage();
    if (notify) update();
  }

  void onCheckoutAddressTextChanged(String value) {
    if (selectedStoreAddress != null &&
        value.trim() != selectedStoreAddress!.streetAddress.trim()) {
      selectedStoreAddress = null;
      update();
    }
  }

  Future<void> calculateDeliveryFeeForSelectedVillage() async {
    if (selectedVillageId == null) return;
    final request = _deliveryQuotes.begin();
    final village = selectedVillageId;
    final price = deliveryQuotePrice();
    hasAuthoritativeDeliveryQuote = false;
    selectedCityPrice = 0;
    deliveryQuoteMessage = null;
    isDeliveryLoading = true;
    update();
    final quotedPrice = await _deliveryQuotes.quote(
      villageId: village!,
      price: price,
    );
    if (!_deliveryQuotes.isCurrent(request)) return;
    isDeliveryLoading = false;
    if (selectedVillageId != village || deliveryQuotePrice() != price) {
      update();
      return;
    }
    if (quotedPrice != null) {
      selectedCityPrice = quotedPrice;
      hasAuthoritativeDeliveryQuote = true;
    } else {
      deliveryQuoteMessage = 'storeDeliveryQuoteUnavailable'.tr;
    }
    update();
  }

  double deliveryQuotePrice() {
    return checkoutTotal;
  }

  int get cartQuantity =>
      cartLines.fold(0, (total, line) => total + line.quantity);
  double get cartSubtotal =>
      cartLines.fold(0, (total, line) => total + line.subtotal);
  double get cartTotal =>
      cartLines.fold(0, (total, line) => total + line.total);
  double get appliedCouponDiscount =>
      activeCode == true ? couponModel?.discountAmount ?? 0 : 0;
  double get cartTotalAfterCoupon {
    final payable = cartTotal - appliedCouponDiscount;
    return payable < 0 ? 0 : payable;
  }

  int get checkoutQuantity =>
      checkoutLines.fold(0, (total, line) => total + line.quantity);
  double get checkoutSubtotal =>
      checkoutLines.fold(0, (total, line) => total + line.subtotal);
  double get checkoutTotal =>
      checkoutLines.fold(0, (total, line) => total + line.total);
  bool get checkoutHasCoupon =>
      !isBuyNowCheckout && activeCode == true && couponModel != null;
  double get checkoutAppliedCouponDiscount =>
      checkoutHasCoupon ? couponModel?.discountAmount ?? 0 : 0;
  double get checkoutTotalAfterCoupon {
    final payable = checkoutTotal - checkoutAppliedCouponDiscount;
    return payable < 0 ? 0 : payable;
  }

  List<Item> get checkoutItems => checkoutLines
      .map((line) {
        line.itemSnapshot.count = line.quantity;
        return line.itemSnapshot;
      })
      .toList(growable: false);

  bool get canCheckout =>
      cartLines.isNotEmpty && cartLines.every((line) => line.structurallyValid);

  void cal() {
    quantity = cartQuantity;
    priceItems = cartSubtotal;
    totalPrice = cartTotal;
  }

  void deletItem(dynamic id) {
    final line = cartLines.firstWhereOrNull(
      (line) => line.identity.listingId == id,
    );
    if (line != null) removeLine(line.identity);
  }

  bool addItem(Item item, {bool closeAfterAdd = true}) {
    late final CartLine candidate;
    try {
      candidate = CartLine.fromItem(item);
    } on FormatException {
      showCustomSnackBar('storeCartInvalidListing'.tr, isError: true);
      return false;
    }
    final index = cartLines.indexWhere(
      (line) => line.identity == candidate.identity,
    );
    if (index >= 0) {
      final maximum = cartLines[index].knownAvailableQuantity;
      final requested = cartLines[index].quantity + candidate.quantity;
      cartLines[index].quantity =
          maximum == null ? requested : requested.clamp(1, maximum);
    } else {
      cartLines.add(candidate);
    }
    _invalidateDeliveryQuote();
    _syncItemsFromLines();
    cal();
    saveCart();
    showCustomSnackBar(
      'Product added'.tr,
      isError: false,
      title: 'storeFeedbackAddedTitle'.tr,
      actionLabel: 'storeViewCart'.tr,
      onAction: () => Get.toNamed(RouteHelper.cartScreen),
    );
    if (closeAfterAdd && Get.key.currentState?.canPop() == true) Get.back();
    update();
    return true;
  }

  void add(dynamic identity) {
    final line = _resolveLine(identity);
    if (line != null) incrementLine(line.identity);
  }

  void mins(dynamic identity) {
    final line = _resolveLine(identity);
    if (line != null) decrementLine(line.identity);
  }

  bool incrementLine(CartLineIdentity identity) {
    final line = cartLines.firstWhereOrNull(
      (line) => line.identity == identity,
    );
    if (line == null) return false;
    final maximum = line.knownAvailableQuantity;
    if (maximum != null && line.quantity >= maximum) return false;
    line.quantity++;
    _afterCartMutation();
    return true;
  }

  bool decrementLine(CartLineIdentity identity) {
    final line = cartLines.firstWhereOrNull(
      (line) => line.identity == identity,
    );
    if (line == null || line.quantity <= 1) return false;
    line.quantity--;
    _afterCartMutation();
    return true;
  }

  bool setLineQuantity(CartLineIdentity identity, int value) {
    final line = cartLines.firstWhereOrNull(
      (line) => line.identity == identity,
    );
    if (line == null || value < 1) return false;
    final maximum = line.knownAvailableQuantity;
    if (maximum != null && value > maximum) return false;
    line.quantity = value;
    _afterCartMutation();
    return true;
  }

  void removeLine(CartLineIdentity identity) {
    cartLines.removeWhere((line) => line.identity == identity);
    _afterCartMutation();
  }

  void retainCouponIntent(String value) {
    couponIntent = value.trim();
    if (couponModel?.code.trim().toUpperCase() != couponIntent.toUpperCase()) {
      couponModel = null;
      activeCode = null;
    }
    box.write(couponIntentStorageKey, couponIntent);
    update();
  }

  void _afterCartMutation() {
    _invalidateDeliveryQuote();
    couponModel = null;
    activeCode = null;
    _syncItemsFromLines();
    saveCart();
    cal();
    update();
  }

  void _invalidateDeliveryQuote() {
    _deliveryQuotes.invalidate();
    isDeliveryLoading = false;
    selectedCityPrice = 0;
    hasAuthoritativeDeliveryQuote = false;
    deliveryQuoteMessage = null;
  }

  CartLine? _resolveLine(dynamic identity) {
    if (identity is CartLineIdentity) {
      return cartLines.firstWhereOrNull((line) => line.identity == identity);
    }
    if (identity is int) {
      return cartLines.firstWhereOrNull(
        (line) => line.identity.listingId == identity,
      );
    }
    return null;
  }

  void _syncItemsFromLines() {
    items.assignAll(
      cartLines.map((line) {
        line.itemSnapshot.count = line.quantity;
        return line.itemSnapshot;
      }),
    );
  }

  void _syncLinesFromItems() {
    for (final item in items) {
      try {
        final identity = CartLineIdentity.fromItem(item);
        final line = cartLines.firstWhereOrNull(
          (line) => line.identity == identity,
        );
        if (line != null) line.quantity = item.count;
      } on FormatException {
        continue;
      }
    }
  }

  Future<String?> _resolveCheckoutAccountRole() async {
    if (userModel == null) {
      final response = await shopRepository.getUser();
      if (response.statusCode != 200 ||
          response.body is! Map<String, dynamic>) {
        showCustomSnackBar(
          'تعذر تحديث بيانات حساب المتجر. يرجى المحاولة مرة أخرى.'.tr,
          isError: true,
        );
        return null;
      }
      userModel = UserModel.fromJson(response.body);
    }

    final resolution = resolveCheckoutRoles(userModel!.accountRoles);
    if (resolution.requirement == CheckoutRoleRequirement.unavailable) {
      showCustomSnackBar(
        'لا يوجد حساب بيع معتمد مرتبط بحساب المتجر. يرجى التواصل مع الإدارة.'
            .tr,
        isError: true,
      );
      return null;
    }
    if (resolution.requirement == CheckoutRoleRequirement.resolved) {
      return resolution.role;
    }

    final selectedRole = await Get.dialog<String>(
      AlertDialog(
        title: Text('اختر نوع الطلب'.tr),
        content: Text('هل تريد تنفيذ الطلب كتجزئة أم جملة؟'.tr),
        actions: [
          TextButton(onPressed: Get.back, child: Text('إلغاء'.tr)),
          TextButton(
            onPressed: () => Get.back(result: 'customer'),
            child: Text('تجزئة'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: 'seller'),
            child: Text('جملة'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
    return confirmCheckoutRole(resolution, selectedRole);
  }

  void setCheckoutStage(CheckoutStage stage) {
    checkoutState = checkoutState.copyWith(stage: stage);
    update();
  }

  void selectCheckoutRole(String role) {
    if (!checkoutState.availableRoles.contains(role)) return;
    checkoutState = checkoutState.copyWith(selectedRole: role);
    update();
  }

  Future<void> submitCheckout() async {
    final generation = sessionGeneration;
    if (!_checkoutAttempt.begin()) return;
    if (!hasAuthoritativeDeliveryQuote || isDeliveryLoading) {
      _checkoutAttempt.finish(successful: false);
      checkoutState = checkoutState.copyWith(
        stage: CheckoutStage.validationError,
        message: 'storeDeliveryQuoteUnavailable'.tr,
      );
      update();
      return;
    }
    final role =
        checkoutState.selectedRole ?? await _resolveCheckoutAccountRole();
    if (!sessionIsCurrent(generation)) return;
    if (role == null || selectedCityId == null || selectedVillageId == null) {
      _checkoutAttempt.finish(successful: false);
      checkoutState = checkoutState.copyWith(
        stage: CheckoutStage.validationError,
        message: 'يرجى استكمال العنوان والشحن ونوع الحساب.'.tr,
      );
      update();
      return;
    }
    checkoutState = checkoutState.copyWith(stage: CheckoutStage.submitting);
    update();
    try {
      final coupon = checkoutHasCoupon ? couponModel?.code : null;
      final transport = await runCheckoutTransport(
        connectivityCheck:
            () async => await CheckInternet.checkInternet() == true,
        submit: () {
          if (!sessionIsCurrent(generation)) {
            throw StateError('Session changed');
          }
          return shopRepository.submitNativeCheckout(
            _checkoutAttempt.attachTo(
              buildNativeCheckoutPayload(
                items: checkoutItems,
                accountRole: role,
                customerAddress: addressController.text,
                shiplyCityId: int.parse(selectedCityId!),
                shiplyVillageId: int.parse(selectedVillageId!),
                partnerAddressId:
                    role == 'customer' ? selectedStoreAddress?.id : null,
                couponCode: coupon,
              ),
            ),
          );
        },
      );
      if (!sessionIsCurrent(generation)) return;
      if (transport.kind == CheckoutTransportKind.offline) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.offline,
          message:
              'لا يوجد اتصال بالإنترنت. تحقق من الاتصال ثم أعد المحاولة.'.tr,
        );
        return;
      }
      if (transport.kind == CheckoutTransportKind.uncertain) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.uncertain,
          message: 'قد يكون الطلب وصل إلى الخادم. أعد المحاولة للتحقق.'.tr,
        );
        return;
      }
      final response = transport.response!;
      final success = completeCheckoutAttempt(
        _checkoutAttempt,
        response.statusCode,
        response.body,
      );
      if (success != null) {
        OrderId = success.orderId;
        checkoutState = CheckoutFlowState(
          stage: CheckoutStage.success,
          orderId: success.orderId,
          orderNumber: success.orderNumber,
          replayed: success.replayed,
          selectedRole: role,
          availableRoles: checkoutState.availableRoles,
        );
        if (isBuyNowCheckout) {
          _buyNowCheckoutLines = null;
          update();
        } else {
          clearCart();
        }
        if (Get.isRegistered<OrderController>()) {
          unawaited(
            Get.find<OrderController>().load(filter: OrderListFilter.current),
          );
        }
        Get.offNamed(RouteHelper.checkOutDone);
        return;
      }
      if (response.statusCode == 422 || response.statusCode == 400) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.validationError,
          validationKind: classifyCheckoutValidation(response.body),
          message:
              'تعذر اعتماد بعض بيانات الطلب. راجع البيانات وحاول مجددًا.'.tr,
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.uncertain,
          message: 'وصل رد غير مكتمل. أعد المحاولة بنفس رقم المحاولة.'.tr,
        );
      } else {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.error,
          message: 'تعذر إتمام الطلب. لم يتم تغيير السلة.'.tr,
        );
      }
    } catch (_) {
      if (!sessionIsCurrent(generation)) return;
      checkoutState = checkoutState.copyWith(
        stage: CheckoutStage.uncertain,
        message: 'قد يكون الطلب وصل إلى الخادم. أعد المحاولة للتحقق.'.tr,
      );
    } finally {
      if (sessionIsCurrent(generation)) {
        if (checkoutState.stage != CheckoutStage.success) {
          _checkoutAttempt.finish(successful: false);
        }
        update();
      }
    }
  }

  createOrder() => submitCheckout();

  createOrderWithCode() => submitCheckout();

  Future<void> checkCode() async {
    final code = discountCodeController.text.trim();
    if (code.isEmpty) {
      couponModel = null;
      activeCode = null;
      showCustomSnackBar('Discount code'.tr, isError: true);
      update();
      return;
    }

    if (!canCheckout) {
      showCustomSnackBar('أضف منتجًا صالحًا للسلة أولًا.'.tr, isError: true);
      return;
    }

    final role =
        checkoutState.selectedRole ?? await _resolveCheckoutAccountRole();
    if (role == null) return;
    checkoutState = checkoutState.copyWith(selectedRole: role);
    isLoading = true;
    update();
    if (await CheckInternet.checkInternet()) {
      try {
        statusRequest = StatusRequest.loading;
        final response = await shopRepository.checkCode(
          code,
          accountRole: role,
          items: cartLines
              .map(
                (line) => {
                  'listing_id': line.identity.listingId,
                  'size_id': line.identity.sizeId,
                  'size_color_id': line.identity.sizeColorId,
                  'quantity': line.quantity,
                },
              )
              .toList(growable: false),
        );

        if (response.statusCode == 200 &&
            response.body is Map &&
            response.body['data'] is Map &&
            response.body['data']['coupon'] is Map) {
          final data = Map<String, dynamic>.from(response.body['data']);
          couponModel = CouponModel.fromJson(
            Map<String, dynamic>.from(data['coupon']),
            discountAmount: (data['coupon_discount'] as num?)?.toDouble() ?? 0,
          );
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
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneNumberController = TextEditingController();
    phoneNumber2Controller = TextEditingController();
    addressController = TextEditingController();
    discountCodeController = TextEditingController();
    loadCart();
    discountCodeController.text = couponIntent;
    cal();
    loadingToken();
    loadingIsNormail();
    super.onInit();
  }

  @override
  void onClose() {
    _deliveryQuotes.invalidate();
    emailController.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    phoneNumber2Controller.dispose();
    addressController.dispose();
    discountCodeController.dispose();
    quantity = 0;
    priceItems = 0;
    activeCode = null;
    super.onClose();
  }
}
