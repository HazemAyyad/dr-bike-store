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
import '../../core/model/user_data_model.dart';
import '../../core/widget/custom_snackbar.dart';
import '../LocalizationController.dart';
import '../order/order_controller.dart';
import 'package:intl/intl.dart';

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
  bool isDarkMode = ThemeServices().loadThemeFromBox();
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
  final AuthRepository authRepository;
  late StatusRequest statusRequest;
  AccountControllerImp({required this.authRepository});
  @override
  getUserById({bool navigate = true}) async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;
        var response = await authRepository.getUser();
        var responseCity = await authRepository.getCity();
        if (response.statusCode == 200) {
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
          debugPrint(
            '[STORE_ACCOUNT] loaded user id=${userModel!.id} email=${emailController.text} phone=${phoneNumberController.text}',
            wrapWidth: 1024,
          );
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
        debugPrint('[STORE_ACCOUNT] getUserById error=$e', wrapWidth: 1024);
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
    update();
  }

  @override
  editeUser() async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        if (userModel!.fullName != nameController.text ||
            userModel!.phoneNumber != phoneNumberController.text ||
            userModel!.phoneNumber2 != phoneNumber2Controller.text ||
            userModel!.cityId != selectedCityId ||
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
            block: userModel!.block,
            typeUser: userModel!.typeUser,
            userUpdate: formattedDate,
          );
          if (response.statusCode == 200) {
            Get.back();
            showCustomSnackBar(
              "Account information has been updated".tr,
              isError: false,
            );
            await AppUsageService.saveUserName(response.body['fullName']);
            await AppUsageService.saveUserEmail(response.body['email']);
          }
        }
      } catch (e) {
        debugPrint('[STORE_ACCOUNT] editeUser error=$e', wrapWidth: 1024);
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

  deleteUserAccount() async {
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      try {
        statusRequest = StatusRequest.loading;

        var response = await authRepository.deleteUserAccount();
        if (response.statusCode == 200) {
          await AppUsageService.deleteIsLogin();
          await AppUsageService.deleteToken();
          await AppUsageService.deleteUserEmail();
          await AppUsageService.deleteUserId();
          await AppUsageService.deleteUserName();
          await AppUsageService.deleteTypeUser();
          await loadingToken();
          Get.back();
          OverlayLoadingProgress.stop();
          showCustomSnackBar("The account has been deleted".tr, isError: false);
        }
        OverlayLoadingProgress.stop();
        update();
      } catch (e) {
        debugPrint('[STORE_ACCOUNT] getAllOrders error=$e', wrapWidth: 1024);
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
    OverlayLoadingProgress.stop();
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

  void openInstagram() async {
    if (conactUsModel!.data.instagram == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch(conactUsModel!.data.instagram!)) {
        await launch(conactUsModel!.data.instagram!);
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    }
  }

  void openFacebook() async {
    if (conactUsModel!.data.twitter == null) {
      if (await canLaunch('')) {
        await launch('');
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    } else {
      if (await canLaunch(conactUsModel!.data.twitter!)) {
        await launch(conactUsModel!.data.twitter!);
      } else {
        showCustomSnackBar(
          "Try using another means of communication.".tr,
          isError: true,
        );
      }
    }
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
