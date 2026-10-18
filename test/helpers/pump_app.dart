import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/l10n/generated/app_localizations_en.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The English strings, for asserting on copy without repeating it in every test.
final AppLocalizations en = AppLocalizationsEn();

/// Mounts [child] in the real theme and localisations.
///
/// Uses a single `pump` rather than `pumpAndSettle`: the app's orbit animations repeat forever,
/// so the tree never settles.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
  double textScale = 1,
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
}
