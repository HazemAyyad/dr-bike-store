import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

class ThemeServices {
  ThemeServices({GetStorage? storage}) : _box = storage ?? GetStorage();

  final GetStorage _box;
  static const key = AppConstants.key;

  void saveThemeToBox(bool isDarkMode) {
    _box.write(key, isDarkMode);
  }

  bool loadThemeFromBox() => _box.read<bool>(key) ?? false;

  ThemeMode get theme => loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    final isDarkMode = loadThemeFromBox();
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox(!isDarkMode);
  }
}
