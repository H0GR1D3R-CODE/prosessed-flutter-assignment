import 'package:flutter/material.dart';

/// Two faces with one job each.
///
/// Unbounded (wide and round, like the orbs) carries the brand: screen titles, prices and big
/// numbers. DM Sans carries everything you actually read. Both are bundled as assets, so the
/// app looks the same offline and on first launch.
abstract final class AppTypography {
  static const String display = 'Unbounded';
  static const String body = 'DM Sans';

  /// Builds the text theme with [color] as the default ink.
  static TextTheme textTheme(Color color) {
    TextStyle display_(
      double size,
      FontWeight weight, {
      double height = 1.15,
      double spacing = -0.4,
    }) => TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );
    TextStyle body_(
      double size,
      FontWeight weight, {
      double height = 1.4,
      double spacing = 0,
    }) => TextStyle(
      fontFamily: body,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color,
    );

    return TextTheme(
      displayLarge: display_(44, FontWeight.w700, height: 1.05, spacing: -1.2),
      displayMedium: display_(34, FontWeight.w700, height: 1.08, spacing: -0.9),
      displaySmall: display_(28, FontWeight.w600, height: 1.12, spacing: -0.7),
      headlineLarge: display_(26, FontWeight.w600, spacing: -0.6),
      headlineMedium: display_(21, FontWeight.w600, spacing: -0.4),
      headlineSmall: body_(20, FontWeight.w700, height: 1.25, spacing: -0.2),
      titleLarge: body_(20, FontWeight.w700, height: 1.25, spacing: -0.2),
      titleMedium: body_(16, FontWeight.w600, height: 1.3),
      titleSmall: body_(14, FontWeight.w600, height: 1.3),
      bodyLarge: body_(16, FontWeight.w400, height: 1.5),
      bodyMedium: body_(14, FontWeight.w400, height: 1.45),
      bodySmall: body_(12.5, FontWeight.w400, height: 1.4),
      labelLarge: body_(14, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelMedium: body_(12, FontWeight.w600, height: 1.2, spacing: 0.2),
      labelSmall: body_(11.5, FontWeight.w600, height: 1.2, spacing: 0.4),
    );
  }

  /// Prices: Unbounded, with figures that keep their width so a column of prices lines up.
  static TextStyle price(
    Color color, {
    double size = 16,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.1,
      letterSpacing: -0.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
