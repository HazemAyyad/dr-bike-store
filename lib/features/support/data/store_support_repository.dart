import 'package:get/get.dart';

import '../../../core/api_client.dart';
import '../../../core/functions/app_usage_service.dart';
import 'store_support_models.dart';

class StoreSupportRepository {
  StoreSupportRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Map<String, String>> _headers() async {
    final token = await AppUsageService.getToken();
    return {
      'Accept': 'application/json',
      if (token?.isNotEmpty == true) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<StoreSupportConversation>> conversations() async {
    final response = await apiClient.getData(
      '/OnlineStore/Support/Conversations',
      headers: await _headers(),
    );
    _requireSuccess(response);
    return (response.body['conversations'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (row) =>
              StoreSupportConversation.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<({StoreSupportConversation conversation, bool resumed})> create({
    required String contextType,
    required String text,
    required String clientMessageId,
    int? listingId,
    String? imagePath,
  }) async {
    final fields = {
      'context_type': contextType,
      'message': text,
      'client_message_id': clientMessageId,
      if (listingId != null) 'listing_id': '$listingId',
    };
    final response =
        imagePath == null
            ? await apiClient.postData(
              '/OnlineStore/Support/Conversations',
              headers: await _headers(),
              body: fields,
            )
            : await apiClient.postMultipartData(
              '/OnlineStore/Support/Conversations',
              headers: await _headers(),
              fields: fields,
              filePaths: [imagePath],
            );
    _requireSuccess(response);
    return (
      conversation: StoreSupportConversation.fromJson(
        Map<String, dynamic>.from(response.body['conversation']),
      ),
      resumed: response.body['resumed'] == true,
    );
  }

  Future<
    ({
      StoreSupportConversation conversation,
      List<StoreSupportMessage> messages,
    })
  >
  detail(int conversationId, {int? afterId}) async {
    final response = await apiClient.getData(
      '/OnlineStore/Support/Conversations/$conversationId',
      query: {if (afterId != null) 'after_id': '$afterId', 'per_page': '100'},
      headers: await _headers(),
    );
    _requireSuccess(response);
    return (
      conversation: StoreSupportConversation.fromJson(
        Map<String, dynamic>.from(response.body['conversation']),
      ),
      messages:
          (response.body['messages'] as List? ?? const [])
              .whereType<Map>()
              .map(
                (row) => StoreSupportMessage.fromJson(
                  Map<String, dynamic>.from(row),
                ),
              )
              .toList(),
    );
  }

  Future<StoreSupportMessage> send({
    required int conversationId,
    required String text,
    required String clientMessageId,
    String? imagePath,
  }) async {
    final fields = {'message': text, 'client_message_id': clientMessageId};
    final path = '/OnlineStore/Support/Conversations/$conversationId/Messages';
    final response =
        imagePath == null
            ? await apiClient.postData(
              path,
              headers: await _headers(),
              body: fields,
            )
            : await apiClient.postMultipartData(
              path,
              headers: await _headers(),
              fields: fields,
              filePaths: [imagePath],
            );
    _requireSuccess(response);
    return StoreSupportMessage.fromJson(
      Map<String, dynamic>.from(response.body['support_message']),
    );
  }

  Future<void> markRead(int conversationId) async {
    final response = await apiClient.postData(
      '/OnlineStore/Support/Conversations/$conversationId/Read',
      headers: await _headers(),
      body: const {},
    );
    _requireSuccess(response);
  }

  void _requireSuccess(Response response) {
    final code = response.statusCode ?? 0;
    if (code < 200 || code >= 300 || response.body is! Map) {
      throw StoreSupportException(
        response.body is Map
            ? (response.body['message'] ?? response.statusText).toString()
            : (response.statusText ?? 'تعذر الاتصال بالدعم'),
      );
    }
  }
}

class StoreSupportException implements Exception {
  const StoreSupportException(this.message);
  final String message;
  @override
  String toString() => message;
}
