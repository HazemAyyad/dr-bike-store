import 'dart:math';

import 'package:get/get.dart';

import '../../controller/LocalizationController.dart';
import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';

abstract interface class HomeDataSource {
  Future<Response> getMainCategories();
  Future<Response> getOnlineAds();
  Future<Response> getAllItemIsMoreSales();
  Future<Response> getNotification();
  Future<Response> postNotificationIsRead(dynamic id);
  Future<Response> search(dynamic name, dynamic lang);
}

abstract interface class StoreHomeDataSource {
  Future<Response> getStoreHome();
  Future<Response> recordBannerClick(int bannerId);
  Future<Response> recordPopupEvent(int campaignId, String eventType);
}

abstract interface class StorePushDataSource {
  Future<Response> updateFcmToken(String token);
}

class HomeRepository extends GetxService
    implements HomeDataSource, StoreHomeDataSource, StorePushDataSource {
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  final ApiClient apiClient;
  // String token =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJhMjk2YWE0Ni1jNmIxLTRkNzEtYjk4YS1iZjMwYjQzYzk4ODkiLCJlbWFpbCI6IndhbGVlZDFAZ21haWwuY29tIiwicm9sZSI6IlVzZXIiLCJuYmYiOjE3NDkxNDI0MTYsImV4cCI6MTc4MDY3ODQxNiwiaWF0IjoxNzQ5MTQyNDE2LCJpc3MiOiJTZWN1cmVBcGkiLCJhdWQiOiJTZWN1cmVBcGlVc2VyIn0.FRbzifVW8Ra7iFd_oFxF9uJ7yey0HXJc1bth2amMXbc";

  HomeRepository({required this.apiClient})
    : _sessionId = _randomIdentity('session');
  String tok = AppUsageService.getToken().toString();
  static const _visitorKey = 'online_store_popup_visitor_id';
  final String _sessionId;

  static String _randomIdentity(String prefix) {
    final random = Random.secure();
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 32)}';
  }

  Future<Map<String, String>> _storeHeaders() async {
    var visitor = apiClient.sharedPreferences.getString(_visitorKey);
    if (visitor == null || visitor.isEmpty) {
      visitor = _randomIdentity('visitor');
      await apiClient.sharedPreferences.setString(_visitorKey, visitor);
    }
    final token = (await AppUsageService.getToken())?.trim();
    return {
      'X-Store-Visitor-ID': visitor,
      'X-Store-Session-ID': _sessionId,
      if (token?.isNotEmpty == true) 'authorization': 'Bearer $token',
    };
  }

  @override
  Future<Response> getStoreHome() async =>
      apiClient.getData('/OnlineStore/Home', headers: await _storeHeaders());

  @override
  Future<Response> recordBannerClick(int bannerId) =>
      apiClient.postData('/OnlineStore/Banners/$bannerId/Click');

  @override
  Future<Response> recordPopupEvent(int campaignId, String eventType) async =>
      apiClient.postData(
        '/OnlineStore/PopupCampaigns/$campaignId/Event',
        headers: await _storeHeaders(),
        body: {'event_type': eventType},
      );

  @override
  Future<Response> updateFcmToken(String token) async => apiClient.postData(
    '/Users/FcmToken',
    headers: await _storeHeaders(),
    body: {'fcm_token': token},
  );

  @override
  Future<Response> getMainCategories() async {
    return await apiClient.postData(
      "/MainCategorys/GetAllShowMainCategories",
      body: {
        "listRelatedObjects": ["<string>", "<string>"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        // "authorization": "Bearer $token",
      },
    );
  }

  @override
  Future<Response> getOnlineAds() async {
    return await apiClient.postData(
      "/OnlineAds/GetAllAds",
      body: {
        "listRelatedObjects": ["<string>", "<string>"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        // "authorization": "Bearer $token",
      },
    );
  }

  Future<Response> checkUser() async {
    String? id = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Auth/CheckUser?UserId=$id',
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  @override
  Future<Response> getAllItemIsMoreSales() async {
    return await apiClient.postData(
      "/Items/GetAllItemIsMoreSales",
      body: {
        "listRelatedObjects": [
          "ViewImgs",
          "NormalImgs",
          "_3DImgs",
          "SupCategories",
          "ItemSizes",
          "ItemColor",
        ],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        // "authorization": "Bearer $token",
      },
    );
  }

  @override
  Future<Response> getNotification() async {
    return await apiClient.postData(
      "/Notifications/GetNotifications?UserId=${await AppUsageService.getUserId()}",
      body: {
        "listRelatedObjects": ["<string>", "<string>"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  @override
  Future<Response> postNotificationIsRead(id) async {
    return await apiClient.postData(
      "/Notifications/EditNotification?NotificationId=$id&IsRead=true",
      body: {
        "listRelatedObjects": ["<string>", "<string>"],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  @override
  Future<Response> search(name, lang) async {
    final encodedName = Uri.encodeQueryComponent(name.toString());
    final encodedLanguage = Uri.encodeQueryComponent(lang.toString());
    return await apiClient.postData(
      "/Items/GetAllItemByName?Name=$encodedName&language=$encodedLanguage",
      body: {
        "listRelatedObjects": [
          "ViewImgs",
          "NormalImgs",
          "_3DImgs",
          "SupCategories",
          "ItemSizes",
          "ItemColor",
        ],
        "entity": {"nullable": true},
        "listOrderOptions": ["<string>", "<string>"],
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        // "authorization": "Bearer $token",
      },
    );
  }
}
