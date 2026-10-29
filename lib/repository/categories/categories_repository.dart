// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';
import 'store_catalog_source.dart';

class CategoriesRepository extends GetxService implements StoreCatalogSource {
  final ApiClient apiClient;
  CategoriesRepository({required this.apiClient});

  Future<Response> getAllCategoriesByMainCategoresId({
    required mainCategoresId,
    Map<String, String> filters = const {},
  }) async {
    final query = <String, String>{
      'MainCategory': '$mainCategoresId',
      ...filters,
    };
    return await apiClient.postData(
      "/Items/GetAllItemsShowByMainCategory?${Uri(queryParameters: query).query}",
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

  Future<Response> getListingsByOnlineStoreCategory({
    required int categoryId,
    Map<String, String> filters = const {},
  }) => catalogPage(categoryId: categoryId, filters: filters);

  @override
  Future<Response> catalogPage({
    String? query,
    int? categoryId,
    int page = 1,
    Map<String, String> filters = const {},
  }) async {
    final response = await apiClient.getData(
      '/OnlineStore/Catalog',
      query: {
        if (query != null) 'q': query,
        if (categoryId != null && categoryId > 0) 'category_id': '$categoryId',
        'page': '$page',
        'per_page': '24',
        ...filters,
      },
    );
    // A new APK can browse while the compatible server addition rolls out.
    if (response.statusCode == 404 && page == 1 && categoryId != null) {
      return getAllCategoriesByMainCategoresId(
        mainCategoresId: categoryId,
        filters: filters,
      );
    }
    return response;
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
