// ignore_for_file: file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/helper/route_helper.dart';
import '../../repository/auth/auth_repository.dart';
import '../notification/notification_controller.dart';

abstract class SignUpController extends GetxController {
  Future<void> signUp();
  void goToSignIn();
}

class SignUpControllerImp extends SignUpController {
  SignUpControllerImp({
    required this.authRepository,
    VoidCallback? onRegistered,
    DateTime Function()? now,
    Future<String> Function()? notificationTokenProvider,
  }) : _onRegistered =
           onRegistered ?? (() => Get.offAllNamed(RouteHelper.signIn)),
       _now = now ?? DateTime.now,
       _notificationTokenProvider =
           notificationTokenProvider ?? _defaultNotificationToken;

  final StoreAuthGateway authRepository;
  final VoidCallback _onRegistered;
  final DateTime Function() _now;
  final Future<String> Function() _notificationTokenProvider;

  static Future<String> _defaultNotificationToken() async {
    if (!Get.isRegistered<NotificationController>()) return '';
    return Get.find<NotificationController>().freshToken();
  }

  final formstate = GlobalKey<FormState>();
  late final TextEditingController EmailController;
  late final TextEditingController PhoneController;
  late final TextEditingController PasswordController;
  late final TextEditingController ConfirmPassword;

  AuthUiStatus status = AuthUiStatus.idle;
  String? messageKey;

  bool get isSubmitting => status == AuthUiStatus.submitting;

  @override
  Future<void> signUp() async {
    if (isSubmitting) return;
    final email = EmailController.text.trim();
    final phone = PhoneController.text.trim();
    final password = PasswordController.text;
    final confirmation = ConfirmPassword.text;

    final form = formstate.currentState;
    if ((form != null && !form.validate()) ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationRequired');
      return;
    }
    if (!_looksLikeEmail(email)) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationEmail');
      return;
    }
    if (password.length < 8) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationPasswordLength');
      return;
    }
    if (password != confirmation) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationPasswordMatch');
      return;
    }

    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.createAccount(
      email: email,
      phoneNumber: phone,
      password: password,
      passwordConfirmation: confirmation,
      timestamp: _now(),
      notificationToken: await _notificationTokenProvider(),
    );
    switch (result) {
      case AuthSuccess<bool>():
        _setStatus(AuthUiStatus.success, 'storeRegistrationSuccess');
        _onRegistered();
      case AuthFailure<bool>(:final kind, :final messageKey):
        _setStatus(switch (kind) {
          AuthFailureKind.offline => AuthUiStatus.offline,
          AuthFailureKind.upgradeRequired => AuthUiStatus.upgradeRequired,
          _ => AuthUiStatus.failure,
        }, messageKey);
    }
  }

  bool _looksLikeEmail(String value) {
    final separator = value.indexOf('@');
    return separator > 0 && value.indexOf('.', separator) > separator + 1;
  }

  void _setStatus(AuthUiStatus value, String? key) {
    status = value;
    messageKey = key;
    update();
  }

  @override
  void goToSignIn() => Get.offNamed(RouteHelper.signIn);

  @override
  void onInit() {
    EmailController = TextEditingController();
    PhoneController = TextEditingController();
    PasswordController = TextEditingController();
    ConfirmPassword = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    EmailController.dispose();
    PhoneController.dispose();
    PasswordController.dispose();
    ConfirmPassword.dispose();
    super.onClose();
  }
}
