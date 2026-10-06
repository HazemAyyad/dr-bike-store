import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/helper/route_helper.dart';
import '../../repository/auth/auth_repository.dart';

abstract class ForgetPasswordController extends GetxController {
  Future<void> checkEmail();
  Future<void> checkOTP();
  Future<void> resendOTP();
  Future<void> resetpassword();
  void next();
  void back();
  void goToLogin();
}

class ForgetPasswordControllerImp extends ForgetPasswordController {
  ForgetPasswordControllerImp({
    required this.authRepository,
    this.resendDuration = const Duration(seconds: 45),
    DateTime Function()? now,
    VoidCallback? onUpgradeRequired,
    this.initialIdentifier,
  }) : _now = now ?? DateTime.now,
       _onUpgradeRequired =
           onUpgradeRequired ??
           (() => Get.toNamed(
             RouteHelper.updateRequired,
             arguments: {'required': true, 'source': 'recovery'},
           ));

  final StoreAuthGateway authRepository;
  final Duration resendDuration;
  final DateTime Function() _now;
  final VoidCallback _onUpgradeRequired;
  final String? initialIdentifier;

  final formstate = GlobalKey<FormState>();
  final formstate2 = GlobalKey<FormState>();
  final formstate3 = GlobalKey<FormState>();
  final password = TextEditingController();
  final repassword = TextEditingController();
  final pageController = PageController();
  final email = TextEditingController();
  final otpController = TextEditingController();

  AuthUiStatus status = AuthUiStatus.idle;
  String? messageKey;
  String? resetProof;
  int currentPage = 0;
  int countdown = 0;
  bool canResend = false;
  Timer? _timer;
  DateTime? _resendAvailableAt;

  bool get isSubmitting => status == AuthUiStatus.submitting;

  String get maskedDestination {
    final value = email.text.trim();
    final at = value.indexOf('@');
    if (at > 1) return '${value.substring(0, 2)}***${value.substring(at)}';
    if (value.length > 4) {
      return '${value.substring(0, 2)}***${value.substring(value.length - 2)}';
    }
    return value;
  }

  void startTimer() {
    _timer?.cancel();
    _resendAvailableAt = _now().add(resendDuration);
    countdown = resendDuration.inSeconds;
    canResend = countdown <= 0;
    if (canResend) {
      update();
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _resendAvailableAt!.difference(_now()).inSeconds;
      countdown = remaining.clamp(0, resendDuration.inSeconds);
      if (countdown == 0) {
        canResend = true;
        _timer?.cancel();
      }
      update();
    });
    update();
  }

  @override
  Future<void> checkEmail() async {
    if (isSubmitting) return;
    final identifier = email.text.trim();
    final form = formstate2.currentState;
    if ((form != null && !form.validate()) || identifier.isEmpty) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationRequired');
      return;
    }

    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.requestPasswordReset(
      identifier: identifier,
    );
    switch (result) {
      case AuthSuccess():
        _setStatus(AuthUiStatus.success, null);
        currentPage = 1;
        _animateToCurrentPage();
        startTimer();
      case AuthFailure(:final kind, :final messageKey):
        _handleFailure(kind, messageKey);
    }
  }

  @override
  Future<void> resendOTP() async {
    if (!canResend || isSubmitting) return;
    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.requestPasswordReset(
      identifier: email.text.trim(),
    );
    switch (result) {
      case AuthSuccess():
        _setStatus(AuthUiStatus.success, 'storeOtpResent');
        startTimer();
      case AuthFailure(:final kind, :final messageKey):
        _handleFailure(kind, messageKey);
    }
  }

  @override
  Future<void> checkOTP() async {
    if (isSubmitting) return;
    final otp = otpController.text.trim();
    if (!RegExp(r'^\d{4,8}$').hasMatch(otp)) {
      _setStatus(AuthUiStatus.validationError, 'storeOtpInvalid');
      return;
    }

    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.verifyPasswordResetOtp(
      identifier: email.text.trim(),
      otp: otp,
    );
    switch (result) {
      case AuthSuccess(:final data):
        resetProof = data.resetProof;
        _timer?.cancel();
        _setStatus(AuthUiStatus.success, null);
        currentPage = 2;
        _animateToCurrentPage();
      case AuthFailure(:final kind, :final messageKey):
        _handleFailure(kind, messageKey);
    }
  }

  @override
  Future<void> resetpassword() async {
    if (isSubmitting) return;
    final proof = resetProof;
    if (proof == null || proof.isEmpty) {
      _setStatus(AuthUiStatus.failure, 'storeResetProofMissing');
      return;
    }
    final form = formstate3.currentState;
    if (form != null && !form.validate()) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationRequired');
      return;
    }
    if (password.text.length < 8) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationPasswordLength');
      return;
    }
    if (password.text != repassword.text) {
      _setStatus(AuthUiStatus.validationError, 'storeValidationPasswordMatch');
      return;
    }

    _setStatus(AuthUiStatus.submitting, null);
    final result = await authRepository.resetPassword(
      resetProof: proof,
      newPassword: password.text,
      confirmPassword: repassword.text,
    );
    switch (result) {
      case AuthSuccess():
        resetProof = null;
        _setStatus(AuthUiStatus.success, 'storeRecoveryCompleteMessage');
        currentPage = 3;
        _animateToCurrentPage();
      case AuthFailure(:final kind, :final messageKey):
        _handleFailure(kind, messageKey);
    }
  }

  void _handleFailure(AuthFailureKind kind, String key) {
    final nextStatus = switch (kind) {
      AuthFailureKind.offline => AuthUiStatus.offline,
      AuthFailureKind.blocked => AuthUiStatus.blocked,
      AuthFailureKind.upgradeRequired => AuthUiStatus.upgradeRequired,
      AuthFailureKind.otpInvalid => AuthUiStatus.otpInvalid,
      AuthFailureKind.otpExpired => AuthUiStatus.otpExpired,
      _ => AuthUiStatus.failure,
    };
    _setStatus(nextStatus, key);
    if (nextStatus == AuthUiStatus.upgradeRequired) {
      _onUpgradeRequired();
    }
  }

  void _setStatus(AuthUiStatus value, String? key) {
    status = value;
    messageKey = key;
    update();
  }

  void _animateToCurrentPage() {
    if (!pageController.hasClients) return;
    pageController.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  @override
  void back() {
    if (currentPage == 0) {
      Get.back();
      return;
    }
    currentPage--;
    _animateToCurrentPage();
    update();
  }

  @override
  void next() {
    if (currentPage < 3) currentPage++;
    _animateToCurrentPage();
    update();
  }

  @override
  void goToLogin() => Get.offAllNamed(RouteHelper.signIn);

  @override
  void onInit() {
    final identifier = initialIdentifier?.trim();
    if (identifier != null && identifier.isNotEmpty) email.text = identifier;
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    email.dispose();
    password.dispose();
    repassword.dispose();
    otpController.dispose();
    pageController.dispose();
    resetProof = null;
    super.onClose();
  }
}
