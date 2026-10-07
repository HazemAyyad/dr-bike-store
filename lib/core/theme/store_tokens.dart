import 'package:flutter/material.dart';

/// Approved Store design primitives. Screen-specific values should be promoted
/// here only after they are calibrated against the reference boards.
abstract final class StorePalette {
  static const navy = Color(0xFF0F0F31);
  static const purple = Color(0xFF6B65BD);
  static const lightPurple = Color(0xFFE9E8F7);
  static const background = Color(0xFFF8F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF22A06B);
  static const warning = Color(0xFFF5A623);
  static const error = Color(0xFFEB4D4F);
  static const info = Color(0xFF3B82F6);
  static const textPrimary = Color(0xFF17172B);
  static const textSecondary = Color(0xFF73737D);
  static const textDisabled = Color(0xFFA0A3B1);
  static const border = Color(0xFFE5E6EA);

  /// Derived state surfaces; these are not approved base palette tokens.
  static const derivedSuccessSurface = Color(0xFFE8F5EE);
  static const derivedWarningSurface = Color(0xFFFFF3E7);
  static const derivedErrorSurface = Color(0xFFFDEBEC);
  static const derivedInfoSurface = Color(0xFFEAF2FC);
  static const derivedScrim = Color(0x66000000);
  static const derivedLoadingOverlay = Color(0x33FFFFFF);
  static const derivedNavyGlow = Color(0xFF25254D);
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
    color: Color(0x0F17172B),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const mediumShadow = BoxShadow(
    color: Color(0x1917172B),
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
  static const compactControlHeight = 40.0;
  static const homeHeroHeight = 168.0;
  static const homeQuickCategoryWidth = 64.0;
  static const homeQuickCategoryHeight = 96.0;
  static const homeStoreCategoryWidth = 84.0;
  static const homeStoreCategoryHeight = 120.0;
  static const homeProductCardWidth = 112.0;
  static const homeProductCardHeight = 236.0;
  static const searchResultCardHeight = 140.0;
  static const outlineWidth = 1.0;
  static const authContentMaxWidth = 420.0;
  static const authViewportInsetAdjustment = 36.0;
  static const authLogoWidth = 104.0;
  static const authLogoHeight = 72.0;
  static const authStateIconExtent = 112.0;
  static const authSuccessIconSize = 58.0;
  static const updateIconSize = 54.0;
  static const otpCellExtent = 56.0;
  static const onboardingMediaFraction = 0.57;
  static const onboardingMediaMinHeight = 190.0;
  static const onboardingMediaMaxHeight = 430.0;
  static const splashLogoWidth = 230.0;
  static const splashLogoHeight = 150.0;
  static const splashWordmarkFontSize = 34.0;
  static const splashProgressWidth = 190.0;
  static const splashTrailGlowWidth = 18.0;
  static const splashTrailLineWidth = 2.0;
  static const splashSequence = Duration(milliseconds: 3200);
  static const splashMinimumDisplay = Duration(milliseconds: 3200);
  static const splashInitializationTimeout = Duration(seconds: 12);
}
