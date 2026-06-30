// ignore_for_file: public_member_api_docs, sort_constructors_first, empty_catches
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:doctor_bike/core/helper/route_helper.dart';
import 'package:overlay_kit/overlay_kit.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/model/conact_us_model.dart';
import '../../repository/auth/auth_repository.dart';
import '../account/account_controller.dart';

class ApiService extends GetxService {
  Timer? _timer;
  bool isConnectToInternet = false;
  StreamSubscription? _internetConnectionStreamSubscription;
  void startAccountCheck() {
    _timer?.cancel(); // Prevent multiple timers
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      checkAccountStatus();
    });
  }

  @override
  void onInit() {
    _internetConnectionStreamSubscription = InternetConnection().onStatusChange
        .listen((event) {
          if (event == InternetStatus.connected) {
            isConnectToInternet = true;
            _handleConnectInternet();
          }
        });
    checkStatus();
    super.onInit();
  }

  checkAccountStatus() async {
    final AuthRepository authRepository = Get.put(
      AuthRepository(apiClient: ApiClient(sharedPreferences: Get.find())),
    );

    try {
      final response = await authRepository.checkUser();
      if (response.statusCode == 200) {
        if (response.body["isClose"] == true) {
          _handleBlockedAccount();
        }
      } else {}
    } catch (e) {}
  }

  checkSiteStatus() async {
    final AccountControllerImp accountControllerImp = Get.put(
      AccountControllerImp(
        authRepository: AuthRepository(
          apiClient: ApiClient(sharedPreferences: Get.find()),
        ),
      ),
    );
    final AuthRepository authRepository = Get.put(
      AuthRepository(apiClient: ApiClient(sharedPreferences: Get.find())),
    );

    try {
      var response = await authRepository.checkSettingAndConactUs();
      if (response.statusCode == 200) {
        accountControllerImp.conactUsModel = ApiResponse.fromJson(
          response.body,
        );
        if (accountControllerImp.conactUsModel?.data.isClose == true) {
          _handleCloseSite();
        }
      }
      OverlayLoadingProgress.stop();
    } catch (e) {
    } finally {
      OverlayLoadingProgress.stop();
    }
  }

  void checkStatus() {
    // Your logic here (e.g., API call, check notifications, etc.)
  }

  void _handleBlockedAccount() async {
    _timer?.cancel();
    Get.snackbar(
      "Account Blocked",
      "Your account has been blocked. Please contact support.",
    );
    await AppUsageService.deleteIsLogin();
    await AppUsageService.deleteToken();
    await AppUsageService.deleteUserEmail();
    await AppUsageService.deleteUserId();
    await AppUsageService.deleteUserName();
    await AppUsageService.deleteTypeUser();
    await Get.find<AccountControllerImp>().loadingToken();
    Get.offAllNamed(RouteHelper.homePage); // Navigate to login screen
  }

  void _handleCloseSite() {
    _timer?.cancel();
    Get.snackbar("Closed Site", "The site is closed");
    Get.offAllNamed(RouteHelper.initial); // Navigate to login screen
  }

  void _handleConnectInternet() {
    _timer?.cancel();
    checkAccountStatus();
    checkSiteStatus();
  }

  @override
  void onClose() {
    _internetConnectionStreamSubscription?.cancel();

    _timer?.cancel();
    super.onClose();
  }
}

// check internet
class ConnectivityController extends GetxController {
  var isConnected = true.obs; // Default to connected

  @override
  void onInit() {
    super.onInit();
    loadingToken();
    _startMonitoring();
  }

  String? token;
  loadingToken() async {
    token = await AppUsageService.getToken();
    update();
  }

  void _startMonitoring() {
    Connectivity().onConnectivityChanged.listen((result) {
      bool connectionStatus =
          (result != ConnectivityResult.wifi) ||
          (result != ConnectivityResult.mobile) ||
          (result != ConnectivityResult.ethernet);
      if (!connectionStatus && isConnected.value) {
        // Show the pop-up only when the connection is lost
        _showConnectionPopup();
      } else {}
      isConnected.value = connectionStatus;
    });
  }

  void retryConnection() async {
    var result = await Connectivity().checkConnectivity();
    isConnected.value = result != ConnectivityResult.none;

    if (isConnected.value) {
      if (await CheckInternet.checkInternet()) {
        Get.back(); // Close the popup
      } else {
        _showConnectionPopup();
      }
      // Close the popup if reconnected
    }
  }

  void _showConnectionPopup() {
    Get.defaultDialog(
      title: "No Internet Connection",
      middleText: "Please check your network and try again.",
      barrierDismissible: false,
      confirm: ElevatedButton(onPressed: retryConnection, child: Text("Retry")),
    );
  }
}
