import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';

/// The single, centralised Material 3 theme.
///
/// Light is "fog and ink": a cool grey canvas, white cards, near-black type and one volt
/// accent. Dark inverts the roles (volt becomes the primary action) and keeps the same shapes.
abstract final class AppTheme {
  static ThemeData light() => _build(_lightScheme, ShopColors.light);
  static ThemeData dark() => _build(_darkScheme, ShopColors.dark);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Palette.ink,
    onPrimary: Palette.volt,
    primaryContainer: Palette.volt,
    onPrimaryContainer: Palette.ink,
    secondary: Palette.coral,
    onSecondary: Palette.ink,
    secondaryContainer: Color(0xFFFFDAD5),
    onSecondaryContainer: Color(0xFF5B0F08),
    tertiary: Color(0xFF3A47F5),
    onTertiary: Palette.white,
    error: Color(0xFFC8321F),
    onError: Palette.white,
    errorContainer: Color(0xFFFFE0DB),
    onErrorContainer: Color(0xFF5B0F08),
    surface: Palette.fog,
    onSurface: Palette.ink,
    onSurfaceVariant: Color(0xFF565B64),
    surfaceContainerLowest: Palette.white,
    surfaceContainerLow: Color(0xFFF8F9FA),
    surfaceContainer: Palette.white,
    surfaceContainerHigh: Color(0xFFE7EAED),
    surfaceContainerHighest: Color(0xFFDDE1E5),
    outline: Color(0xFF8A9099),
    outlineVariant: Color(0xFFD5D9DE),
    inverseSurface: Palette.ink,
    onInverseSurface: Palette.fog,
    inversePrimary: Palette.volt,
    shadow: Palette.ink,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Palette.volt,
    onPrimary: Palette.ink,
    primaryContainer: Palette.volt,
    onPrimaryContainer: Palette.ink,
    secondary: Color(0xFFFF6A5A),
    onSecondary: Palette.ink,
    secondaryContainer: Color(0xFF5A1D17),
    onSecondaryContainer: Color(0xFFFFDAD5),
    tertiary: Color(0xFF9AA3FF),
    onTertiary: Palette.ink,
    error: Color(0xFFFF8A7D),
    onError: Palette.ink,
    errorContainer: Color(0xFF5A1D17),
    onErrorContainer: Color(0xFFFFDAD5),
    surface: Palette.night,
    onSurface: Color(0xFFF1F2F4),
    onSurfaceVariant: Color(0xFFA6ABB4),
    surfaceContainerLowest: Color(0xFF07080A),
    surfaceContainerLow: Color(0xFF111317),
    surfaceContainer: Color(0xFF15171B),
    surfaceContainerHigh: Color(0xFF1D2026),
    surfaceContainerHighest: Color(0xFF272B32),
    outline: Color(0xFF6A707A),
    outlineVariant: Color(0xFF2A2E35),
    inverseSurface: Color(0xFFF1F2F4),
    onInverseSurface: Palette.ink,
    inversePrimary: Palette.ink,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: Colors.transparent,
  );

  static ThemeData _build(ColorScheme scheme, ShopColors shop) {
    final text = AppTypography.textTheme(scheme.onSurface);
    const stadium = StadiumBorder();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      textTheme: text,
      primaryTextTheme: text,
      fontFamily: AppTypography.body,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      extensions: [shop],
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: Radii.brL),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          minimumSize: const Size(64, 56),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          shape: stadium,
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: stadium,
          side: BorderSide(color: scheme.onSurface, width: 1.5),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          shape: stadium,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
        errorStyle: text.bodySmall?.copyWith(color: scheme.error, fontWeight: FontWeight.w600),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: _outline(scheme.outlineVariant, 1.5),
        enabledBorder: _outline(scheme.outlineVariant, 1.5),
        focusedBorder: _outline(scheme.onSurface, 2),
        errorBorder: _outline(scheme.error, 2),
        focusedErrorBorder: _outline(scheme.error, 2),
        disabledBorder: _outline(scheme.outlineVariant, 1),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primary,
        disabledColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outlineVariant),
        shape: stadium,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(color: scheme.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: shop.volt,
        indicatorShape: stadium,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 24, color: selected ? shop.onVolt : scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: shop.volt,
        indicatorShape: stadium,
        elevation: 0,
        minWidth: 84,
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(size: 24, color: shop.onVolt),
        unselectedIconTheme: IconThemeData(size: 24, color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.brXl),
        titleTextStyle: text.headlineMedium,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface, fontWeight: FontWeight.w600),
        actionTextColor: scheme.brightness == Brightness.light ? shop.volt : const Color(0xFF3A47F5),
        shape: const RoundedRectangleBorder(borderRadius: Radii.brM),
        insetPadding: const EdgeInsets.all(Gap.l),
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.onSurface,
        linearTrackColor: scheme.outlineVariant,
        circularTrackColor: Colors.transparent,
        linearMinHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? shop.onVolt : scheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? shop.volt : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? shop.onVolt : scheme.outline,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        minVerticalPadding: 12,
        shape: const RoundedRectangleBorder(borderRadius: Radii.brM),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: Radii.brS),
        textStyle: text.labelMedium?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: Radii.brM,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Shorthand for reading the theme from a build context.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  ShopColors get shop => Theme.of(this).extension<ShopColors>()!;
}
