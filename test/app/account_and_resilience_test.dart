import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/l10n/generated/app_localizations_hi.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

const String _mascara = 'Essence Mascara Lash Princess';

/// Scrolls the screen's list until [finder] is actually on screen (not merely built).
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(find.text(en.navProfile));
  await settle(tester);
}

void main() {
  group('profile', () {
    testWidgets('shows who is signed in', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      await _openProfile(tester);

      expect(find.text('Emily Johnson'), findsOneWidget);
      expect(find.text('emily.johnson@x.dummyjson.com'), findsOneWidget);
      expect(find.text('+81 965-431-3024'), findsOneWidget);
    });

    testWidgets('signing out asks first, then clears the session', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _openProfile(tester);
      await _scrollTo(tester, find.text(en.signOut));

      await tester.tap(find.text(en.signOut));
      await settle(tester);
      expect(find.text(en.signOutConfirmTitle), findsOneWidget);

      // Cancelling changes nothing.
      await tester.tap(find.text(en.cancel));
      await settle(tester);
      expect(find.text(en.loginHeadline), findsNothing);

      // Confirming does.
      await tester.tap(find.text(en.signOut));
      await settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(en.signOut),
        ),
      );
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.loginHeadline), findsOneWidget);
    });

    testWidgets('the language switch flips the whole app to Hindi', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _openProfile(tester);

      await _scrollTo(tester, find.text(en.languageHindi));
      await tester.tap(find.text(en.languageHindi));
      await settle(tester);

      final hindi = AppLocalizationsHi();
      expect(find.text(hindi.navCart), findsOneWidget);
      expect(find.text(en.navCart), findsNothing);
    });

    testWidgets('the app starts in a remembered language', (tester) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        preferences: {'settings.language': 'hi'},
      );

      expect(find.text(AppLocalizationsHi().loginHeadline), findsOneWidget);
      expect(find.text(en.loginHeadline), findsNothing);
    });

    testWidgets('a remembered dark theme is applied from the first frame', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        preferences: {'settings.theme': 'dark'},
      );

      final brightness = Theme.of(tester.element(find.byType(Scaffold).first))
          .brightness;
      expect(brightness, Brightness.dark);
    });
  });

  group('sessions that cannot be saved', () {
    testWidgets('an expired session at launch returns to login with a notice', (
      tester,
    ) async {
      final api = FakeShopApi()
        ..meStatus = 401
        ..refreshStatus = 403;

      await pumpShopApp(tester, api, secure: signedInStorage);

      expect(find.text(en.loginHeadline), findsOneWidget);
      expect(find.text(en.sessionEndedNotice), findsOneWidget);
    });

    testWidgets('the stored tokens are wiped when the session ends', (
      tester,
    ) async {
      final api = FakeShopApi()
        ..meStatus = 401
        ..refreshStatus = 403;

      final storage = await pumpShopApp(tester, api, secure: signedInStorage);

      expect(storage.containsKey('access_token'), isFalse);
      expect(storage.containsKey('refresh_token'), isFalse);
    });

    testWidgets('a failed sign-in explains itself and stays on the form', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi());

      await tester.enterText(
        find.widgetWithText(TextField, en.usernameLabel),
        'emilys',
      );
      await tester.enterText(
        find.widgetWithText(TextField, en.passwordLabel),
        'not-the-password',
      );
      await tester.tap(find.text(en.signIn));
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.invalidCredentials), findsOneWidget);
      expect(find.text(en.loginHeadline), findsOneWidget);
    });
  });

  group('error lab', () {
    Future<void> openLab(WidgetTester tester, FakeShopApi api) async {
      await pumpShopApp(tester, api, secure: signedInStorage);
      await _openProfile(tester);
      await _scrollTo(tester, find.text(en.profileDevTools));
      await tester.tap(find.text(en.profileDevTools));
      await settle(tester);
      expect(find.text(en.labTitle), findsOneWidget);
    }

    Future<void> run(WidgetTester tester, String title) async {
      await _scrollTo(tester, find.text(title));
      final card = find
          .ancestor(of: find.text(title), matching: find.byType(DecoratedBox))
          .first;
      final button = find.descendant(of: card, matching: find.text(en.labRun));
      await _scrollTo(tester, button);
      await tester.tap(button);
      await settle(tester, const Duration(seconds: 6));
    }

    testWidgets('a server error and a missing product become friendly states', (
      tester,
    ) async {
      await openLab(tester, FakeShopApi());

      await run(tester, en.labServerError);
      expect(find.text(en.labHandled), findsOneWidget);

      await run(tester, en.labNotFound);
      expect(find.text(en.labHandled), findsWidgets);
    });

    testWidgets('a slow answer is waited for; a very slow one times out', (
      tester,
    ) async {
      await openLab(tester, FakeShopApi());

      await run(tester, en.labSlow);
      // The elapsed time is measured with a real stopwatch, so only the wording is stable.
      expect(
        find.textContaining('The slow response arrived after'),
        findsOneWidget,
      );

      await run(tester, en.labTimeout);
      expect(find.text(en.labHandled), findsWidgets);
    });

    testWidgets('an expired token is refreshed and the request retried', (
      tester,
    ) async {
      final api = FakeShopApi();
      await openLab(tester, api);

      await run(tester, en.labExpired);

      expect(find.text(en.labRecovered), findsOneWidget);
      expect(api.to('/auth/refresh'), hasLength(1));
    });

    testWidgets('a rejected refresh token signs the user out', (tester) async {
      await openLab(tester, FakeShopApi());

      await run(tester, en.labRejectedRefresh);
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.loginHeadline), findsOneWidget);
      expect(find.text(en.sessionEndedNotice), findsOneWidget);
    });
  });

  group('responsive layouts', () {
    testWidgets('a tablet shows a navigation rail and a master-detail shop', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        size: const Size(1280, 800),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text(_mascara), findsOneWidget);

      // Opening a product fills the detail pane instead of leaving the list.
      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.productAbout), findsOneWidget);
      expect(find.text('Eyeshadow Palette with Mirror'), findsOneWidget);
    });

    testWidgets('a medium window uses a rail and a wider grid', (tester) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        size: const Size(820, 1100),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a phone uses the bottom bar', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('landscape on a phone does not overflow', (tester) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        size: const Size(844, 390),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(_mascara), findsOneWidget);
    });

    testWidgets('text at 1.3x does not overflow on the main screens', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        size: const Size(360, 740),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);

      for (final tab in [en.navSaved, en.navCart, en.navProfile, en.navShop]) {
        await tester.tap(find.text(tab));
        await settle(tester);
        expect(tester.takeException(), isNull, reason: 'overflow on $tab');
      }

      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));
      expect(tester.takeException(), isNull, reason: 'overflow on details');
    });
  });
}
