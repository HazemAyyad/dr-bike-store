import 'package:doctor_bike/controller/auth/login.controller.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/model/otp_model.dart';
import 'package:doctor_bike/features/auth/signin/sign_in_screen.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _SuccessfulAuthGateway implements StoreAuthGateway {
  @override
  Future<AuthResult<StoreAuthenticatedSession>> authenticate({
    required String identifier,
    required String password,
    required String notificationToken,
  }) async => const AuthSuccess(
    StoreAuthenticatedSession(
      userId: '114',
      token: 'opaque-token',
      displayName: 'Customer',
      email: 'customer@example.test',
      accountRoles: ['customer'],
    ),
  );

  @override
  Future<AuthResult<bool>> createAccount({
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required DateTime timestamp,
  }) => throw UnimplementedError();

  @override
  Future<AuthResult<ForgotPasswordResponse>> requestPasswordReset({
    required String identifier,
  }) => throw UnimplementedError();

  @override
  Future<AuthResult<bool>> resetPassword({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  }) => throw UnimplementedError();

  @override
  Future<AuthResult<OtpVerificationResponse>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) => throw UnimplementedError();
}

class _NoopSessionStore implements AuthSessionStore {
  @override
  Future<void> saveAuthenticatedSession(
    StoreAuthenticatedSession session, {
    required bool remember,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  testWidgets('overlapping login routes do not share editable field state', (
    tester,
  ) async {
    Get.put(
      LoginControllerImp(
        authRepository: _SuccessfulAuthGateway(),
        sessionStore: _NoopSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        translations: MyLocale(),
        home: const Stack(children: [SignInScreen(), SignInScreen()]),
      ),
    );
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'first@example.test');

    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'first@example.test',
    );
    expect(
      tester.widget<TextFormField>(fields.at(2)).controller!.text,
      isEmpty,
    );
  });

  testWidgets(
    'successful login disposes its route without field lifecycle errors',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('ar'),
          translations: MyLocale(),
          initialRoute: '/login',
          getPages: [
            GetPage(
              name: '/login',
              page: () => const SignInScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut(
                  () => LoginControllerImp(
                    authRepository: _SuccessfulAuthGateway(),
                    sessionStore: _NoopSessionStore(),
                    notificationTokenProvider: () async => '',
                    onAuthenticated: () => Get.offAllNamed('/home'),
                  ),
                );
              }),
            ),
            GetPage(
              name: '/home',
              page: () => const Scaffold(body: Text('HOME')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'customer@example.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      expect(Get.isRegistered<LoginControllerImp>(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
