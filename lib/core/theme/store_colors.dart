import 'package:flutter/material.dart';
import 'store_tokens.dart';

/// Keeps the approved light palette while adapting semantic surfaces and text.
abstract final class StoreColors {
  static Color resolve(BuildContext context, Color color) {
    final theme = Theme.of(context);
    if (theme.brightness != Brightness.dark) return color;
    if (color == StorePalette.surface) return theme.colorScheme.surface;
    if (color == StorePalette.background) return theme.scaffoldBackgroundColor;
    if (color == StorePalette.textPrimary || color == StorePalette.navy) {
      return theme.colorScheme.onSurface;
    }
    if (color == StorePalette.textSecondary) {
      return theme.colorScheme.onSurfaceVariant;
    }
    if (color == StorePalette.textDisabled) return theme.disabledColor;
    if (color == StorePalette.border) return theme.dividerColor;
    if (color == StorePalette.lightPurple) {
      return theme.colorScheme.primaryContainer;
    }
    if (color == StorePalette.derivedWarningSurface ||
        color == StorePalette.derivedErrorSurface ||
        color == StorePalette.derivedSuccessSurface ||
        color == StorePalette.derivedInfoSurface) {
      return Color.alphaBlend(
        color.withValues(alpha: 0.15),
        theme.colorScheme.surface,
      );
    }
    return color;
  }

  static TextStyle text(BuildContext context, TextStyle style) =>
      style.color == null
          ? style
          : style.copyWith(color: resolve(context, style.color!));
}
