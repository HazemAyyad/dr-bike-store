import 'package:doctor_bike/controller/auth/login.controller.dart';
import 'package:doctor_bike/controller/auth/signupController.dart';
import 'package:doctor_bike/controller/auth/forgetpassword.controller.dart';
import 'package:doctor_bike/controller/check_account/account_service.dart';
import 'package:doctor_bike/core/locale/locale.dart';
import 'package:doctor_bike/core/constants/images.dart';
import 'package:doctor_bike/core/model/otp_model.dart';
import 'package:doctor_bike/core/theme/light.dart';
import 'package:doctor_bike/core/theme/store_typography.dart';
import 'package:doctor_bike/features/auth/signin/sign_in_screen.dart';
import 'package:doctor_bike/features/auth/signup/sign_up_screen.dart';
import 'package:doctor_bike/features/auth/forget_password/otp_page.dart';
import 'package:doctor_bike/features/auth/forget_password/send_otp_screen.dart';
import 'package:doctor_bike/features/auth/reset password/change_password_screen.dart';
import 'package:doctor_bike/features/onbarding/onbarding.dart';
import 'package:doctor_bike/features/splash/splash.dart';
import 'package:doctor_bike/features/splash/store_unavailable_screen.dart';
import 'package:doctor_bike/features/splash/update_required_screen.dart';
import 'package:doctor_bike/repository/auth/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedStartupResolver implements StartupResolver {
  const _FixedStartupResolver(this.decision);

  final StartupDecision decision;

  @override
  Future<StartupDecision> resolveStartup() async => decision;
}

class _NoopAuthGateway implements StoreAuthGateway {
  @override
  Future<AuthResult<StoreAuthenticatedSession>> authenticate({
    required String identifier,
    required String password,
    required String notificationToken,
  }) async => const AuthFailure(
    kind: AuthFailureKind.server,
    messageKey: 'storeAuthGenericError',
  );

  @override
  Future<AuthResult<bool>> createAccount({
    required String email,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    required DateTime timestamp,
  }) async => const AuthSuccess(true);

  @override
  Future<AuthResult<bool>> resetPassword({
    required String resetProof,
    required String newPassword,
    required String confirmPassword,
  }) async => const AuthSuccess(true);

