// ignore_for_file: constant_identifier_names

import '../model/language_model.dart';

String? shareLink;

class AppConstants {
  static const String appName = 'doctor bike';
  static const double appVersion = 1.0;

  static const String fontFamily = 'Almarai';
  static const String key = "isDarkMode";
  static const String items = "items";
  static const String FirstLog = 'FirstLog';
  static const String appBaseUrl = "https://dr-bike.duosparktech.com/public";
  static const String storePublicBaseUrl = String.fromEnvironment(
    'STORE_PUBLIC_BASE_URL',
    defaultValue: appBaseUrl,
  );
  static const String userId = 'userId';
  static const String ISLOGIN = 'ISLOGIN';
  static const String userName = 'userName';
  static const String userEmail = 'userEmail';
  static const String typeUser = 'typeUser';

  // Shared Key
  static const String THEME = 'Doctor_Bike_theme';
  static const String TOKEN = 'Doctor_Bike_token';
  static const String COUNTRY_CODE = 'doctorBikeCountry_code';
  static const String LANGUAGE_CODE = 'doctorBikeLanguage_code';

  static String productShareUrl(int productId) {
    if (productId <= 0) {
      throw ArgumentError.value(productId, 'productId', 'must be positive');
    }

    final base = Uri.parse(storePublicBaseUrl);
    final pathSegments = <String>[
      ...base.pathSegments.where((segment) => segment.trim().isNotEmpty),
      'store',
      'products',
      '$productId',
    ];

    return base
        .replace(pathSegments: pathSegments, query: null, fragment: null)
        .toString();
  }

  static List<LanguageModel> languages = [
    LanguageModel(languageName: 'عربى', countryCode: 'SA', languageCode: 'ar'),
    LanguageModel(
      languageName: 'English',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      languageName: 'Hebrew',
      countryCode: 'HE',
      languageCode: 'he',
    ),
  ];
}
