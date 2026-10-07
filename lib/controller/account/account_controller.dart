// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print, deprecated_member_use, unrelated_type_equality_checks
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/functions/theme_services.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/city_model.dart';
import '../../core/model/conact_us_model.dart';
import '../../core/model/orders_model.dart';
import '../../core/model/store_address_model.dart';
import '../../core/model/user_data_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../LocalizationController.dart';
import '../order/order_controller.dart';
import 'package:intl/intl.dart';

enum AccountViewStatus { guest, initial, loading, content, offline, error }

enum AccountMutationStatus { idle, submitting, success, failure }

typedef ConnectivityChecker = Future<bool> Function();

Future<bool> _defaultConnectivityChecker() async =>
    await CheckInternet.checkInternet() == true;

Uri? safeHttpUri(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  if (uri == null || !uri.hasAuthority) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

bool isValidAccountDeletionResponse(Response response) =>
    response.statusCode == 200 &&
    response.body is Map &&
    response.body['message'] == 'success';

Map<String, Object?> profileEditPayload({
  required String fullName,
  required String email,
  required String phoneNumber,
  required String phoneNumber2,
  required String address,
  required String cityId,
}) => <String, Object?>{
  'fullName': fullName,
  'email': email,
  'phoneNumber': phoneNumber,
  'phoneNumber2': phoneNumber2,
  'address': address,
  'cityId': cityId,
};

abstract class AccountController extends GetxController {
  getUserById({bool navigate});
  editeUser();
  getAllOrders();
  getConactUs();
  editAllOrders({required Order order});
  changePassword();
  getConactUsAccount();
}

class AccountControllerImp extends AccountController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late bool isDarkMode;
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  bool isNormail = AppUsageService.getTypeUser() == "Normail";
  String? token;
  CitiesResponse? citiesResponse;
  ApiResponse? conactUsModel;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController phoneNumber2Controller;
  late TextEditingController addressController;
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  String? selectedCity; // Default selected city
  String? selectedCityId; // Default selected city
  int selectedCondition = 0;
  List<Citys> cities = [];
  List<String> citiesList = [];
  UserModel? userModel;
  UserModel? get profile => userModel;
  AccountViewStatus profileStatus = AccountViewStatus.initial;
  AccountMutationStatus mutationStatus = AccountMutationStatus.idle;
  String? message;
  List<StoreAddress> addresses = const [];
  bool addressesLoading = false;
  String? addressesMessage;
  final AuthRepository authRepository;
  final ConnectivityChecker connectivityChecker;
  late StatusRequest statusRequest;
  AccountControllerImp({
    required this.authRepository,
    ConnectivityChecker? connectivityChecker,
    bool? initialDarkMode,
  }) : connectivityChecker = connectivityChecker ?? _defaultConnectivityChecker,
       isDarkMode = initialDarkMode ?? ThemeServices().loadThemeFromBox();
  @override
  getUserById({bool navigate = true}) async {
    token = await AppUsageService.getToken();
    if (token == null || token!.isEmpty) {
      profileStatus = AccountViewStatus.guest;
      userModel = null;
      update();
      return;
    }
    if (await CheckInternet.checkInternet()) {
      try {
        statusRequest = StatusRequest.loading;
        profileStatus = AccountViewStatus.loading;
        message = null;
        update();
        var response = await authRepository.getUser();
        var responseCity = await authRepository.getCity();
        if (response.statusCode == 200 &&
            response.body is Map<String, dynamic>) {
          userModel = UserModel.fromJson(response.body);
          if (userModel!.id.isEmpty) throw const FormatException('profile');
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
          profileStatus = AccountViewStatus.content;
        } else {
          profileStatus = AccountViewStatus.error;
          message = 'تعذر تحميل بيانات الحساب';
        }

        if (responseCity.statusCode == 200 && userModel != null) {
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
            }
          }
          createListCity();
        }

        if (navigate) {
          Get.toNamed(RouteHelper.personalDetailsPage);
        } else {
          update();
        }
      } catch (e) {
        profileStatus = AccountViewStatus.error;
        message = 'تعذر تحميل بيانات الحساب';
        update();
      } finally {
        update();
      }
    } else {
      profileStatus = AccountViewStatus.offline;
      message = 'Check the internet connection'.tr;
      update();
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
    update();
  }

  @override
  editeUser() async {
    if (await connectivityChecker()) {
      try {
        mutationStatus = AccountMutationStatus.submitting;
        message = null;
        update();
        if (userModel!.fullName != nameController.text ||
            userModel!.email != emailController.text ||
            userModel!.phoneNumber != phoneNumberController.text ||
            userModel!.phoneNumber2 != phoneNumber2Controller.text ||
            userModel!.cityId?.toString() != selectedCityId ||
            userModel!.address != addressController.text) {
          statusRequest = StatusRequest.loading;
          for (int i = 0; i < cities.length; i++) {
            if (selectedCity == cities[i].cityNameAr ||
                selectedCity == cities[i].cityNameEng ||
                selectedCity == cities[i].cityNameAbree) {
              selectedCityId = cities[i].id.toString();
            }
          }
          var response = await authRepository.userEdit(
            fullName: nameController.text,
            email: emailController.text,
            phoneNumber: phoneNumberController.text,
            phoneNumber2: phoneNumber2Controller.text,
            cityId: selectedCityId.toString(),
            address: addressController.text,
          );
          if (response.statusCode == 200 &&
              response.body is Map<String, dynamic>) {
            final authoritative = UserModel.fromJson(response.body);
            if (authoritative.id.isEmpty) {
              throw const FormatException('profile');
            }
            userModel = authoritative;
            mutationStatus = AccountMutationStatus.success;
            profileStatus = AccountViewStatus.content;
            _populateProfile(authoritative);
            await AppUsageService.saveUserName(authoritative.fullName ?? '');
            await AppUsageService.saveUserEmail(authoritative.email);
            showCustomSnackBar(
              "Account information has been updated".tr,
              isError: false,
            );
          } else {
            mutationStatus = AccountMutationStatus.failure;
            message = 'تعذر حفظ بيانات الحساب';
          }
        } else {
          mutationStatus = AccountMutationStatus.idle;
        }
      } catch (e) {
        mutationStatus = AccountMutationStatus.failure;
        message = 'تعذر حفظ بيانات الحساب';
      } finally {
        update();
      }
    } else {
      mutationStatus = AccountMutationStatus.failure;
      message = 'Check the internet connection'.tr;
      update();
    }
  }

  void _populateProfile(UserModel value) {
    nameController.text = value.fullName ?? '';
    emailController.text = value.email;
    phoneNumberController.text = value.phoneNumber ?? '';
    phoneNumber2Controller.text = value.phoneNumber2 ?? '';
    addressController.text = value.address ?? '';
    selectedCityId = value.cityId?.toString();
  }

  Future<void> logout({required bool confirmed}) async {
    if (!confirmed) return;
    await _clearSession();
  }

  Future<bool> deactivateAccount({required bool confirmed}) async {
    if (!confirmed) return false;
    mutationStatus = AccountMutationStatus.submitting;
    update();
    try {
      final response = await authRepository.deleteUserAccount();
      final valid = isValidAccountDeletionResponse(response);
      if (!valid) {
        mutationStatus = AccountMutationStatus.failure;
        update();
        return false;
      }
      await _clearSession();
      mutationStatus = AccountMutationStatus.success;
      update();
      return true;
    } catch (_) {
      mutationStatus = AccountMutationStatus.failure;
      update();
      return false;
    }
  }

  Future<void> _clearSession() async {
    await Future.wait([
      AppUsageService.deleteIsLogin(),
      AppUsageService.deleteToken(),
      AppUsageService.deleteUserId(),
      AppUsageService.deleteUserName(),
      AppUsageService.deleteUserEmail(),
      AppUsageService.deleteTypeUser(),
    ]);
    token = null;
    userModel = null;
    profileStatus = AccountViewStatus.guest;
    update();
  }

  Future<bool> deleteUserAccount() => deactivateAccount(confirmed: true);

  Future<void> loadAddresses() async {
    addressesLoading = true;
    addressesMessage = null;
    update();
    try {
      final response = await authRepository.getStoreAddresses();
      if (response.statusCode != 200 || response.body is! Map) {
        throw const FormatException('store addresses');
      }
      final raw = (response.body as Map)['data'];
      if (raw is! List) throw const FormatException('store addresses data');
      addresses = raw
          .whereType<Map>()
          .map((row) => StoreAddress.fromJson(Map<String, dynamic>.from(row)))
          .where((address) => address.id > 0)
          .toList(growable: false);
    } catch (_) {
      addressesMessage = 'تعذر تحميل العناوين.';
    } finally {
      addressesLoading = false;
      update();
    }
  }

  Future<bool> saveAddress({
    StoreAddress? current,
    required String label,
    required String streetAddress,
    String? phone,
    bool isDefault = false,
  }) async {
    final cleanLabel = label.trim();
    final cleanStreet = streetAddress.trim();
    if (cleanLabel.isEmpty || cleanStreet.isEmpty) {
      addressesMessage = 'اسم العنوان وتفاصيله مطلوبان.';
      update();
      return false;
    }
    addressesLoading = true;
    addressesMessage = null;
    update();
    try {
      final body = <String, dynamic>{
        if (current != null) 'address_id': current.id,
        'label': cleanLabel,
        'street_address': cleanStreet,
        'phone': phone?.trim().isEmpty == true ? null : phone?.trim(),
        'city_id': current?.cityId ?? userModel?.cityId,
        'shiply_city_id': current?.shiplyCityId,
        'shiply_village_id': current?.shiplyVillageId,
        'shiply_city_name': current?.shiplyCityName,
        'shiply_village_name': current?.shiplyVillageName,
        'delivery_notes': current?.deliveryNotes,
        'is_default': isDefault,
      };
      final response =
          current == null
              ? await authRepository.createStoreAddress(body)
              : await authRepository.updateStoreAddress(body);
      if ((current == null && response.statusCode != 201) ||
          (current != null && response.statusCode != 200)) {
        throw const FormatException('save store address');
      }
      await loadAddresses();
      final defaultAddress = addresses.firstWhereOrNull(
        (address) => address.isDefault,
      );
      if (defaultAddress != null) {
        userModel?.address = defaultAddress.streetAddress;
        addressController.text = defaultAddress.streetAddress;
      }
      showCustomSnackBar(
        current == null ? 'تمت إضافة العنوان بنجاح.' : 'تم تحديث العنوان.',
        isError: false,
      );
      return true;
    } catch (_) {
      addressesMessage = 'تعذر حفظ العنوان.';
      addressesLoading = false;
      update();
      showCustomSnackBar(addressesMessage, isError: true);
      return false;
    }
  }

  Future<bool> makeDefaultAddress(StoreAddress address) => saveAddress(
    current: address,
    label: address.label,
    streetAddress: address.streetAddress,
    phone: address.phone,
    isDefault: true,
  );

  Future<bool> deleteAddress(StoreAddress address) async {
    addressesLoading = true;
    addressesMessage = null;
    update();
    try {
      final response = await authRepository.deleteStoreAddress(address.id);
      if (response.statusCode != 200) {
        throw const FormatException('delete store address');
      }
      await loadAddresses();
      showCustomSnackBar('تم حذف العنوان.', isError: false);
      return true;
    } catch (_) {
      addressesMessage = 'تعذر حذف العنوان.';
      addressesLoading = false;
      update();
      showCustomSnackBar(addressesMessage, isError: true);
      return false;
    }
  }

  @override
  getAllOrders() async {
    final controller = Get.find<OrderController>();
    await controller.load();
    Get.toNamed(RouteHelper.ordersScreen);
  }

  @override
  getConactUs() async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;

        var response = await authRepository.checkSettingAndConactUs();
        if (response.statusCode == 200) {
          conactUsModel = ApiResponse.fromJson(response.body);
          print(response.body);
          // Get.toNamed(RouteHelper.contactUsPage);
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

  @override
  getConactUsAccount() async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;

        var response = await authRepository.checkSettingAndConactUs();
        if (response.statusCode == 200) {
          conactUsModel = ApiResponse.fromJson(response.body);
          Get.toNamed(RouteHelper.contactUsPage);
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

  @override
  editAllOrders({required Order order}) async {
    await Get.find<OrderController>().requestCancellation(
      order,
      confirmed: true,
    );
  }

  String formatDate(String dateString) {
    DateTime time = DateTime.parse(dateString);
    return DateFormat('d MMMM yyyy').format(time);
  }

  @override
  changePassword() async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        if (newPasswordController.text == confirmPasswordController.text) {
          var response = await authRepository.changePassword(
            oldPassword: oldPasswordController.text,
            newPassword: newPasswordController.text,
            confirmPassword: confirmPasswordController.text,
            dateUpdate: formattedDate,
          );
          if (response.statusCode == 200) {
            oldPasswordController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();
            Get.back();
            showCustomSnackBar(
              "The password has been changed.".tr,
              isError: false,
            );
          } else if (response.statusCode != 200) {
            if (response.body["exception"] != null) {
              if (response.body["exception"]["Message"] ==
                  "Incorrect password.") {
                showCustomSnackBar("Password Not Match".tr, isError: true);
              }
            } else if (response.body["message"] ==
                "PasswordsMustBeAtLeast8Characters") {
              showCustomSnackBar(
                "PasswordsMustBeAtLeast8Characters".tr,
                isError: true,
              );
            } else if (response.body["message"] ==
                "PasswordsMustHaveAtLeastOneLowercaseAndOneUppercase") {
              showCustomSnackBar(
                "PasswordsMustHaveAtLeastOneLowercaseAndOneUppercase".tr,
                isError: true,
              );
            } else {
              showCustomSnackBar(
                'An error occurred. Please try again.'.tr,
                isError: true,
              );
            }
          }
        } else {
          showCustomSnackBar("Password Not Match".tr, isError: true);
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

  void openWhatsApp() async {
    if (conactUsModel!.data.whatsApp == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch("https://wa.me/${conactUsModel?.data.whatsApp}")) {
        await launch("https://wa.me/${conactUsModel?.data.whatsApp}");
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    }
  }

  void openWhatsAppAsk({required String text}) async {
    if (conactUsModel!.data.whatsApp == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch("https://wa.me/${conactUsModel?.data.whatsApp}")) {
        await launch(
          "https://wa.me/${conactUsModel?.data.whatsApp}?text=$text",
        );
      } else {
        throw "Try using another means of communication.".tr;
      }
    }
  }

  Future<void> openInstagram() =>
      _openConfiguredHttpUrl(conactUsModel?.data.instagram);

  Future<void> openTwitter() =>
      _openConfiguredHttpUrl(conactUsModel?.data.twitter);

  Future<void> _openConfiguredHttpUrl(String? value) async {
    final uri = safeHttpUri(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    showCustomSnackBar(
      "Try using another means of communication.".tr,
      isError: true,
    );
  }

  void openCall() async {
    if (conactUsModel!.data.call == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch("tel:${conactUsModel!.data.call}")) {
        await launch("tel:${conactUsModel!.data.call}");
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    }
  }

  void openSms() async {
    if (conactUsModel!.data.call == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch("sms:${conactUsModel!.data.call}")) {
        await launch(
          "sms:${conactUsModel!.data.call}${Platform.isAndroid ? '?' : '&'}body=",
        );
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
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
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    phoneNumber2Controller = TextEditingController();
    addressController = TextEditingController();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    phoneNumber2Controller.dispose();
    addressController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
