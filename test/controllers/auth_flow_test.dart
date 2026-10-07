import 'package:doctor_bike/controller/auth/forgetpassword.controller.dart';
import 'package:doctor_bike/controller/auth/login.controller.dart';
import 'package:doctor_bike/controller/auth/signupController.dart';
import 'package:doctor_bike/core/model/otp_model.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeAuthGateway implements StoreAuthGateway {
  AuthResult<StoreAuthenticatedSession> loginResult = const AuthFailure(
    kind: AuthFailureKind.server,
    messageKey: 'storeAuthGenericError',
  );
  AuthResult<bool> registrationResult = const AuthSuccess(true);
  AuthResult<ForgotPasswordResponse> requestResult = const AuthSuccess(
    ForgotPasswordResponse(status: 'success', message: 'sent'),
  );
  AuthResult<OtpVerificationResponse> otpResult = const AuthSuccess(
    OtpVerificationResponse(
      status: 'success',
      resetProof: 'opaque-proof',
      message: 'verified',
    ),
  );
  AuthResult<bool> resetResult = const AuthSuccess(true);

  int loginCalls = 0;
  int registrationCalls = 0;
  int requestCalls = 0;
  int otpCalls = 0;
  int resetCalls = 0;
  String? submittedProof;

  @override
  Future<AuthResult<StoreAuthenticatedSession>> authenticate({
    required String identifier,
    required String password,
    required String notificationToken,
  }) async {
    loginCalls++;
    return loginResult;
  }

  @override
  Future<AuthResult<bool>> createAccount({
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required DateTime timestamp,
  }) async {
    registrationCalls++;
    return registrationResult;
  }

  @override
  Future<AuthResult<ForgotPasswordResponse>> requestPasswordReset({
    required String identifier,
  }) async {
    requestCalls++;
    return requestResult;
  }

  @override
  Future<AuthResult<OtpVerificationResponse>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) async {
    otpCalls++;
    return otpResult;
  }

  @override
  Future<AuthResult<bool>> resetPassword({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  }) async {
    resetCalls++;
    submittedProof = resetProof;
    return resetResult;
  }
}

class _RecordingSessionStore implements AuthSessionStore {
  StoreAuthenticatedSession? session;
  bool? remembered;

