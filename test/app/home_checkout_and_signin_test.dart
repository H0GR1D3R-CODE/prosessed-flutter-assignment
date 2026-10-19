import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';
import 'package:shopsphere/features/products/presentation/widgets/home_showcase.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';
import '../helpers/shop_finders.dart';

const String _mascara = 'Essence Mascara Lash Princess';

Future<void> _signInWithDemo(WidgetTester tester) async {
  await tester.tap(find.text(en.useDemoAccount));
  await tester.pump();
  await tester.tap(find.text(en.signIn));
  await settle(tester, const Duration(seconds: 1));
}

/// Adds one mascara and opens the checkout page.
Future<void> _toCheckout(WidgetTester tester) async {
  await scrollToGrid(tester);
  await tester.tap(inGrid(_mascara));
  await settle(tester, const Duration(seconds: 1));
  await tester.tap(find.textContaining(en.addToCart));
  await settle(tester, const Duration(seconds: 5));
  await tester.tap(find.byTooltip(en.back));
  await settle(tester);
  await tester.tap(find.text(en.navCart));
  await settle(tester);
  await tester.tap(find.text(en.cartCheckout));
  await settle(tester);
}

Future<void> _show(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('the home page', () {
    testWidgets('opens with offers and shelves, which give way to a search', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      expect(find.byType(HomeHero), findsOneWidget);
      expect(find.text(en.homeDealTag.toUpperCase()), findsOneWidget);
      expect(find.text(en.shelfDealsTitle), findsOneWidget);

      // The main grid, under its own heading, comes after the shelves.
      await scrollToGrid(tester);
      expect(find.text(en.shelfAllTitle), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'phone');
      await settle(tester, const Duration(seconds: 1));

      expect(find.byType(HomeHero), findsNothing);
      expect(find.text(en.shelfDealsTitle), findsNothing);
      expect(find.text(en.shelfAllTitle), findsNothing);
    });

    testWidgets('the offers slide on their own, and the code can be copied', (
      tester,
    ) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      final pages = find.byType(PageView);
      double page() => tester.widget<PageView>(pages).controller!.page!;
      expect(page(), closeTo(0, 0.01));

      // After a few seconds the carousel moves on to the promo code slide.
      await settle(tester, const Duration(seconds: 6));
      expect(page(), closeTo(1, 0.01));

      await tester.tap(find.text('WELCOME10'));
      await settle(tester, const Duration(milliseconds: 400));

      expect(copied, ['WELCOME10']);
      expect(find.text(en.homeCouponCopied('WELCOME10')), findsOneWidget);
    });

    testWidgets(
      'offline, the saved products appear under a notice at the top',
      (tester) async {
        // A first visit online fills the cache...
        await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
        final prefs = sl<SharedPreferences>();
        final saved = {for (final key in prefs.getKeys()) key: prefs.get(key)!};
        await tester.pumpWidget(const SizedBox());
        await sl.reset();

        // ...so a second one with no connection still has something to show.
        await pumpShopApp(
          tester,
          FakeShopApi()..offline = true,
          secure: signedInStorage,
          preferences: saved,
        );

        expect(find.text(en.shopOfflineBanner), findsOneWidget);
        expect(find.byType(HomeHero), findsOneWidget);
        expect(
          tester.getTopLeft(find.text(en.shopOfflineBanner)).dy,
          lessThan(tester.getTopLeft(find.byType(HomeHero)).dy),
          reason:
              'the notice comes first, so it is not hidden under the shelves',
        );
      },
    );

    testWidgets('tapping the deal of the day opens that product', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      await tester.tap(find.text(en.homeDealCta));
      await settle(tester, const Duration(seconds: 1));

      expect(find.byType(ProductDetailsPage), findsOneWidget);
    });
  });

  group('checkout', () {
    testWidgets('a promo code and a donation change the total and are kept', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _toCheckout(tester);
      // One mascara costs 8.94.
      expect(find.textContaining(r'$8.94'), findsWidgets);

      await _show(tester, find.byKey(const ValueKey('coupon-WELCOME10')));
      await tester.tap(find.byKey(const ValueKey('coupon-WELCOME10')));
      await settle(tester);
      expect(find.text(en.couponApplied('WELCOME10')), findsOneWidget);
      // 10% off 8.94 is 0.89, which leaves 8.05.
      expect(
        find.text(en.checkoutPlaceOrderWithTotal(r'$8.05')),
        findsOneWidget,
      );

      await _show(tester, find.byKey(const ValueKey('donation-fixed-1.0')));
      await tester.tap(find.byKey(const ValueKey('donation-fixed-1.0')));
      await settle(tester);
      expect(
        find.text(en.checkoutPlaceOrderWithTotal(r'$9.05')),
        findsOneWidget,
      );

      await tester.tap(find.textContaining(en.checkoutPlaceOrder).last);
      await settle(tester, const Duration(seconds: 2));

      expect(find.text(en.orderPlacedTitle), findsOneWidget);
      expect(find.textContaining(r'$9.05'), findsWidgets);
      expect(find.textContaining(en.couponLine('WELCOME10')), findsOneWidget);
      expect(find.text(en.giveThanks(r'$1.00')), findsOneWidget);

      // The order history keeps both lines.
      await tester.tap(find.text(en.orderViewOrders));
      await settle(tester);
      await tester.tap(find.text(en.orderNumber(209)));
      await settle(tester);
      expect(find.text(en.couponLine('WELCOME10')), findsOneWidget);
      expect(find.text(en.giveLine), findsOneWidget);
      expect(find.text(r'$9.05'), findsWidgets);
    });

    testWidgets('a wrong code says so, and a code needing more says how much', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _toCheckout(tester);

      await _show(tester, find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'NOPE');
      // The field scrolls itself into view; taps are ignored for that moment, as for a real user.
      await settle(tester, const Duration(milliseconds: 500));
      await tester.tap(find.widgetWithText(FilledButton, en.couponApply));
      await settle(tester);
      expect(find.text(en.couponUnknown), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'save5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);
      // The order is 8.94 and SAVE5 starts at 25.00.
      expect(find.text(en.couponTooSmall('SAVE5', r'$16.06')), findsOneWidget);
      expect(find.text(en.couponApplied('SAVE5')), findsNothing);
    });

    testWidgets('an applied code can be taken off again', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _toCheckout(tester);

      await _show(tester, find.byKey(const ValueKey('coupon-WELCOME10')));
      await tester.tap(find.byKey(const ValueKey('coupon-WELCOME10')));
      await settle(tester);
      await _show(tester, find.byTooltip(en.couponRemove));
      await tester.tap(find.byTooltip(en.couponRemove));
      await settle(tester);

      expect(find.text(en.couponApplied('WELCOME10')), findsNothing);
      expect(
        find.text(en.checkoutPlaceOrderWithTotal(r'$8.94')),
        findsOneWidget,
      );
    });

    testWidgets('the cart points at the code box and shows the saving', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await scrollToGrid(tester);
      await tester.tap(inGrid(_mascara));
      await settle(tester, const Duration(seconds: 1));
      await tester.tap(find.textContaining(en.addToCart));
      await settle(tester, const Duration(seconds: 5));
      await tester.tap(find.byTooltip(en.back));
      await settle(tester);
      await tester.tap(find.text(en.navCart));
      await settle(tester);

      expect(find.text(en.cartSavings(r'$1.05')), findsOneWidget);
      expect(find.text(en.cartPromoTitle), findsOneWidget);

      await tester.tap(find.text(en.cartPromoTitle));
      await settle(tester);
      expect(find.text(en.couponTitle), findsOneWidget);
    });
  });

  group('the search box', () {
    testWidgets('lets go of the keyboard when a category is chosen', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      bool searchHasFocus() => tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode
          .hasFocus;

      await tester.tap(find.byType(TextField));
      await settle(tester, const Duration(milliseconds: 300));
      expect(searchHasFocus(), isTrue);

      await tester.tap(find.bySemanticsLabel('Beauty'));
      await settle(tester);

      expect(searchHasFocus(), isFalse);
    });
  });

  group('quick add and buy again', () {
    testWidgets('the + on a product card adds it without opening it', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await scrollToGrid(tester);

      final card = find.ancestor(
        of: inGrid(_mascara),
        matching: find.byType(ProductCard),
      );
      await tester.tap(
        find.descendant(of: card, matching: find.byType(QuickAddButton)),
      );
      await settle(tester, const Duration(milliseconds: 600));

      expect(find.text(en.addedToCart(1, _mascara)), findsOneWidget);
      expect(
        find.byType(ProductDetailsPage),
        findsNothing,
        reason: 'stayed put',
      );

      await tester.tap(find.text(en.viewCart));
      await settle(tester);
      expect(find.text(en.cartTitle), findsOneWidget);
      expect(find.text(_mascara), findsOneWidget);
    });

    testWidgets('screen readers can reach the heart and the + on a card', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await scrollToGrid(tester);

      expect(find.bySemanticsLabel(en.quickAdd(_mascara)), findsWidgets);
      expect(find.bySemanticsLabel(en.wishlistAdd(_mascara)), findsWidgets);
      semantics.dispose();
    });

    testWidgets('every product in stock has a + on its card', (tester) async {
      final api = FakeShopApi();
      await pumpShopApp(tester, api, secure: signedInStorage);
      await scrollToGrid(tester);

      final cards = find.byType(ProductCard);
      final quick = find.descendant(
        of: cards,
        matching: find.byType(QuickAddButton),
      );
      // Every card in the fixture is in stock, so each one has it.
      expect(quick.evaluate().length, cards.evaluate().length);
    });

    testWidgets('an earlier order can be put back in the cart', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await _toCheckout(tester);
      await tester.tap(find.textContaining(en.checkoutPlaceOrder).last);
      await settle(tester, const Duration(seconds: 2));
      expect(find.text(en.orderPlacedTitle), findsOneWidget);

      // The cart was emptied by the order; "Buy again" fills it.
      await tester.tap(find.text(en.orderViewOrders));
      await settle(tester);
      await tester.tap(find.text(en.orderNumber(209)));
      await settle(tester);
      await _show(tester, find.text(en.orderBuyAgain));
      await tester.tap(find.text(en.orderBuyAgain));
      await settle(tester, const Duration(milliseconds: 600));

      expect(find.text(en.reorderAdded(1)), findsOneWidget);
      await tester.tap(find.text(en.viewCart));
      await settle(tester);
      expect(find.text(en.cartTitle), findsOneWidget);
      expect(find.text(_mascara), findsOneWidget);
    });
  });

  group('keep me signed in', () {
    testWidgets('is ticked to begin with, and the choice is remembered', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi());
      final box = find.byKey(const ValueKey('remember-me'));
      expect(tester.widget<CheckboxListTile>(box).value, isTrue);

      await tester.tap(box);
      await tester.pump();
      expect(tester.widget<CheckboxListTile>(box).value, isFalse);

      await _signInWithDemo(tester);

      expect(sl<SharedPreferences>().getBool('signin.remember'), isFalse);
    });

    testWidgets('the username comes back when you chose to be remembered', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        preferences: {'signin.remember': true, 'signin.username': 'emilys'},
      );

      expect(find.text('emilys'), findsOneWidget);
      final box = find.byKey(const ValueKey('remember-me'));
      expect(tester.widget<CheckboxListTile>(box).value, isTrue);
    });

    testWidgets('an unticked box ends the session when the app is reopened', (
      tester,
    ) async {
      final storage = await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        preferences: {'signin.remember': false},
      );

      expect(find.text(en.loginHeadline), findsOneWidget);
      expect(storage, isEmpty, reason: 'the tokens were wiped');
    });

    testWidgets('a ticked box keeps the session across a restart', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        preferences: {'signin.remember': true, 'signin.username': 'emilys'},
      );

      expect(find.text(en.loginHeadline), findsNothing);
      expect(find.text(en.shopGreeting('Emily')), findsOneWidget);
    });
  });
}
