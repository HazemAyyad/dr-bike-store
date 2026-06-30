// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

ThemeData light({Color color = const Color(0xFF6B65BD)}) => ThemeData(
  // useMaterial3: false, // Uncomment if necessary
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  hoverColor: const Color(0xff0F0F31),
  secondaryHeaderColor: const Color(0xFF102e52),
  disabledColor: const Color(0xFFf3f3f3),
  brightness: Brightness.light,
  hintColor: const Color(0xFF727171),
  cardColor: Colors.white,
  scaffoldBackgroundColor: Colors.white, // Changed to scaffoldBackgroundColor
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: color),
  ),
  colorScheme: ColorScheme.light(primary: color, secondary: color)
      .copyWith(
        surface: Colors.white,
        primaryContainer: Color(0xffd3d1eb),
        secondaryContainer: Color(0xffeeeeee),
      )
      .copyWith(error: const Color(0xFFE84D4F)),
);

ThemeData dark({Color color = const Color(0xFF6B65BD)}) => ThemeData(
  // useMaterial3: false, // Uncomment if necessary
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  hoverColor: const Color(0xFFffffff),
  secondaryHeaderColor: const Color(0xFF102e52),
  disabledColor: const Color.fromARGB(255, 0, 0, 0),
  brightness: Brightness.light,
  hintColor: const Color(0xFFafafae),
  cardColor: Colors.black,
  scaffoldBackgroundColor: Color(0xFF121212),

  // Changed to scaffoldBackgroundColor
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: color),
  ),
  colorScheme: ColorScheme.light(primary: color, secondary: color)
      .copyWith(
        surface: Colors.black,
        primaryContainer: Color(0xffff4e4e4f),
        secondaryContainer: Color(0xff202020),
      )
      .copyWith(error: const Color(0xFFE84D4F)),
);
