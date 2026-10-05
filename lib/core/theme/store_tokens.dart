import 'package:flutter/material.dart';

/// Approved Store design primitives. Screen-specific values should be promoted
/// here only after they are calibrated against the reference boards.
abstract final class StorePalette {
  static const purple = Color(0xFF6B65BD);
  static const purpleDark = Color(0xFF514AA8);
  static const purpleSoft = Color(0xFFF0EFFA);
  static const background = Color(0xFFF7F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF20212B);
  static const textSecondary = Color(0xFF6F7180);
  static const border = Color(0xFFE3E4E8);
  static const success = Color(0xFF278A5B);
  static const successSoft = Color(0xFFE8F5EE);
  static const warning = Color(0xFFF2994A);
  static const warningSoft = Color(0xFFFFF3E7);
  static const error = Color(0xFFE84D4F);
  static const errorSoft = Color(0xFFFDEBEC);
  static const info = Color(0xFF3478C8);
  static const infoSoft = Color(0xFFEAF2FC);
  static const scrim = Color(0x66000000);
}

abstract final class StoreSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
}

abstract final class StoreRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 24.0;
  static const round = 999.0;
}

abstract final class StoreElevation {
  static const none = 0.0;
  static const low = 1.0;
  static const medium = 4.0;
  static const high = 8.0;

  static const lowShadow = BoxShadow(
    color: Color(0x0F20212B),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const mediumShadow = BoxShadow(
    color: Color(0x1920212B),
    blurRadius: 16,
    offset: Offset(0, 6),
  );
}

abstract final class StoreIconSizes {
  static const small = 16.0;
  static const medium = 20.0;
  static const standard = 24.0;
  static const large = 32.0;
}

abstract final class StoreMotion {
  static const fast = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
}

/// Named values which still require device screenshot calibration.
abstract final class StoreCalibration {
  static const screenPadding = StoreSpacing.md;
  static const controlHeight = 48.0;
  static const topBarHeight = 72.0;
  static const bottomNavigationHeight = 72.0;
  static const productMediaAspectRatio = 1.05;
  static const outlineWidth = 1.0;
}
