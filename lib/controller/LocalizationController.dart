// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/dimensions.dart';
import '../core/helper/chache_helper.dart';
import '../core/helper/route_helper.dart';
import '../core/model/language_model.dart';

class LocalizationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;

  LocalizationController({required this.sharedPreferences}) {
    loadCurrentLanguage();
  }
  Locale _locale = Locale(
    AppConstants.languages[1].languageCode!,
    AppConstants.languages[1].countryCode,
  );
  bool _isLtr = true;
  List<LanguageModel> _languages = [];

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  List<LanguageModel> get languages => _languages;

  Locale initLang =
      CacheHelper.getData(key: 'lang') == null
          ? Locale(AppConstants.languages[1].languageCode!)
          : Locale(CacheHelper.getData(key: 'lang'));

  void changeLocale(String codeLang) {
    Locale locale = Locale(codeLang);
    CacheHelper.savedata(key: 'lang', value: codeLang);
    Get.updateLocale(locale);
  }

  void setLanguage(Locale locale) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = _locale.languageCode != 'ar' && _locale.languageCode != 'he';
    saveLanguage(_locale);
    update();
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(
      AppConstants.LANGUAGE_CODE,
      locale.languageCode,
    );
    sharedPreferences.setString(AppConstants.COUNTRY_CODE, locale.countryCode!);
  }

  void loadCurrentLanguage() async {
    _locale = Locale(
      sharedPreferences.getString(AppConstants.LANGUAGE_CODE) ??
          AppConstants.languages[0].languageCode!,
      sharedPreferences.getString(AppConstants.COUNTRY_CODE) ??
          AppConstants.languages[0].countryCode,
    );
    _isLtr = _locale.languageCode != 'ar' && _locale.languageCode != 'he';
    for (int index = 0; index < AppConstants.languages.length; index++) {
      if (AppConstants.languages[index].languageCode == _locale.languageCode) {
        _selectedIndex = index;
        break;
      }
    }
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  int selectedCondition = 0;
  Widget buildConditionButton({
    required String text,
    required int index,
    required BuildContext context,
  }) {
    bool isSelected = selectedCondition == index;
    return GestureDetector(
      onTap: () {
        selectedCondition = index;
        setLanguage(
          Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ),
        );
        setSelectIndex(index);
        Get.offNamed(RouteHelper.onBoardin);
        update();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        height: 45.h,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.fontSizeExtraLarge,
              color:
                  isSelected
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Theme.of(context).hintColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
