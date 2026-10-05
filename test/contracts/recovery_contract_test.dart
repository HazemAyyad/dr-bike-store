import 'package:doctor_bike/core/api_client.dart';
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

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient(SharedPreferences sharedPreferences)
    : super(sharedPreferences: sharedPreferences);

  String? uri;
  Map<String, dynamic>? body;

  @override
  Future<Response> patch(
    String uri, {
    Map<String, String>? headers,
    int? timeout,
    dynamic body,
  }) async {
    this.uri = uri;
    this.body = Map<String, dynamic>.from(body as Map);
    return const Response(statusCode: 200, body: {'status': 'success'});
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OTP response retains an opaque reset proof', () {
    final response = OtpVerificationResponse.fromJson({
      'status': 'success',
      'resetProof': 'opaque.proof.value',
      'message': 'verified',
    });

    expect(response.resetProof, 'opaque.proof.value');
    expect(missingResetProofMessage(response.resetProof), isNull);
    expect(missingResetProofMessage(null), isNotNull);
    expect(missingResetProofMessage(''), isNotNull);
  });

  test(
    'password reset submits proof and metadata without user identity',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final client = _RecordingApiClient(preferences);
      final repository = AuthRepository(
        apiClient: client,
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

      await repository.changePasswordToForgot(
        resetProof: 'opaque-proof',
        newPassword: 'new-secret',
        confirmPassword: 'new-secret',
      );

      expect(client.uri, '/Auth/ChangePasswordToForgot');
      expect(client.body?['resetProof'], 'opaque-proof');
      expect(client.body?['app'], 'store');
      expect(client.body?['platform'], 'android');
      expect(client.body, isNot(contains('userId')));
      expect(client.body, isNot(contains('otp')));
    },
  );

  test(
    'parsed API diagnostics redact reset proof, OTP, and passwords',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final client = ApiClient(sharedPreferences: preferences);
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
      client.handleResponse(
        http.Response(
          '{"resetProof":"opaque-proof","otp":"654321","newPassword":"secret"}',
          200,
          headers: {'content-type': 'application/json'},
          request: request,
        ),
        '/Auth/ChangePasswordToForgot',
      );

      final output = messages.join('\n');
      expect(output, isNot(contains('opaque-proof')));
      expect(output, isNot(contains('654321')));
      expect(output, isNot(contains('secret')));
    },
  );
}
