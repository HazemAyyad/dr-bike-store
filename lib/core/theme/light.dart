import 'package:flutter/material.dart';

import 'store_tokens.dart';
import 'store_typography.dart';

ThemeData light({Color color = StorePalette.purple}) {
  final scheme = const ColorScheme.light(
    primary: StorePalette.purple,
    onPrimary: Colors.white,
    secondary: StorePalette.purpleDark,
    onSecondary: Colors.white,
    surface: StorePalette.surface,
    onSurface: StorePalette.textPrimary,
    error: StorePalette.error,
    onError: Colors.white,
  ).copyWith(primary: color);

  return ThemeData(
    fontFamily: StoreTypography.fontFamily,
    textTheme: StoreTypography.textTheme,
    primaryColor: color,
    hoverColor: StorePalette.purpleSoft,
    secondaryHeaderColor: StorePalette.purpleDark,
    disabledColor: StorePalette.border,
    brightness: Brightness.light,
    hintColor: StorePalette.textSecondary,
    cardColor: StorePalette.surface,
    scaffoldBackgroundColor: StorePalette.background,
    colorScheme: scheme,
    dividerColor: StorePalette.border,
    splashColor: StorePalette.purple.withValues(alpha: 0.08),
    highlightColor: StorePalette.purple.withValues(alpha: 0.04),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: color,
        textStyle: StoreTypography.label,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StorePalette.surface,
      hintStyle: StoreTypography.body.copyWith(
        color: StorePalette.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: StoreSpacing.md,
        vertical: StoreSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoreRadii.md),
        borderSide: const BorderSide(color: StorePalette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoreRadii.md),
        borderSide: const BorderSide(color: StorePalette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoreRadii.md),
        borderSide: BorderSide(color: color, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(StoreRadii.md),
        borderSide: const BorderSide(color: StorePalette.error),
      ),
    ),
  );
}

ThemeData dark({Color color = StorePalette.purple}) {
  const darkSurface = Color(0xFF1B1B1F);
  const darkBackground = Color(0xFF121216);
  const darkText = Color(0xFFF4F4F6);
  final darkTextTheme = StoreTypography.textTheme.apply(
    bodyColor: darkText,
    displayColor: darkText,
  );

  return ThemeData(
    fontFamily: StoreTypography.fontFamily,
    textTheme: darkTextTheme,
    primaryColor: color,
    hoverColor: StorePalette.purpleSoft,
    secondaryHeaderColor: StorePalette.purpleDark,
    disabledColor: const Color(0xFF39393F),
    brightness: Brightness.dark,
    hintColor: const Color(0xFFB7B7BE),
    cardColor: darkSurface,
    scaffoldBackgroundColor: darkBackground,
    dividerColor: const Color(0xFF39393F),
    colorScheme: const ColorScheme.dark(
      primary: StorePalette.purple,
      onPrimary: Colors.white,
      secondary: StorePalette.purpleSoft,
      onSecondary: StorePalette.textPrimary,
      surface: darkSurface,
      onSurface: darkText,
      error: StorePalette.error,
      onError: Colors.white,
    ).copyWith(primary: color),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: StorePalette.purpleSoft,
        textStyle: StoreTypography.label,
      ),
    ),
  );
}
