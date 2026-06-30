// ignore_for_file: file_names, depend_on_referenced_packages, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:overlay_kit/overlay_kit.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/auth_eesponse.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../repository/auth/auth_repository.dart';

abstract class SignUpController extends GetxController {
  signUp();

  goToSignIn();
}

class SignUpControllerImp extends SignUpController {
  final AuthRepository authRepository;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late TextEditingController NameController;
  late TextEditingController EmailController;
  late TextEditingController PhoneController;
  late TextEditingController PasswordController;
  late TextEditingController ConfirmPassword;
  late TextEditingController rePasswordController;

  late PageController pageController;
  late TextEditingController searchController;

  UserSignUp? userAuth;
  List data = [];

  SignUpControllerImp({required this.authRepository});
  late StatusRequest statusRequest;

  @override
  signUp() async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat(
      "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
    ).format(now);

    if (await CheckInternet.checkInternet() != true) {
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
      return;
    }

    final formdata = formstate.currentState;
    if (formdata == null || !formdata.validate()) {
      showCustomSnackBar('errorRepassword'.tr, isError: true);
      return;
    }

    if (PasswordController.text != ConfirmPassword.text) {
      showCustomSnackBar("Password Not Match".tr, isError: true);
      return;
    }

    OverlayLoadingProgress.start();
    try {
      statusRequest = StatusRequest.loading;

      final response = await authRepository.register(
        email: EmailController.text.trim(),
        phoneNumber: PhoneController.text.trim(),
        password: PasswordController.text,
        passwordConfirmation: ConfirmPassword.text,
        date: formattedDate,
      );

      debugPrint(
        '[STORE_SIGNUP] status=${response.statusCode} body=${response.body}',
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("createAccount successfully".tr, isError: false);
        Get.offAllNamed(RouteHelper.signIn);
        return;
      }

      showCustomSnackBar(_signupErrorMessage(response.body), isError: true);
    } catch (e) {
      debugPrint('[STORE_SIGNUP] error=$e');
      showCustomSnackBar(
        'An error occurred. Please try again.'.tr,
        isError: true,
      );
    } finally {
      OverlayLoadingProgress.stop();
      update();
    }
  }

  String _signupErrorMessage(dynamic body) {
    if (body is Map) {
      final exception = body['exception'];
      if (exception is Map && exception['Message'] != null) {
        final message = exception['Message'].toString();
        if (message == 'Incorrect password.') return "Password Not Match".tr;
        return message;
      }

      final message = body['message']?.toString();
      if (message == "PasswordsMustBeAtLeast8Characters") {
        return "PasswordsMustBeAtLeast8Characters".tr;
      }
      if (message == "PasswordsMustHaveAtLeastOneLowercaseAndOneUppercase") {
        return "PasswordsMustHaveAtLeastOneLowercaseAndOneUppercase".tr;
      }
      if (message == "ErrorInEmailOrPassword") {
        return "Wrong email or password".tr;
      }
      if (message == "EmailIsExist" ||
          (message != null && message.toLowerCase().contains('email'))) {
        return "This email has been used.".tr;
      }
      if (message != null && message.isNotEmpty) return message;

      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }

    return 'An error occurred. Please try again.'.tr;
  }

  @override
  goToSignIn() {
    Get.offNamed(RouteHelper.signIn);
  }

  @override
  void onInit() {
    pageController = PageController();
    EmailController = TextEditingController();
    PhoneController = TextEditingController();
    PasswordController = TextEditingController();
    rePasswordController = TextEditingController();
    ConfirmPassword = TextEditingController();

    super.onInit();
  }

  @override
  void dispose() {
    EmailController.dispose();
    PhoneController.dispose();
    PasswordController.dispose();
    ConfirmPassword.dispose();
    rePasswordController.dispose();
    super.dispose();
  }
}
