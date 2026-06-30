// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';

class CategoriesRepository extends GetxService {
  final ApiClient apiClient;
  CategoriesRepository({required this.apiClient});
  String tok = AppUsageService.getToken().toString();

  Future<Response> getAllCategoriesByMainCategoresId({
    required mainCategoresId,
  }) async {
    return await apiClient.postData(
      "/Items/GetAllItemsShowByMainCategory?MainCategory=$mainCategoresId",
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

  Future<Response> getCategoriesById({required categoryId}) async {
    return await apiClient.postData(
      "/Items/GetItemById?itemId=$categoryId",
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

  Future<Response> getCategoriesBySupId({required supId}) async {
    return await apiClient.postData(
      "/Items/GetAllShowItemsBySupCatId?supCategoryId=$supId",
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

  Future<Response> getCommintByCategoryId({required categoryId}) async {
    return await apiClient.postData(
      "/Comments/GetAllCommentsToItem?ItemId=$categoryId",
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

  Future<Response> postCommint({
    required dateAdd,
    required itemName,
    required itemId,
    required comment,
    required rate,
  }) async {
    String? id = await AppUsageService.getUserId();
    String? name = await AppUsageService.getUserName();
    return await apiClient.postData(
      "/Comments/ManageComment",
      body: {
        "id": 0,
        "comment": comment,
        "productId": itemId,
        "productName": itemName,
        "rate": rate,
        "userName": name,
        "userAddId": id,
        "isShow": true,
        "dateAdd": dateAdd,
      },

      headers: {
        'Content-Type': 'application/json',
        "authorization": "Bearer ${await AppUsageService.getToken()}",
      },
    );
  }

  Future<Response> getSupCategorysByMainCategoresId({
    required mainCategoresId,
  }) async {
    return await apiClient.postData(
      "/SupCategorys/GetAllShowSupCategories?mainCategoryId=$mainCategoresId",
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

  Future<Response> getCategoriesItemBySupcategores({
    required supCategoresId,
  }) async {
    return await apiClient.postData(
      "/Items/GetAllShowItemsBySupCatId?supCategoryId=$supCategoresId",
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
