import 'dart:convert';
import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/functions/app_usage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ApiClient client;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    client = ApiClient(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
  });

  http.Response response(int status, String token) => http.Response(
    jsonEncode({'message': 'Unauthenticated'}),
    status,
    headers: {'content-type': 'application/json'},
    request: http.Request('POST', Uri.parse('https://example.test/private'))
      ..headers['Authorization'] = 'Bearer $token',
  );

  test(
    'a late 401 from an old session cannot sign out the new account',
    () async {
      await AppUsageService.saveToken('new-session');
      client.handleResponse(response(401, 'old-session'), '/private');
      expect(await AppUsageService.getToken(), 'new-session');
    },
  );

  test('concurrent 401s clear the matching identity once', () async {
    await AppUsageService.saveToken('current');
    await AppUsageService.saveUserId('42');
    final expired = AppUsageService.sessionExpired.stream.first;
    client.handleResponse(response(401, 'current'), '/private');
    client.handleResponse(response(401, 'current'), '/private');
    await expired;
    expect(await AppUsageService.getToken(), isNull);
    expect(await AppUsageService.getUserId(), isNull);
  });

  test(
    'forbidden permissions do not invalidate an authenticated session',
    () async {
      await AppUsageService.saveToken('current');
      client.handleResponse(response(403, 'current'), '/private');
      expect(await AppUsageService.getToken(), 'current');
    },
  );

  test('logout accepts an empty 204 response', () {
    expect(
      client.handleResponse(http.Response('', 204), '/Auth/Logout').statusCode,
      204,
    );
  });

  test('diagnostics omit query parameters and server message contents', () {
    final messages = <String>[];
    final previous = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = previous);
    client.handleResponse(
      http.Response(
        jsonEncode({'message': 'private-reset-proof'}),
        400,
        headers: {'content-type': 'application/json'},
        request: http.Request(
          'POST',
          Uri.parse(
            'https://example.test/private?otp=123456&email=private@example.test',
          ),
        ),
      ),
      '/private',
    );
    expect(messages.join(), isNot(contains('123456')));
    expect(messages.join(), isNot(contains('private@example.test')));
    expect(messages.join(), isNot(contains('private-reset-proof')));
  });

  test('a parsed response without a transport request remains usable', () {
    final parsed = client.handleResponse(
      http.Response(
        '{"rows":[]}',
        200,
        headers: {'content-type': 'application/json'},
      ),
      '/catalog',
    );
    expect(parsed.statusCode, 200);
    expect(parsed.body, {'rows': []});
  });
}