  @override
  Future<void> saveAuthenticatedSession(
    StoreAuthenticatedSession session, {
    required bool remember,
  }) async {
    this.session = session;
    remembered = remember;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('login validation blocks an empty submission', () async {
    final gateway = _FakeAuthGateway();
    final controller = Get.put(
      LoginControllerImp(
        authRepository: gateway,
        sessionStore: _RecordingSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );

    await controller.login(identifier: '', password: '');

    expect(gateway.loginCalls, 0);
    expect(controller.status, AuthUiStatus.validationError);
  });

  test('blocked login remains a blocking failure', () async {
    final gateway =
        _FakeAuthGateway()
          ..loginResult = const AuthFailure(
            kind: AuthFailureKind.blocked,
            messageKey: 'storeAuthBlocked',
          );
    final controller = Get.put(
      LoginControllerImp(
        authRepository: gateway,
        sessionStore: _RecordingSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );
    await controller.login(
      identifier: 'customer@example.test',
      password: 'not-logged',
    );

    expect(controller.status, AuthUiStatus.blocked);
    expect(controller.status, isNot(AuthUiStatus.success));
  });

  test(
    'successful login preserves authoritative session and remember choice',
    () async {
      const session = StoreAuthenticatedSession(
        userId: '42',
        token: 'opaque-token',
        displayName: 'Customer',
        email: 'customer@example.test',
        accountRoles: ['customer'],
      );
      final gateway =
          _FakeAuthGateway()..loginResult = const AuthSuccess(session);
      final store = _RecordingSessionStore();
      var navigated = false;
      final controller = Get.put(
        LoginControllerImp(
          authRepository: gateway,
          sessionStore: store,
          notificationTokenProvider: () async => 'fcm-token',
          onAuthenticated: () => navigated = true,
        ),
      );
      controller.checkBox = true;

      await controller.login(
        identifier: 'customer@example.test',
        password: 'not-logged',
      );

      expect(controller.status, AuthUiStatus.success);
      expect(store.session, same(session));
      expect(store.remembered, isTrue);
      expect(navigated, isTrue);
    },
  );

  test(
    'registration validation rejects mismatched passwords locally',
    () async {
      final gateway = _FakeAuthGateway();
      final controller = Get.put(
        SignUpControllerImp(authRepository: gateway, onRegistered: () {}),
      );
      controller.EmailController.text = 'customer@example.test';
      controller.PhoneController.text = '+970591234567';
      controller.PasswordController.text = 'StrongPass1';
      controller.ConfirmPassword.text = 'DifferentPass1';

      await controller.signUp();

      expect(gateway.registrationCalls, 0);
      expect(controller.status, AuthUiStatus.validationError);
    },
  );

  test('forgot-password request advances only after backend success', () async {
    final gateway = _FakeAuthGateway();
    final controller = Get.put(
      ForgetPasswordControllerImp(
        authRepository: gateway,
        resendDuration: const Duration(seconds: 3),
      ),
    );
    controller.email.text = 'customer@example.test';

    await controller.checkEmail();

    expect(gateway.requestCalls, 1);
    expect(controller.currentPage, 1);
    expect(controller.canResend, isFalse);
    expect(controller.countdown, 3);
  });

  test('development OTP response prefills the six-digit field', () async {
    final gateway =
        _FakeAuthGateway()
          ..requestResult = const AuthSuccess(
            ForgotPasswordResponse(
              status: 'success',
              message: 'sent',
              developmentOtp: '654321',
            ),
          );
    final controller = Get.put(
      ForgetPasswordControllerImp(authRepository: gateway),
    );
    controller.email.text = 'customer@example.test';

    await controller.checkEmail();

    expect(controller.otpController.text, '654321');
    expect(controller.currentPage, 1);
  });

  test('OTP resend countdown advances in real one-second steps', () async {
    final controller = Get.put(
      ForgetPasswordControllerImp(
        authRepository: _FakeAuthGateway(),
        resendDuration: const Duration(seconds: 1),
      ),
    );

    controller.startTimer();
    expect(controller.countdown, 1);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    expect(controller.countdown, 0);
    expect(controller.canResend, isTrue);
  });

  test('invalid and expired OTP remain distinct failures', () async {
    final gateway = _FakeAuthGateway();
    final controller = Get.put(
      ForgetPasswordControllerImp(authRepository: gateway),
    );
    controller.email.text = 'customer@example.test';
    controller.otpController.text = '123456';

    gateway.otpResult = const AuthFailure(
      kind: AuthFailureKind.otpInvalid,
      messageKey: 'storeOtpInvalid',
    );
    await controller.checkOTP();
    expect(controller.status, AuthUiStatus.otpInvalid);
    expect(controller.currentPage, 0);

    gateway.otpResult = const AuthFailure(
      kind: AuthFailureKind.otpExpired,
      messageKey: 'storeOtpExpired',
    );
    await controller.checkOTP();
    expect(controller.status, AuthUiStatus.otpExpired);
    expect(controller.currentPage, 0);
  });

  test(
    'proof-bound reset retains proof on failure and never reports success',
    () async {
      final gateway = _FakeAuthGateway();
      final controller = Get.put(
        ForgetPasswordControllerImp(authRepository: gateway),
      );
      controller.email.text = 'customer@example.test';
      controller.otpController.text = '123456';
      await controller.checkOTP();
      expect(controller.resetProof, 'opaque-proof');

      gateway.resetResult = const AuthFailure(
        kind: AuthFailureKind.server,
        messageKey: 'storeAuthGenericError',
      );
      controller.password.text = 'StrongPass1';
      controller.repassword.text = 'StrongPass1';
      await controller.resetpassword();

      expect(gateway.submittedProof, 'opaque-proof');
      expect(controller.resetProof, 'opaque-proof');
      expect(controller.status, AuthUiStatus.failure);
      expect(controller.currentPage, isNot(3));
    },
  );

  test('authoritative reset success clears the in-memory proof', () async {
    final gateway = _FakeAuthGateway();
    final controller = Get.put(
      ForgetPasswordControllerImp(authRepository: gateway),
    );
    controller.email.text = 'customer@example.test';
    controller.otpController.text = '123456';
    await controller.checkOTP();
    controller.password.text = 'StrongPass1';
    controller.repassword.text = 'StrongPass1';

    await controller.resetpassword();

    expect(gateway.submittedProof, 'opaque-proof');
    expect(controller.resetProof, isNull);
    expect(controller.status, AuthUiStatus.success);
    expect(controller.currentPage, 3);
  });
}
