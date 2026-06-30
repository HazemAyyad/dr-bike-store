// ignore_for_file: public_member_api_docs, sort_constructors_first, deprecated_member_use
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_kit/overlay_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/ads_response.dart';
import '../../core/model/get_all_item_model.dart';
import '../../core/model/main_categores_model.dart';
import '../../core/model/notification_model.dart';
import '../../core/widget/custom_snackbar.dart';
import 'package:intl/intl.dart';
import '../../repository/home/home_repository.dart';
import '../LocalizationController.dart';

abstract class HomeController extends GetxController {
  getMainCategores();
  getOnlineAds();
  getAllItemIsMoreSales();
  getNotifications();
  postNotificationsIsRead();
  getSearch(String name);
}

class HomeControllerImp extends HomeController {
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );

  final CarouselSliderController carouselController =
      CarouselSliderController();
  Rx<int> currentPage = 0.obs;
  String? token;
  var isLoadingSearch = false.obs;
  var isLoadingGetOnlineAds = false.obs;
  var isLoadingGetItems = false.obs;
  var isLoadingGetCategories = false.obs;
  var isTwo = false.obs;
  final HomeRepository homeRepository;
  late StatusRequest statusRequest;
  late bool isNormail;
  final mainCategoresModel = <Category>[].obs;
  final adsResponse = <Ad>[].obs;
  final itemList = <Item>[].obs;
  final itemListSearch = <Item>[].obs;
  RxList<int> notificationIsNotRead = <int>[].obs;
  Rx<NotificationResponse>? notifications;
  bool isGrid = false;
  bool showFilter = false;
  Rx<bool> isNotificationNotRead = false.obs;
  late TextEditingController search;
  HomeControllerImp({required this.homeRepository});

  String formatDate(DateTime dateString) {
    return DateFormat('MMMM d, yyyy').format(dateString);
  }

  @override
  getMainCategores() async {
    if (await CheckInternet.checkInternet()) {
      isLoadingGetCategories.value = true;
      try {
        var response = await homeRepository.getMainCategories();

        // print('getMainCategores statusCode ${response.statusCode}');
        // print('getMainCategores body ${response.body}');

        if (response.statusCode == 200) {
          mainCategoresModel.value = List<Category>.from(
            response.body["rows"].map((x) => Category.fromJson(x)),
          );

          if (mainCategoresModel.isNotEmpty) {
            // print(
            //   "mainCategoresModel.value.rows : ${mainCategoresModel!.value.rows[0]}",
            // );
          }
          // print("mainCategoresModel.value.rows : isEmpty");
        }
        update();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
        // print('Error during get Main Categores: $e');
      } finally {
        isLoadingGetCategories.value = false;
      }
    } else {
      isLoadingGetCategories.value = false;
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  getAllItemIsMoreSales() async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      isLoadingGetItems.value = true;

      try {
        var response = await homeRepository.getAllItemIsMoreSales();
        // itemList.value = [];
        if (response.statusCode == 200) {
          itemList.value = List<Item>.from(
            response.body["rows"].map((x) {
              return Item.fromJson(x);
            }),
          );
          // itemList = ItemsResponse.fromJson(response.body).obs;

          if (itemList.isNotEmpty) {
            for (var element in List.from(itemList)) {
              if (element.isShow == false) {
                itemList.remove(element);
              }
            }
          }
        }
        update();
      } catch (e) {
        // showCustomSnackBar(e.toString(), isError: true);
      } finally {
        isLoadingGetItems.value = false;
      }
    } else {
      isLoadingGetItems.value = false;
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  getOnlineAds() async {
    if (await CheckInternet.checkInternet()) {
      isLoadingGetOnlineAds.value = true;
      try {
        var response = await homeRepository.getOnlineAds();
        if (response.statusCode == 200) {
          adsResponse.value = List<Ad>.from(
            response.body['rows'].map((x) => Ad.fromJson(x)),
          );
          if (adsResponse.isNotEmpty) {}
        }
        update();
      } catch (e) {
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        isLoadingGetOnlineAds.value = false;
      }
    } else {
      isLoadingGetOnlineAds.value = false;

      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  Future<void> getSearch(String name) async {
    isNormail = await AppUsageService.getTypeUser() == "Normail";
    if (await CheckInternet.checkInternet()) {
      OverlayLoadingProgress.start();
      isLoadingSearch = true.obs;
      try {
        itemListSearch.value = [];
        var response = await homeRepository.search(
          name,
          localizationController.locale.languageCode,
        );

        if (response.statusCode == 200) {
          itemListSearch.value = List<Item>.from(
            response.body['rows'].map((x) => Item.fromJson(x)),
          );
          if (itemListSearch.isNotEmpty) {}
        } else {}
        isLoadingSearch = false.obs;
        update();
      } catch (e) {
        isLoadingSearch = false.obs;
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      }
      isLoadingSearch = false.obs;
    } else {
      isLoadingSearch = false.obs;
      // isLoadingGetOnlineAds = false.obs;

      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
    OverlayLoadingProgress.stop();
    // isLoadingGetOnlineAds = false.obs;
  }

  @override
  getNotifications() async {
    if (await CheckInternet.checkInternet()) {
      try {
        var response = await homeRepository.getNotification();

        if (response.statusCode == 200) {
          notifications = NotificationResponse.fromJson(response.body).obs;

          if (notifications!.value.rows.isNotEmpty) {
            for (int i = 0; i < notifications!.value.rows.length; i++) {
              if (notifications!.value.rows[i].isRead == false) {
                isNotificationNotRead = true.obs;
                notificationIsNotRead.add(notifications!.value.rows[i].id);
              }
            }
          } else {}
        }
      } catch (e) {
        debugPrint('[STORE_HOME] notifications error=$e');
      } finally {}
      update();
    } else {
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  postNotificationsIsRead() async {
    if (notificationIsNotRead.isNotEmpty) {
      if (await CheckInternet.checkInternet()) {
        try {
          if (notificationIsNotRead.length != []) {
            for (int i = 0; i < notificationIsNotRead.length; i++) {
              isNotificationNotRead = false.obs;
              var response = await homeRepository.postNotificationIsRead(
                notificationIsNotRead[i],
              );
              if (response.statusCode == 200) {
                response.body == true;
              }
            }

            notificationIsNotRead.clear();
          }
        } catch (e) {
          showCustomSnackBar(
            'An error occurred. Please try again.'.tr,
            isError: true,
          );
        } finally {
          OverlayLoadingProgress.stop();
        }
        update();
      } else {
        OverlayLoadingProgress.stop();

        showCustomSnackBar('Check the internet connection'.tr, isError: true);
      }
    }
  }

  void openWeb(String web) async {
    if (await canLaunch(web)) {
      await launch(web);
    } else {
      showCustomSnackBar(
        'An error occurred. Please try again.'.tr,
        isError: true,
      );
      // throw "error occured";
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
    search = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    search.clear();
    super.dispose();
  }
}
