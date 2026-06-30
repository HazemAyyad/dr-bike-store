import 'dart:convert';


class ServerException implements Exception {
  ServerException();

  Map<String, dynamic>? errors;
  int? statusCode;

  ServerException.errorApi({this.errors, this.statusCode});

  static fromResponse(String body, {int? statusCode}) {
    return ServerException.errorApi(
        errors: json.decode(body), statusCode: statusCode);
  }


}

class CacheException implements Exception {}
class NoCurrentConversationException implements Exception {}
