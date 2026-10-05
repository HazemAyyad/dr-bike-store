import 'package:doctor_bike/features/category/category_screen.dart';
import 'package:get/get.dart';
import '../../features/acount/about_us_screen.dart';
import '../../features/acount/change_password_screen.dart';
import '../../features/acount/contact_us_screen.dart';
import '../../features/acount/personal_screen.dart';
import '../../features/acount/profile_screen.dart';
import '../../features/acount/terms_and_condotions.dart';
import '../../features/auth/signin/sign_in_screen.dart';
import '../../features/auth/forget_password/forget_password_page.dart';
import '../../features/auth/signup/sign_up_screen.dart';
import '../../features/category/filter_screen.dart';
import '../../features/home_screen/home_screen.dart';
import '../../features/intro/intro_log.dart';
import '../../features/lang/lang_screen.dart';

import '../../features/notification/notification_screen.dart';
import '../../features/onbarding/onbarding.dart';
import '../../features/order/order_screen.dart';
import '../../features/order/order_details_screen.dart';
import '../../features/product/product_details_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shop/check_out_done.dart';
import '../../features/shop/check_out_screen.dart';
import '../../features/splash/splash.dart';
import '../../features/splash/store_unavailable_screen.dart';
import '../../features/splash/update_required_screen.dart';
import '../../features/supCategory/supCategory.dart';

class RouteHelper {
  static const String initial = '/';
  static const String lang = '/LangScreen';
  static const String onBoardin = '/OnboardingScreen';
  static const String intoLog = '/IntroLog';
  static const String signIn = '/SignInScreen';
  static const String signUp = '/SignUpScreen';
  static const String forgotPassword = '/ForgotPasswordScreen';
  static const String storeUnavailable = '/StoreUnavailableScreen';
  static const String updateRequired = '/UpdateRequiredScreen';
  static const String homePage = '/HomePage';
  static const String categoreyPage = '/CategoreyPage';
  static const String checkOutScreen = '/CheckOutScreen';
  static const String checkOutDone = '/CheckOutDone';
  static const String notificationScreen = '/NotificationScreen';
  static const String filterPage = '/FilterPage';
  static const String profileScreen = '/ProfileScreen';
  static const String personalDetailsPage = '/PersonalDetailsPage';
  static const String changePasswordScreen = '/ChangePasswordScreen';
  static const String ordersScreen = '/OrdersScreen';
  static const String orderDetailsScreen = '/OrderDetailsScreen';
  static const String termsConditionsPage = '/TermsConditionsPage';
  static const String aboutUsScreen = '/AboutUsScreen';
  static const String contactUsPage = '/ContactUsPage';
  static const String categoryScreen = '/CategoryScreen';
  static const String searchScreen = '/searchScreen';
  static const String supcategoryScreen = '/SupcategoryScreen';
  static const String productDetailsScreen = '/ProductDetailsScreen';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: searchScreen, page: () => const SearchScreen()),
    GetPage(name: lang, page: () => const LangScreen()),
    GetPage(name: onBoardin, page: () => const OnboardingScreen()),
    GetPage(name: intoLog, page: () => const IntroLog()),
    GetPage(
      name: signIn,
      page: () => const SignInScreen(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: forgotPassword,
      page: () {
        final arguments = Get.arguments;
        return ForgetPasswordPage(
          initialIdentifier:
              arguments is Map ? arguments['identifier']?.toString() : null,
        );
      },
    ),
    GetPage(
      name: storeUnavailable,
      page: () => StoreUnavailableScreen.fromArguments(Get.arguments),
    ),
    GetPage(
      name: updateRequired,
      page: () => UpdateRequiredScreen.fromArguments(Get.arguments),
    ),
    GetPage(
      name: homePage,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: checkOutScreen, page: () => const CheckOutScreen()),
    GetPage(name: checkOutDone, page: () => const CheckOutDone()),

    GetPage(name: notificationScreen, page: () => NotificationScreen()),
    GetPage(name: filterPage, page: () => const FilterPage()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: personalDetailsPage, page: () => const PersonalDetailsPage()),
    GetPage(
      name: changePasswordScreen,
      page: () => const ChangePasswordScreen(),
    ),
    GetPage(name: termsConditionsPage, page: () => const TermsConditionsPage()),
    GetPage(name: aboutUsScreen, page: () => const AboutUsScreen()),
    GetPage(name: categoryScreen, page: () => CategoryScreen()),
    GetPage(name: contactUsPage, page: () => const ContactUsPage()),
    GetPage(name: ordersScreen, page: () => const OrderScreen()),
    GetPage(name: orderDetailsScreen, page: () => const OrderDetailsScreen()),
    GetPage(name: supcategoryScreen, page: () => const SupcategoryScreen()),
    GetPage(name: productDetailsScreen, page: () => ProductDetailsScreen()),
  ];
}