  @override
  Future<AuthResult<ForgotPasswordResponse>> requestPasswordReset({
    required String identifier,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthResult<OtpVerificationResponse>> verifyPasswordResetOtp({
    required String identifier,
    required String otp,
  }) {
    throw UnimplementedError();
  }
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

  setUpAll(() async {
    final cairo = FontLoader(StoreTypography.fontFamily)
      ..addFont(rootBundle.load('assets/font/Cairo-Variable.ttf'));
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await cairo.load();
    await materialIcons.load();
  });

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(Get.reset);

  test('Phase 3 and 4 translation keys cover every supported locale', () {
    const requiredKeys = [
      'storeSplashBrand',
      'storeSplashLoading',
      'storeSplashInitializationError',
      'storeSkip',
      'storePrevious',
      'storeNext',
      'storeStartNow',
      'storeOnboardingAllTitle',
      'storeOnboardingQualityTitle',
      'storeOnboardingServiceTitle',
      'storeOfflineTitle',
      'storeMaintenanceTitle',
      'storeUpdateRequiredTitle',
      'storeUpdateRecommendedTitle',
      'storeLoginTitle',
      'storeIdentifierLabel',
      'storePassword',
      'storeRegisterTitle',
      'storeRecoveryRequestTitle',
      'storeOtpTitle',
      'storeOtpInvalid',
      'storeOtpExpired',
      'storeNewPasswordTitle',
      'storeRecoveryCompleteTitle',
    ];
    final translations = MyLocale().keys;
    final arabicStoreKeys =
        translations['ar']!.keys
            .where((key) => key.startsWith('store'))
            .toSet();

    for (final locale in const ['ar', 'en', 'he']) {
      final localeStoreKeys =
          translations[locale]!.keys
              .where((key) => key.startsWith('store'))
              .toSet();
      expect(
        localeStoreKeys,
        containsAll(arabicStoreKeys),
        reason: 'Store localization coverage differs for $locale',
      );
      for (final key in requiredKeys) {
        expect(
          translations[locale],
          contains(key),
          reason: 'Missing $key for $locale',
        );
        expect(translations[locale]![key], isNotEmpty);
      }
    }
  });

  testWidgets('reduced-motion splash shows the complete Arabic brand safely', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _ArabicTestApp(
        child: SplashScreen(
          resolver: const _FixedStartupResolver(
            StartupDecision(destination: StartupDestination.guestHome),
          ),
          reduceMotionOverride: true,
          onDecision: (_) {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Doctor Bike'), findsOneWidget);
    expect(find.text('جارٍ تجهيز المتجر'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding is Arabic RTL and survives large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(textScale: 1.3, child: OnboardingScreen()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(OnboardingScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(find.text('السابق'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline and maintenance render distinct localized states', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _ArabicTestApp(
        child: StoreUnavailableScreen(kind: StoreUnavailableKind.offline),
      ),
    );
    expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);

    await tester.pumpWidget(
      const _ArabicTestApp(
        child: StoreUnavailableScreen(
          kind: StoreUnavailableKind.maintenance,
          authoritativeMessage: 'صيانة مجدولة',
        ),
      ),
    );
    expect(find.text('المتجر غير متاح حاليًا'), findsOneWidget);
    expect(find.text('صيانة مجدولة'), findsOneWidget);
    expect(find.text('لا يوجد اتصال بالإنترنت'), findsNothing);
  });

  testWidgets('login is Arabic RTL and omits unsupported social providers', (
    tester,
  ) async {
    Get.put(
      LoginControllerImp(
        authRepository: _NoopAuthGateway(),
        sessionStore: _NoopSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(textScale: 1.3, child: SignInScreen()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SignInScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.textContaining('Google'), findsNothing);
    expect(find.textContaining('Apple'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('concurrent login routes own distinct form keys', (tester) async {
    Get.put(
      LoginControllerImp(
        authRepository: _NoopAuthGateway(),
        sessionStore: _NoopSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );

    await tester.pumpWidget(
      const _ArabicTestApp(
        child: Stack(children: [SignInScreen(), SignInScreen()]),
      ),
    );
    await tester.pump();

    expect(find.byType(Form), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration exposes only backend-supported identity fields', (
    tester,
  ) async {
    Get.put(
      SignUpControllerImp(
        authRepository: _NoopAuthGateway(),
        onRegistered: () {},
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(textScale: 1.3, child: SignUpScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('الاسم الكامل'), findsNothing);
    expect(find.textContaining('الشروط'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery steps render safely without exposing reset proof', (
    tester,
  ) async {
    final controller = Get.put(
      ForgetPasswordControllerImp(authRepository: _NoopAuthGateway()),
    );
    controller.email.text = 'customer@example.test';
    controller.resetProof = 'must-never-render';
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final screen in const <Widget>[
      OtpPage(),
      SendOtpScreen(),
      ResetPasswordScreen(),
    ]) {
      await tester.pumpWidget(
        _ArabicTestApp(textScale: 1.3, child: Scaffold(body: screen)),
      );
      await tester.pump();
      expect(find.text('must-never-render'), findsNothing);
      if (screen is SendOtpScreen) {
        expect(find.textContaining('cu***@example.test'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('auth and onboarding remain usable on a small phone viewport', (
    tester,
  ) async {
    Get.put(
      LoginControllerImp(
        authRepository: _NoopAuthGateway(),
        sessionStore: _NoopSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );
    Get.put(
      SignUpControllerImp(
        authRepository: _NoopAuthGateway(),
        onRegistered: () {},
      ),
    );
    Get.put(ForgetPasswordControllerImp(authRepository: _NoopAuthGateway()));
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final screen in const <Widget>[
      OnboardingScreen(),
      SignInScreen(),
      SignUpScreen(),
      Scaffold(body: OtpPage()),
      Scaffold(body: SendOtpScreen()),
      Scaffold(body: ResetPasswordScreen()),
    ]) {
      await tester.pumpWidget(_ArabicTestApp(textScale: 1.2, child: screen));
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('required update cannot continue and recommended update can', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ArabicTestApp(
        child: UpdateRequiredScreen(
          requirement: StoreUpdateRequirement.required,
          onRetry: () {},
        ),
      ),
    );
    expect(find.text('المتابعة الآن'), findsNothing);

    await tester.pumpWidget(
      _ArabicTestApp(
        child: UpdateRequiredScreen(
          requirement: StoreUpdateRequirement.recommended,
          onRetry: () {},
          onContinue: () {},
        ),
      ),
    );
    expect(find.text('المتابعة الآن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding first page has a deterministic regression render', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _ArabicTestApp(child: OnboardingScreen()));
    await tester.pumpAndSettle();
    final onboardingContext = tester.element(find.byType(OnboardingScreen));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(Images.onBoarding1),
        onboardingContext,
      );
      await precacheImage(const AssetImage(Images.logo), onboardingContext);
    });
    await tester.pump();

    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/p03-onboarding-ar-390x844.png'),
    );
  });

  testWidgets('onboarding second page has a deterministic regression render', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _ArabicTestApp(child: OnboardingScreen()));
    await tester.pumpAndSettle();
    final onboardingContext = tester.element(find.byType(OnboardingScreen));
    await tester.runAsync(
      () => precacheImage(
        const AssetImage(Images.onBoarding2),
        onboardingContext,
      ),
    );
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/p03-onboarding-2-ar-390x844.png'),
    );
  });

  testWidgets('onboarding third page has a deterministic regression render', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _ArabicTestApp(child: OnboardingScreen()));
    await tester.pumpAndSettle();
    final onboardingContext = tester.element(find.byType(OnboardingScreen));
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(Images.onBoarding2),
        onboardingContext,
      );
      await precacheImage(
        const AssetImage(Images.onBoarding3),
        onboardingContext,
      );
    });
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/p03-onboarding-3-ar-390x844.png'),
    );
  });

  testWidgets('login has a deterministic regression render', (tester) async {
    Get.put(
      LoginControllerImp(
        authRepository: _NoopAuthGateway(),
        sessionStore: _NoopSessionStore(),
        notificationTokenProvider: () async => '',
        onAuthenticated: () {},
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _ArabicTestApp(child: SignInScreen()));
    await _precacheAuthAssets(tester, find.byType(SignInScreen));
    await tester.pumpAndSettle();
    _expectAuthBackAtTop(tester);

    await expectLater(
      find.byType(SignInScreen),
      matchesGoldenFile('goldens/p04-login-ar-390x844.png'),
    );
  });

  testWidgets('registration has a deterministic regression render', (
    tester,
  ) async {
    Get.put(
      SignUpControllerImp(
        authRepository: _NoopAuthGateway(),
        onRegistered: () {},
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const _ArabicTestApp(child: SignUpScreen()));
    await _precacheAuthAssets(tester, find.byType(SignUpScreen));
    await tester.pumpAndSettle();
    _expectAuthBackAtTop(tester);

    await expectLater(
      find.byType(SignUpScreen),
      matchesGoldenFile('goldens/p04-register-ar-390x844.png'),
    );
  });

  testWidgets('recovery request has a deterministic regression render', (
    tester,
  ) async {
    Get.put(ForgetPasswordControllerImp(authRepository: _NoopAuthGateway()));
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(child: Scaffold(body: OtpPage())),
    );
    await _precacheAuthAssets(
      tester,
      find.byType(OtpPage),
      includeRecoveryIllustration: true,
    );
    await tester.pumpAndSettle();
    _expectAuthBackAtTop(tester);

    await expectLater(
      find.byType(OtpPage),
      matchesGoldenFile('goldens/p04-forgot-password-ar-390x844.png'),
    );
  });

  testWidgets('OTP entry has a deterministic regression render', (
    tester,
  ) async {
    final controller = Get.put(
      ForgetPasswordControllerImp(
        authRepository: _NoopAuthGateway(),
        resendDuration: Duration.zero,
      ),
    );
    controller.email.text = 'customer@example.test';
    controller.startTimer();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(child: Scaffold(body: SendOtpScreen())),
    );
    await _precacheAuthAssets(tester, find.byType(SendOtpScreen));
    await tester.pump(const Duration(milliseconds: 300));
    _expectAuthBackAtTop(tester);

    await expectLater(
      find.byType(SendOtpScreen),
      matchesGoldenFile('goldens/p04-otp-ar-390x844.png'),
    );
  });

  testWidgets('new password has a deterministic regression render', (
    tester,
  ) async {
    final controller = Get.put(
      ForgetPasswordControllerImp(authRepository: _NoopAuthGateway()),
    );
    controller.resetProof = 'test-only-proof';
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _ArabicTestApp(child: Scaffold(body: ResetPasswordScreen())),
    );
    await _precacheAuthAssets(tester, find.byType(ResetPasswordScreen));
    await tester.pumpAndSettle();
    _expectAuthBackAtTop(tester);

    await expectLater(
      find.byType(ResetPasswordScreen),
      matchesGoldenFile('goldens/p04-new-password-ar-390x844.png'),
    );
  });
}

void _expectAuthBackAtTop(WidgetTester tester) {
  final backButton = find.byKey(const ValueKey('auth-back-button'));
  expect(backButton, findsOneWidget);
  expect(tester.getTopLeft(backButton).dy, lessThanOrEqualTo(24));
}

Future<void> _precacheAuthAssets(
  WidgetTester tester,
  Finder screen, {
  bool includeRecoveryIllustration = false,
}) async {
  final context = tester.element(screen);
  await tester.runAsync(() async {
    await precacheImage(const AssetImage(Images.logo), context);
    if (includeRecoveryIllustration) {
      await precacheImage(
        const AssetImage(Images.passwordRecoveryIllustration),
        context,
      );
    }
  });
}

class _ArabicTestApp extends StatelessWidget {
  const _ArabicTestApp({required this.child, this.textScale = 1});

  final Widget child;
  final double textScale;

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: light(),
    locale: const Locale('ar'),
    translations: MyLocale(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    ),
  );
}
