import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:overlay_kit/overlay_kit.dart';

import '../../core/functions/app_usage_service.dart';
import '../../core/classes/status_request.dart';
import '../../core/functions/checkInternet.dart';
import '../../core/helper/route_helper.dart';
import '../../core/model/auth_eesponse.dart';
import '../../core/widget/custom_snackbar.dart';
import '../../features/auth/forget_password/forget_password_page.dart';
import '../../repository/auth/auth_repository.dart';
import '../notification/notification_controller.dart';

abstract class LoginController extends GetxController {
  login();
  //signOut();
  goToSignUp();
  goToForgetPassword();
  // signInWithGoogle();
  // signInWithFacebook();
}

class LoginControllerImp extends LoginController {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController password;
  final AuthRepository authRepository;
  AuthResponse? userAuth;
  AuthModel? userAuth2;
  bool checkBox = false;
  bool _isLoggingIn = false;
  LoginControllerImp({required this.authRepository});

  late StatusRequest statusRequest;
  final NotificationController notificationController = Get.put(
    NotificationController(),
  );
  @override
  login() async {
    if (_isLoggingIn) return;
    _isLoggingIn = true;
    OverlayLoadingProgress.start();
    if (await CheckInternet.checkInternet()) {
      try {
        var formdata = formstate.currentState;
        if (formdata == null || !formdata.validate()) {
          showCustomSnackBar(
            'Please fill in all required fields'.tr,
            isError: true,
          );
          return;
        }

        statusRequest = StatusRequest.loading;

        var response = await authRepository.login(
          email.text,
          password.text,
          notificationController.fcmToken.value,
        );
        if (response.statusCode == 200) {
          userAuth = AuthResponse.fromJson(response.body);
          if (userAuth!.user.block == false) {
            await AppUsageService.saveUserId(userAuth!.user.id);
            await AppUsageService.saveToken(userAuth!.token);
            await AppUsageService.saveUserName(userAuth!.user.userName);
            await AppUsageService.saveUserEmail(userAuth!.user.email);
            await AppUsageService.saveTypeUser(userAuth!.user.typeUser!);
            if (checkBox == true) {
              await AppUsageService.saveIsLogin(true);
            }
            showCustomSnackBar("Login successfully".tr, isError: false);
            Get.offAllNamed(RouteHelper.homePage);
          } else {
            Get.snackbar(
              "Account Blocked",
              "Your account has been blocked. Please contact support.",
            );
          }
        } else {
          if (response.body['message'] != null) {
            showCustomSnackBar(response.body['message'], isError: true);
            showCustomSnackBar(response.body, isError: true);
          } else if (response.body['message'] == "ErrorInEmailOrPassword") {
            showCustomSnackBar("Wrong email or password".tr, isError: true);
          } else {
            showCustomSnackBar(
              'Sign in failed. Please try again.'.tr,
              isError: true,
            );
          }
        }
      } catch (e) {
        debugPrint('[STORE_LOGIN] error=$e');
        showCustomSnackBar(
          'An error occurred. Please try again.'.tr,
          isError: true,
        );
      } finally {
        _isLoggingIn = false;
        OverlayLoadingProgress.stop();
      }
    } else {
      _isLoggingIn = false;
      OverlayLoadingProgress.stop();
      showCustomSnackBar('Check the internet connection'.tr, isError: true);
    }
  }

  @override
  goToSignUp() {
    Get.offNamed(RouteHelper.signUp);
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  // @override
  // signOut() async {
  //   GoogleSignIn? googleSignIn = GoogleSignIn();
  //   googleSignIn.disconnect();
  //   FacebookAuth.instance.logOut();
  //   Get.toNamed(AppRoutes.loginScreen);
  // }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  goToForgetPassword() {
    Get.to(() => ForgetPasswordPage(email: email));
  }
}
