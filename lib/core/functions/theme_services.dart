import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  final GetStorage _box = GetStorage();
  final GetStorage box2 = GetStorage();
  final key = "isDarkMode";

  saveThemeToBox(bool isDarkMode) {
    _box.write(key, isDarkMode);
    box2.write(key, isDarkMode);
  }

  bool loadThemeFromBox() => _box.read<bool>(key) ?? false;

  ThemeMode get theme => loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    Get.changeThemeMode(loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    saveThemeToBox(!loadThemeFromBox());
  }
}
