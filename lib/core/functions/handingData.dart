// ignore_for_file: file_names

import 'package:get/get.dart';
import '../classes/status_request.dart';

enum StoreResponseKind { success, offline, unauthorized, failure, malformed }

abstract final class StoreResponseClassifier {
  static StoreResponseKind classify(
    Object? response, {
    bool Function(Object? body)? parser,
  }) {
    if (response is StatusRequest) {
      return response == StatusRequest.offlinefailure
          ? StoreResponseKind.offline
          : StoreResponseKind.failure;
    }
    if (response is! Response) return StoreResponseKind.malformed;
    final code = response.statusCode ?? 0;
    if (code == 0 || code == 1) return StoreResponseKind.offline;
    if (code == 401 || code == 403) return StoreResponseKind.unauthorized;
    if (code < 200 || code >= 300) return StoreResponseKind.failure;
    if (parser == null || !parser(response.body)) {
      return StoreResponseKind.malformed;
    }
    return StoreResponseKind.success;
  }
}

abstract class HandlingData {
  static StatusRequest handlingData(
    Object? response, {
    bool Function(Object? body)? parser,
  }) => switch (StoreResponseClassifier.classify(response, parser: parser)) {
    StoreResponseKind.success => StatusRequest.success,
    StoreResponseKind.offline => StatusRequest.offlinefailure,
    _ => StatusRequest.failure,
  };
}
