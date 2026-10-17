import 'package:flutter/material.dart';

/// The raw palette. Widgets never use these directly: they read the `ColorScheme` or the
/// [ShopColors] extension so light and dark stay in step.
abstract final class Palette {
  // Brand.
  static const Color ink = Color(0xFF101114);
  static const Color volt = Color(0xFFD4FF3F);
  static const Color coral = Color(0xFFFF5E4D);

  // Light surfaces.
  static const Color fog = Color(0xFFF0F2F4);
  static const Color white = Color(0xFFFFFFFF);

  // Dark surfaces.
  static const Color night = Color(0xFF0B0C0F);
}

/// Colours that the Material `ColorScheme` has no slot for.
@immutable
class ShopColors extends ThemeExtension<ShopColors> {
  const ShopColors({
    required this.volt,
    required this.onVolt,
    required this.coral,
    required this.onCoral,
    required this.saleText,
    required this.star,
    required this.success,
    required this.warning,
    required this.orbShadow,
    required this.isDark,
  });

  /// The accent: selection, the active navigation pill, highlights.
  final Color volt;
  final Color onVolt;

  /// Fill for discount pills; text on it is [onCoral].
  final Color coral;
  final Color onCoral;

  /// A coral that passes 4.5:1 as text on the card colour.
  final Color saleText;
  final Color star;
  final Color success;
  final Color warning;
  final Color orbShadow;
  final bool isDark;

  static const ShopColors light = ShopColors(
    volt: Palette.volt,
    onVolt: Palette.ink,
    coral: Palette.coral,
    onCoral: Palette.ink,
    saleText: Color(0xFFC8321F),
    star: Color(0xFFF2A100),
    success: Color(0xFF0B7D57),
    warning: Color(0xFF8F5B00),
    orbShadow: Color(0x33101114),
    isDark: false,
  );

  static const ShopColors dark = ShopColors(
    volt: Palette.volt,
    onVolt: Palette.ink,
    coral: Color(0xFFFF6A5A),
    onCoral: Palette.ink,
    saleText: Color(0xFFFF8A7D),
    star: Color(0xFFFFC247),
    success: Color(0xFF3DDC97),
    warning: Color(0xFFFFC247),
    orbShadow: Color(0x99000000),
    isDark: true,
  );

  @override
  ShopColors copyWith({
    Color? volt,
    Color? onVolt,
    Color? coral,
    Color? onCoral,
    Color? saleText,
    Color? star,
    Color? success,
    Color? warning,
    Color? orbShadow,
    bool? isDark,
  }) {
    return ShopColors(
      volt: volt ?? this.volt,
      onVolt: onVolt ?? this.onVolt,
      coral: coral ?? this.coral,
      onCoral: onCoral ?? this.onCoral,
      saleText: saleText ?? this.saleText,
      star: star ?? this.star,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      orbShadow: orbShadow ?? this.orbShadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ShopColors lerp(ThemeExtension<ShopColors>? other, double t) {
    if (other is! ShopColors) return this;
    return ShopColors(
      volt: Color.lerp(volt, other.volt, t)!,
      onVolt: Color.lerp(onVolt, other.onVolt, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      onCoral: Color.lerp(onCoral, other.onCoral, t)!,
      saleText: Color.lerp(saleText, other.saleText, t)!,
      star: Color.lerp(star, other.star, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      orbShadow: Color.lerp(orbShadow, other.orbShadow, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
