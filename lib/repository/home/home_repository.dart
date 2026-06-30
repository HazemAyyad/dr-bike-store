import 'package:get/get.dart';

import '../../controller/LocalizationController.dart';
import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';

class HomeRepository extends GetxService {
  final LocalizationController localizationController = Get.put(
    LocalizationController(sharedPreferences: Get.find()),
  );
  final ApiClient apiClient;
  // String token =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1laWQiOiJhMjk2YWE0Ni1jNmIxLTRkNzEtYjk4YS1iZjMwYjQzYzk4ODkiLCJlbWFpbCI6IndhbGVlZDFAZ21haWwuY29tIiwicm9sZSI6IlVzZXIiLCJuYmYiOjE3NDkxNDI0MTYsImV4cCI6MTc4MDY3ODQxNiwiaWF0IjoxNzQ5MTQyNDE2LCJpc3MiOiJTZWN1cmVBcGkiLCJhdWQiOiJTZWN1cmVBcGlVc2VyIn0.FRbzifVW8Ra7iFd_oFxF9uJ7yey0HXJc1bth2amMXbc";

  HomeRepository({required this.apiClient});
  String tok = AppUsageService.getToken().toString();
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

  Future<Response> search(name, lang) async {
    return await apiClient.postData(
      "/Items/GetAllItemByName?Name=$name&language=$lang",
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
