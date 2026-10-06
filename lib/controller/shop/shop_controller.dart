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
import '../../core/model/cart_line_model.dart';
import '../../core/model/checkout_flow_model.dart';
import '../../core/model/discount_code_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/shop/shop_repository.dart';
import '../LocalizationController.dart';

class ShopController extends GetxController {
  static const cartStorageKey = 'store_cart_v2';
  static const couponIntentStorageKey = 'store_cart_coupon_intent';
  final CheckoutAttempt _checkoutAttempt = CheckoutAttempt();
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
  RxList<Item> get cartItems => items;
  late bool isNormail;
  String? token;
  String couponIntent = '';

  bool addToCart(Item item) => addItem(item, closeAfterAdd: false);

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
    box.remove(cartStorageKey);
    box.remove('cart');
    update();
  }

  void saveCart() {
    _syncLinesFromItems();
    box.write(
      cartStorageKey,
      cartLines.map((line) => line.toJson()).toList(growable: false),
    );
    box.write(couponIntentStorageKey, couponIntent);
    update();
  }

  void loadCart() {
    final savedLines = box.read<List<dynamic>>(cartStorageKey);
    final restored = <CartLine>[];
    if (savedLines != null) {
      for (final raw in savedLines) {
        try {
          if (raw is! Map) continue;
          restored.add(CartLine.fromJson(Map<String, dynamic>.from(raw)));
        } on FormatException {
          // Invalid/legacy rows fail closed; productId is never a listing fallback.
        } catch (_) {
          // A malformed retained row must not crash app startup.
        }
      }
    } else {
      _migrateLegacyCart();
      return;
    }
    cartLines.assignAll(restored);
    _syncItemsFromLines();
    couponIntent = box.read<String>(couponIntentStorageKey) ?? '';
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
  ShopController({required this.shopRepository, GetStorage? storage})
    : box = storage ?? GetStorage();
  getUserById() async {
    checkoutState = checkoutState.copyWith(stage: CheckoutStage.loadingProfile);
    update();
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

        final resolution = resolveCheckoutRoles(
          userModel?.accountRoles ?? const [],
        );
        checkoutState = CheckoutFlowState(
          stage: CheckoutStage.address,
          selectedRole: resolution.role,
          availableRoles: resolution.availableRoles,
        );
        Get.toNamed(RouteHelper.checkOutScreen);
      } catch (e, stackTrace) {
        checkoutState = const CheckoutFlowState(stage: CheckoutStage.error);
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
    return cartTotal;
  }

  int get cartQuantity =>
      cartLines.fold(0, (total, line) => total + line.quantity);
  double get cartSubtotal =>
      cartLines.fold(0, (total, line) => total + line.subtotal);
  double get cartTotal =>
      cartLines.fold(0, (total, line) => total + line.total);
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
    _syncItemsFromLines();
    cal();
    saveCart();
    showCustomSnackBar('Product added'.tr, isError: false);
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
    discountCodeController.text = couponIntent;
    box.write(couponIntentStorageKey, couponIntent);
    update();
  }

  void _afterCartMutation() {
    _syncItemsFromLines();
    saveCart();
    cal();
    update();
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

  void _migrateLegacyCart() {
    final legacy = box.read<List<dynamic>>('cart');
    final migrated = <CartLine>[];
    for (final raw in legacy ?? const <dynamic>[]) {
      try {
        if (raw is! Map) continue;
        final item = Item.fromJson2(Map<String, dynamic>.from(raw));
        migrated.add(
          CartLine.fromItem(item)..status = CartLineStatus.needsValidation,
        );
      } catch (_) {
        // Legacy lines without a valid listing identity are deliberately dropped.
      }
    }
    cartLines.assignAll(migrated);
    _syncItemsFromLines();
    box.remove('cart');
    saveCart();
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
    if (!_checkoutAttempt.begin()) return;
    final role =
        checkoutState.selectedRole ?? await _resolveCheckoutAccountRole();
    if (role == null || selectedCityId == null || selectedVillageId == null) {
      _checkoutAttempt.finish(successful: false);
      checkoutState = checkoutState.copyWith(
        stage: CheckoutStage.validationError,
        message: 'يرجى استكمال العنوان والشحن ونوع الحساب.',
      );
      update();
      return;
    }
    checkoutState = checkoutState.copyWith(stage: CheckoutStage.submitting);
    update();
    try {
      final online = await CheckInternet.checkInternet();
      if (!online) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.uncertain,
          message: 'تعذر تأكيد وصول الطلب. أعد المحاولة بنفس رقم المحاولة.',
        );
        return;
      }
      final coupon = activeCode == true ? couponModel?.code : null;
      final response = await shopRepository.submitNativeCheckout(
        _checkoutAttempt.attachTo(
          buildNativeCheckoutPayload(
            items: items,
            accountRole: role,
            customerAddress: addressController.text,
            shiplyCityId: int.parse(selectedCityId!),
            shiplyVillageId: int.parse(selectedVillageId!),
            couponCode: coupon,
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
        checkoutState = CheckoutFlowState(
          stage: CheckoutStage.success,
          orderId: success.orderId,
          replayed: success.replayed,
          selectedRole: role,
          availableRoles: checkoutState.availableRoles,
        );
        clearCart();
        Get.offNamed(RouteHelper.checkOutDone);
        return;
      }
      if (response.statusCode == 422 || response.statusCode == 400) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.validationError,
          validationKind: classifyCheckoutValidation(response.body),
          message: 'تعذر اعتماد بعض بيانات الطلب. راجع البيانات وحاول مجددًا.',
        );
      } else if (response.statusCode == 200 || response.statusCode == 201) {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.uncertain,
          message: 'وصل رد غير مكتمل. أعد المحاولة بنفس رقم المحاولة.',
        );
      } else {
        checkoutState = checkoutState.copyWith(
          stage: CheckoutStage.error,
          message: 'تعذر إتمام الطلب. لم يتم مسح السلة.',
        );
      }
    } catch (_) {
      checkoutState = checkoutState.copyWith(
        stage: CheckoutStage.uncertain,
        message: 'قد يكون الطلب وصل إلى الخادم. أعد المحاولة للتحقق.',
      );
    } finally {
      if (checkoutState.stage != CheckoutStage.success) {
        _checkoutAttempt.finish(successful: false);
      }
      update();
    }
  }

  createOrder() => submitCheckout();

  // ignore: unused_element
  _legacyCreateOrder() async {
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

  createOrderWithCode() => submitCheckout();

  // ignore: unused_element
  _legacyCreateOrderWithCode() async {
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
