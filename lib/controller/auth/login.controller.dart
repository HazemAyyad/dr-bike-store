import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/functions/app_usage_service.dart';
import '../../core/helper/route_helper.dart';
import '../../repository/auth/auth_repository.dart';
import '../notification/notification_controller.dart';

abstract class LoginController extends GetxController {
  Future<void> login({
    FormState? form,
    required String identifier,
    required String password,
  });
  void goToSignUp();
  void goToForgetPassword(String identifier);
}

abstract interface class AuthSessionStore {
  Future<void> saveAuthenticatedSession(
    StoreAuthenticatedSession session, {
    required bool remember,
  });
}

class AppUsageAuthSessionStore implements AuthSessionStore {
  const AppUsageAuthSessionStore();

  @override
  Future<void> saveAuthenticatedSession(
    StoreAuthenticatedSession session, {
    required bool remember,
  }) async {
    await AppUsageService.saveUserId(session.userId);
    await AppUsageService.saveToken(session.token);
    await AppUsageService.saveUserName(session.displayName);
    await AppUsageService.saveUserEmail(session.email);
    if (session.typeUser case final typeUser?) {
      await AppUsageService.saveTypeUser(typeUser);
    }
    await AppUsageService.saveIsLogin(remember);
  }
}

class LoginControllerImp extends LoginController {
  LoginControllerImp({
    required this.authRepository,
    AuthSessionStore sessionStore = const AppUsageAuthSessionStore(),
    Future<String> Function()? notificationTokenProvider,
    VoidCallback? onAuthenticated,
  }) : _sessionStore = sessionStore,
       _notificationTokenProvider =
           notificationTokenProvider ?? _defaultNotificationToken,
       _onAuthenticated =
           onAuthenticated ?? (() => Get.offAllNamed(RouteHelper.homePage));

  final StoreAuthGateway authRepository;
  final AuthSessionStore _sessionStore;
  final Future<String> Function() _notificationTokenProvider;
  final VoidCallback _onAuthenticated;

  bool checkBox = false;
  AuthUiStatus status = AuthUiStatus.idle;
  String? messageKey;

  bool get isSubmitting => status == AuthUiStatus.submitting;
  bool get supportsSocialProviders => false;

  static Future<String> _defaultNotificationToken() async {
    if (!Get.isRegistered<NotificationController>()) return '';
    return Get.find<NotificationController>().freshToken();
  }

  @override
  Future<void> login({
    FormState? form,
    required String identifier,
    required String password,
  }) async {
    if (isSubmitting) return;
    final normalizedIdentifier = identifier.trim();
    if ((form != null && !form.validate()) ||
        normalizedIdentifier.isEmpty ||
        password.isEmpty) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationRequired');
      return;
    }

    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.authenticate(
      identifier: normalizedIdentifier,
      password: password,
      notificationToken: await _notificationTokenProvider(),
    );
    switch (result) {
      case AuthSuccess<StoreAuthenticatedSession>(:final data):
        await _sessionStore.saveAuthenticatedSession(data, remember: checkBox);
        _setStatus(AuthUiStatus.success, 'storeLoginSuccess');
        _onAuthenticated();
      case AuthFailure<StoreAuthenticatedSession>(
        :final kind,
        :final messageKey,
      ):
        _setStatus(_statusForFailure(kind), messageKey);
    }
  }

  AuthUiStatus _statusForFailure(AuthFailureKind kind) => switch (kind) {
    AuthFailureKind.offline => AuthUiStatus.offline,
    AuthFailureKind.blocked => AuthUiStatus.blocked,
    AuthFailureKind.upgradeRequired => AuthUiStatus.upgradeRequired,
    _ => AuthUiStatus.failure,
  };

  void _setStatus(AuthUiStatus value, String? key) {
    status = value;
    messageKey = key;
    update();
  }

  void setRemember(bool value) {
    checkBox = value;
    update();
  }

  @override
  void goToSignUp() => Get.toNamed(RouteHelper.signUp);

  @override
  void goToForgetPassword(String identifier) => Get.toNamed(
    RouteHelper.forgotPassword,
    arguments: {'identifier': identifier.trim()},
  );
}
