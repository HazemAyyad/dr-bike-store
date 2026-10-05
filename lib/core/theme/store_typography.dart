import 'package:flutter/material.dart';

import 'store_tokens.dart';

abstract final class StoreTypography {
  static const fontFamily = 'Cairo';

  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.35,
    fontWeight: bold,
    color: StorePalette.textPrimary,
  );
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.4,
    fontWeight: bold,
    color: StorePalette.textPrimary,
  );
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.45,
    fontWeight: semiBold,
    color: StorePalette.textPrimary,
  );
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.55,
    fontWeight: regular,
    color: StorePalette.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.55,
    fontWeight: medium,
    color: StorePalette.textPrimary,
  );
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.4,
    fontWeight: semiBold,
    color: StorePalette.textPrimary,
  );
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.45,
    fontWeight: regular,
    color: StorePalette.textSecondary,
  );

  static const textTheme = TextTheme(
    displaySmall: display,
    headlineSmall: headline,
    titleLarge: title,
    titleMedium: bodyMedium,
    bodyLarge: body,
    bodyMedium: body,
    labelLarge: label,
    bodySmall: caption,
    labelSmall: caption,
  );
}
