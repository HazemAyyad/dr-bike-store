import 'package:get/get.dart';

import '../../core/api_client.dart';
import '../../core/functions/app_usage_service.dart';

abstract interface class ReviewDataSource {
  Future<Response> publicReviews(int productId);
  Future<Response> ownReviews();
  Future<Response> submitReview(int productId, int rating, String? comment);
  Future<Response> updatePendingReview(
    int id,
    int productId,
    int rating,
    String? comment,
  );
}

class ReviewRepository implements ReviewDataSource {
  ReviewRepository({required this.apiClient});
  final ApiClient apiClient;

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'authorization': 'Bearer ${await AppUsageService.getToken()}',
  };

  @override
  Future<Response> publicReviews(int productId) => apiClient.postData(
    '/Comments/GetAllCommentsToItem?ItemId=$productId',
    body: const {
      'listRelatedObjects': <String>[],
      'entity': {'nullable': true},
      'listOrderOptions': <String>[],
      'paginationInfo': {'pageIndex': 0, 'pageSize': 0},
    },
  );

  @override
  Future<Response> ownReviews() async =>
      apiClient.getData('/OnlineStore/Reviews', headers: await _headers());

  @override
  Future<Response> submitReview(
    int productId,
    int rating,
    String? comment,
  ) async => apiClient.postData(
    '/OnlineStore/Reviews',
    headers: await _headers(),
    body: {'product_id': productId, 'rating': rating, 'comment': comment},
  );

  @override
  Future<Response> updatePendingReview(
    int id,
    int productId,
    int rating,
    String? comment,
  ) async => apiClient.postData(
    '/Comments/ManageComment',
    headers: await _headers(),
    body: {
      'id': id,
      'productId': productId,
      'rate': rating,
      'comment': comment,
    },
  );
}
