import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/LocalizationController.dart';
import 'functions/app_usage_service.dart';
import 'constants/app_constants.dart';
import 'model/error_response.dart';

class ApiClient {
  static var logoutFromInterceptors = false;
  final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  final int timeoutInSeconds = 40;

  ApiClient({required this.sharedPreferences});

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    try {
      _logRequest('GET', url);
      final requestUri = Uri.parse(url).replace(queryParameters: query);
      http.Response response = await http
          .get(requestUri, headers: _jsonHeaders(headers))
          .timeout(Duration(seconds: timeoutInSeconds));
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('GET', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postData(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    final requestHeaders = _jsonHeaders(headers);
    try {
      _logRequest('POST', url, headers: requestHeaders, body: body);
      http.Response response = await http
          .post(Uri.parse(url), headers: requestHeaders, body: jsonEncode(body))
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('POST', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipart(
    String uri, {
    required String filePath,
    String fieldName = 'image',
    Map<String, String>? headers,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers ?? const {});
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      _logRequest('POST', url, headers: request.headers);
      final streamed = await request.send().timeout(
        Duration(seconds: timeoutInSeconds),
      );
      final response = await http.Response.fromStream(streamed);
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('POST', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(
    String uri, {
    Map<String, String> fields = const {},
    List<String> filePaths = const [],
    String fieldName = 'attachments[]',
    Map<String, String>? headers,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({'Accept': 'application/json', ...?headers});
      request.fields.addAll(fields);
      for (final path in filePaths) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, path));
      }
      _logRequest('POST', url, headers: request.headers, body: fields);
      final streamed = await request.send().timeout(
        Duration(seconds: timeoutInSeconds),
      );
      final response = await http.Response.fromStream(streamed);
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('POST', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        body = jsonDecode(response.body);
      } else {
        _logApiClientMessage(
          'UNEXPECTED_CONTENT_TYPE ${response.statusCode} ${response.request?.url} content-type=${response.headers['content-type']} body=${_shortText(response.body)}',
        );
        return Response(
          statusCode: response.statusCode,
          statusText:
              'Unexpected content type: ${response.headers['content-type']}',
        );
      }
    } catch (e) {
      _logApiClientMessage(
        'JSON_DECODE_FAILED ${response.statusCode} ${response.request?.url} error=$e body=${_shortText(response.body)}',
      );
      return Response(
        statusCode: response.statusCode,
        statusText: 'Failed to decode response body',
      );
    }

    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
        headers: response.request!.headers,
        method: response.request!.method,
        url: response.request!.url,
      ),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );

    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.errors![0].message,
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: response0.body['message'],
        );
      }
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = Response(statusCode: 0, statusText: noInternetMessage);
    }

    if (kDebugMode) {
      _logApiClientMessage(
        'PARSED ${response0.request?.method ?? response.request?.method} ${response0.request?.url ?? response.request?.url} status=${response0.statusCode} statusText=${response0.statusText} parsedBody=${_bodySummary(response0.body)}',
      );
    }

    return response0;
  }

  Future<Response> putData(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    final requestHeaders = _jsonHeaders({
      'content-type': 'application/json',
      'authorization': 'Bearer ${AppUsageService.getToken()}',
      'Accept-Language': Get.find<LocalizationController>().locale.languageCode,
    });
    try {
      _logRequest('PUT', url, headers: requestHeaders, body: body);
      http.Response response = await http
          .put(Uri.parse(url), headers: requestHeaders, body: jsonEncode(body))
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('PUT', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> patch(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    final url = AppConstants.appBaseUrl + uri;
    final requestHeaders = _jsonHeaders({
      'content-type': 'application/json',
      'Accept-Language': Get.find<LocalizationController>().locale.languageCode,
    });
    try {
      _logRequest('PATCH', url, headers: requestHeaders, body: body);
      http.Response response = await http
          .patch(
            Uri.parse(url),
            headers: requestHeaders,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      _logRawResponse(response);
      return handleResponse(response, uri);
    } catch (e) {
      _logError('PATCH', url, e);
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  void _logRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;
    _logApiClientMessage('REQUEST $method $url');
    if (headers != null) {
      _logApiClientMessage('REQUEST_HEADERS ${_redactHeaders(headers)}');
    }
    if (body != null) {
      _logApiClientMessage('REQUEST_BODY ${_shortObject(_redactBody(body))}');
    }
  }

  void _logRawResponse(http.Response response) {
    if (!kDebugMode) return;
    _logApiClientMessage(
      'RESPONSE ${response.request?.method} ${response.request?.url} status=${response.statusCode} content-type=${response.headers['content-type']} bodyLength=${response.body.length}',
    );
  }

  void _logError(String method, String url, Object error) {
    if (!kDebugMode) return;
    _logApiClientMessage('ERROR $method $url error=$error');
  }

  Map<String, String> _jsonHeaders(Map<String, String>? headers) {
    final normalizedHeaders = Map<String, String>.from(headers ?? {});
    normalizedHeaders.putIfAbsent('Content-Type', () => 'application/json');
    normalizedHeaders.putIfAbsent('Accept', () => 'application/json');
    return normalizedHeaders;
  }

  Map<String, String> _redactHeaders(Map<String, String> headers) {
    final copy = Map<String, String>.from(headers);
    for (final key in copy.keys.toList()) {
      final lower = key.toLowerCase();
      if (lower == 'authorization') {
        final value = copy[key] ?? '';
        copy[key] =
            value.length <= 16 ? '***' : '${value.substring(0, 16)}...***';
      }
    }
    return copy;
  }

  dynamic _redactBody(dynamic body) {
    if (body is! Map) return body;
    final copy = Map<dynamic, dynamic>.from(body);
    for (final key in copy.keys.toList()) {
      final lower = key.toString().toLowerCase();
      if (lower.contains('password') ||
          lower.contains('token') ||
          lower == 'otp' ||
          lower == 'resetproof') {
        copy[key] = '***';
      }
    }
    return copy;
  }

  String _shortObject(dynamic value) => _shortText(value.toString());

  String _bodySummary(dynamic value) {
    if (value is Map) {
      final parts = <String>[];
      if (value.containsKey('rows') && value['rows'] is List) {
        parts.add('rows=${(value['rows'] as List).length}');
      }
      if (value.containsKey('total')) parts.add('total=${value['total']}');
      if (value.containsKey('totalNotFiltered')) {
        parts.add('totalNotFiltered=${value['totalNotFiltered']}');
      }
      if (value.containsKey('id')) parts.add('id=${value['id']}');
      if (value.containsKey('serialNumber')) {
        parts.add('serialNumber=${value['serialNumber']}');
      }
      if (value.containsKey('orderNumber')) {
        parts.add('orderNumber=${value['orderNumber']}');
      }
      if (parts.isNotEmpty) return '{${parts.join(', ')}}';
    }
    return _shortObject(_redactBody(value));
  }

  String _shortText(String value) {
    const maxLength = 450;
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...<truncated ${value.length - maxLength} chars>';
  }

  void _logApiClientMessage(String message) {
    debugPrint('[STORE_API] $message', wrapWidth: 1024);
  }
}
