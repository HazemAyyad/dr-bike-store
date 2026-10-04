import 'package:doctor_bike/core/api_client.dart';
import 'package:doctor_bike/core/functions/checkout_attempt.dart';
import 'package:doctor_bike/core/functions/store_client_metadata.dart';
import 'package:doctor_bike/core/functions/upgrade_required.dart';
import 'package:doctor_bike/core/model/otp_model.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingApiClient extends ApiClient {
  RecordingApiClient(SharedPreferences sharedPreferences)
    : super(sharedPreferences: sharedPreferences);

  String? method;
  String? uri;
  Map<String, dynamic>? sentBody;
  Response response = const Response(statusCode: 200, body: {});

  @override
  Future<Response> postData(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    method = 'POST';
    this.uri = uri;
    sentBody = Map<String, dynamic>.from(body as Map);
    return response;
  }

  @override
  Future<Response> patch(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    method = 'PATCH';
    this.uri = uri;
    sentBody = Map<String, dynamic>.from(body as Map);
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RecordingApiClient apiClient;
  late AuthRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    apiClient = RecordingApiClient(preferences);
    repository = AuthRepository(
      apiClient: apiClient,
      clientMetadata: StoreClientMetadata(
        platform: TargetPlatform.android,
        packageInfoLoader:
            () async => PackageInfo(
              appName: 'Doctor Bike Store',
              packageName: 'com.example.store',
              version: '2.2.1',
              buildNumber: '10',
            ),
      ),
    );
  });

  test('forgot password sends Store metadata and expects no OTP', () async {
    apiClient.response = const Response(
      statusCode: 200,
      body: {'status': 'success', 'message': 'success'},
    );

    final response = await repository.forgotPassword(email: 'a@example.com');
    final model = ForgotPasswordResponse.fromJson(response.body);

    expect(apiClient.uri, '/Auth/ForgotPassword');
    expect(apiClient.sentBody, {
      'Email': 'a@example.com',
      'app': 'store',
      'platform': 'android',
      'current_version': '2.2.1',
      'current_build': 10,
    });
    expect(model.status, 'success');
    expect(apiClient.sentBody, isNot(contains('otp')));
  });

  test('OTP verification sends entered OTP and retains opaque proof', () async {
    apiClient.response = const Response(
      statusCode: 200,
      body: {
        'status': 'success',
        'resetProof': 'opaque.proof.value',
        'message': 'success',
      },
    );

    final response = await repository.verifyForgotPasswordOtp(
      email: 'a@example.com',
      otp: '654321',
    );
    final model = OtpVerificationResponse.fromJson(response.body);

    expect(apiClient.uri, '/Auth/VerifyForgotPasswordOtp');
    expect(apiClient.sentBody?['otp'], '654321');
    expect(model.resetProof, 'opaque.proof.value');
  });

  test('reset sends resetProof and never sends userId', () async {
    await repository.changePasswordToForgot(
      resetProof: 'opaque-proof',
      newPassword: 'new-secret',
      confirmPassword: 'new-secret',
    );

    expect(apiClient.method, 'PATCH');
    expect(apiClient.uri, '/Auth/ChangePasswordToForgot');
    expect(apiClient.sentBody?['resetProof'], 'opaque-proof');
    expect(apiClient.sentBody, isNot(contains('userId')));
  });

  test('HTTP 426 maps to explicit upgrade-required Arabic UX', () {
    const response = Response(
      statusCode: 426,
      body: {'status': 'upgrade_required', 'minimum_build': 10},
    );
    expect(upgradeRequiredMessage(response), contains('تحديث التطبيق'));
    expect(upgradeRequiredMessage(const Response(statusCode: 400)), isNull);
  });

  test('API debug output redacts OTP, proof, and passwords', () async {
    final messages = <String>[];
    final previous = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = previous);

    final request = http.Request(
      'PATCH',
      Uri.parse('https://example.test/Auth/ChangePasswordToForgot'),
    );
    final response = http.Response(
      '{"resetProof":"opaque-proof","otp":"654321","newPassword":"secret"}',
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
    apiClient.handleResponse(response, '/Auth/ChangePasswordToForgot');

    final output = messages.join('\n');
    expect(output, isNot(contains('opaque-proof')));
    expect(output, isNot(contains('654321')));
    expect(output, isNot(contains('secret')));
  });

  test('checkout attempt reuses UUID until success then creates a new one', () {
    final attempt = CheckoutAttempt();
    expect(attempt.begin(), isTrue);
    final first = attempt.id;
    expect(attempt.attachTo({'order': 1})['client_request_id'], first);
    expect(
      RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(first),
      isTrue,
    );

    expect(attempt.begin(), isFalse, reason: 'in-flight taps are coalesced');
    expect(attempt.id, first);
    attempt.finish(successful: false);
    expect(attempt.begin(), isTrue);
    expect(attempt.id, first, reason: 'transport retries reuse the ID');

    attempt.finish(successful: true);
    expect(attempt.begin(), isTrue);
    expect(attempt.id, isNot(first));
  });
}
