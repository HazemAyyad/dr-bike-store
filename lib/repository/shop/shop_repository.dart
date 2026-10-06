import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';

class ShopRepository extends GetxService {
  final ApiClient apiClient;
  ShopRepository({required this.apiClient});
  String tok = AppUsageService.getToken().toString();

  Future<Response> createOrder({required body}) async {
    String? token = await AppUsageService.getToken();
    return await apiClient.postData(
      "/OnlineStore/Checkout",
      body: body,
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token",
      },
    );
  }

  Future<Response> submitNativeCheckout(Map<String, dynamic> request) =>
      createOrder(body: request);

  Future<Response> getUser() async {
    String? id = await AppUsageService.getUserId();
    return await apiClient.postData(
      '/Users/GetById?id=$id',
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

  Future<Response> checkCode(code) async {
    return await apiClient.postData(
      '/DiscoundCodes/GetByDiscoundCode?code=$code&userid=${await AppUsageService.getUserId()}',
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

  Future<Response> getCity() async {
    return await apiClient.postData(
      '/Cities/GetAllCities',
      body: {
        "listRelatedObjects": ["City"],
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

  Future<Response> getVillagesByCityId(String cityId) async {
    return await apiClient.postData(
      '/Cities/GetVillagesByCityId?cityId=$cityId',
      body: {
        "cityId": cityId,
        "paginationInfo": {"pageIndex": 0, "pageSize": 0},
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> calculateDeliveryFee({
    required String villageId,
    required double price,
  }) async {
    return await apiClient.postData(
      '/Cities/CalculateDeliveryFee',
      body: {"villageId": villageId, "price": price},
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> userEdit({
    required email,
    required phoneNumber,
    required address,
    required block,
    required fullName,
    required phoneNumber2,
    required typeUser,
    required cityId,
    required city,
    required userUpdate,
  }) async {
    return await apiClient.postData(
      '/Users/Edit',
      body: {
        "id": await AppUsageService.getUserId(),
        "email": email,
        "phoneNumber": phoneNumber,
        "address": address,
        "block": block,
        "fullName": fullName,
        "phoneNumber2": phoneNumber2,
        "typeUser": typeUser,
        "userUpdate": await AppUsageService.getUserId(),
        "dateUpdate": userUpdate,
        "cityId": cityId,
      },
      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }
}
