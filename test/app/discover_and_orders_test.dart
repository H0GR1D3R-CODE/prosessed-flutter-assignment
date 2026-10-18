import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_config.dart';
import 'package:shopsphere/features/discover/presentation/widgets/recently_viewed_strip.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

const String _mascara = 'Essence Mascara Lash Princess';

/// What the app has saved for user 1 (the demo account), as it would be after earlier visits.
Map<String, Object> _history(List<String> terms) => {
  'search.history.1': '[${terms.map((t) => '"$t"').join(',')}]',
};

Future<void> _focusSearch(WidgetTester tester) async {
  await tester.tap(find.byType(TextField));
  await settle(tester, const Duration(milliseconds: 400));
}

/// The Orders row sits below the first screenful of the profile, so scroll to it.
Future<void> _scrollToOrdersRow(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text(en.profileOrders),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text(en.profileOrders));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('search suggestions', () {
    testWidgets('a search is remembered and offered again next time', (
      tester,
    ) async {
      final api = FakeShopApi();
      await pumpShopApp(tester, api, secure: signedInStorage);

      await tester.enterText(find.byType(TextField), 'phone');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await settle(tester, const Duration(seconds: 1));

      // Start again from an empty box and focus it: the recent word is on offer.
      await tester.tap(find.byTooltip(en.shopClearSearch));
      await settle(tester);
      await _focusSearch(tester);
      expect(find.text(en.searchRecent), findsOneWidget);
      expect(find.text('phone'), findsOneWidget);

      // Choosing it searches for it.
      final before = api.to(Endpoints.productSearch).length;
      await tester.tap(find.text('phone'));
      await settle(tester, const Duration(seconds: 1));

      expect(api.to(Endpoints.productSearch).length, before + 1);
      expect(find.text('Apple AirPods Max Silver'), findsOneWidget);
    });

    testWidgets('a word can be removed, and all of them cleared', (
      tester,
    ) async {
      await pumpShopApp(
        tester,
        FakeShopApi(),
        secure: signedInStorage,
        preferences: _history(['phone', 'lamp']),
      );
      await _focusSearch(tester);
      expect(find.text('phone'), findsOneWidget);
      expect(find.text('lamp'), findsOneWidget);

      await tester.tap(find.byTooltip(en.searchForget('phone')));
      await settle(tester);
      expect(find.text('phone'), findsNothing);
      expect(find.text('lamp'), findsOneWidget);

      await tester.tap(find.text(en.searchClearAll));
      await settle(tester);
      expect(find.text('lamp'), findsNothing);
      expect(find.text(en.searchRecent), findsNothing);
    });

    testWidgets('typing narrows the words and offers matching categories', (
      tester,
    ) async {
      final api = FakeShopApi();
      await pumpShopApp(
        tester,
        api,
        secure: signedInStorage,
        preferences: _history(['red beauty box', 'phone']),
      );

      await tester.enterText(find.byType(TextField), 'beau');
      await settle(tester, const Duration(milliseconds: 300));

      expect(find.text('red beauty box'), findsOneWidget);
      expect(find.text('phone'), findsNothing, reason: 'does not match');
      expect(find.text(en.searchCategorySuggestion('Beauty')), findsOneWidget);

      await tester.tap(find.text(en.searchCategorySuggestion('Beauty')));
      await settle(tester, const Duration(seconds: 1));

      expect(api.to('/products/category/beauty'), isNotEmpty);
    });

    testWidgets(
      'Enter searches for what was typed, even when a category matches',
      (tester) async {
        final api = FakeShopApi();
        await pumpShopApp(tester, api, secure: signedInStorage);

        await tester.enterText(find.byType(TextField), 'beau');
        await settle(tester, const Duration(milliseconds: 300));
        expect(find.text(en.searchFor('beau')), findsOneWidget);
        expect(
          find.text(en.searchCategorySuggestion('Beauty')),
          findsOneWidget,
        );

        await tester.testTextInput.receiveAction(TextInputAction.search);
        await settle(tester, const Duration(seconds: 1));

        expect(api.to('/products/category/beauty'), isEmpty);
        expect(
          api.to(Endpoints.productSearch).last.queryParameters['q'],
          'beau',
        );
      },
    );

    testWidgets('there is nothing to suggest on a first visit', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      await _focusSearch(tester);

      expect(find.text(en.searchRecent), findsNothing);
    });
  });

  group('recently viewed', () {
    testWidgets(
      'an opened product shows up on a shelf, and the shelf can be cleared',
      (tester) async {
        await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
        expect(find.text(en.viewedTitle), findsNothing);

        await tester.tap(find.text(_mascara));
        await settle(tester, const Duration(seconds: 1));
        await tester.tap(find.byTooltip(en.back));
        await settle(tester);

        expect(find.text(en.viewedTitle), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(RecentlyViewedStrip),
            matching: find.text(_mascara),
          ),
          findsOneWidget,
        );

        await tester.tap(find.text(en.viewedClear));
        await settle(tester);
        expect(find.text(en.viewedTitle), findsNothing);
      },
    );

    testWidgets('tapping a product on the shelf opens it again', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));
      await tester.tap(find.byTooltip(en.back));
      await settle(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(RecentlyViewedStrip),
          matching: find.text(_mascara),
        ),
      );
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.productAbout), findsOneWidget);
    });

    testWidgets('the shelf is hidden while searching or browsing a category', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));
      await tester.tap(find.byTooltip(en.back));
      await settle(tester);
      expect(find.text(en.viewedTitle), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Beauty'));
      await settle(tester);

      expect(find.text(en.viewedTitle), findsNothing);
    });
  });

  group('order history', () {
    Future<void> placeAnOrder(WidgetTester tester) async {
      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));
      await tester.tap(find.textContaining(en.addToCart));
      await settle(tester, const Duration(seconds: 5));
      await tester.tap(find.byTooltip(en.back));
      await settle(tester);
      await tester.tap(find.text(en.navCart));
      await settle(tester);
      await tester.tap(find.text(en.cartCheckout));
      await settle(tester);
      await tester.tap(find.textContaining(en.checkoutPlaceOrder).last);
      await settle(tester, const Duration(seconds: 2));
    }

    testWidgets('a placed order is listed with its items and total', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await placeAnOrder(tester);
      expect(find.text(en.orderPlacedTitle), findsOneWidget);

      await tester.tap(find.text(en.orderViewOrders));
      await settle(tester);

      expect(find.text(en.ordersTitle), findsOneWidget);
      expect(find.text(en.ordersCount(1)), findsOneWidget);
      expect(find.text(en.orderNumber(209)), findsOneWidget);
      expect(find.text('\$8.94'), findsOneWidget, reason: 'the order total');

      // Opening the card shows what was bought.
      expect(find.text(_mascara), findsNothing);
      await tester.tap(find.text(en.orderNumber(209)));
      await settle(tester);
      expect(find.text(_mascara), findsOneWidget);
      expect(find.text('×1'), findsOneWidget);
    });

    testWidgets('the profile counts the orders and opens the list', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await placeAnOrder(tester);
      await tester.tap(find.text(en.orderContinue));
      await settle(tester);

      await tester.tap(find.text(en.navProfile));
      await settle(tester);
      await _scrollToOrdersRow(tester);
      expect(find.text(en.ordersCount(1)), findsOneWidget);

      await tester.tap(find.text(en.profileOrders));
      await settle(tester);
      expect(find.text(en.orderNumber(209)), findsOneWidget);
    });

    testWidgets('with no orders it says so and offers a way to start', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await tester.tap(find.text(en.navProfile));
      await settle(tester);
      await _scrollToOrdersRow(tester);
      expect(find.text(en.profileOrdersNote), findsOneWidget);

      await tester.tap(find.text(en.profileOrders));
      await settle(tester);

      expect(find.text(en.ordersEmptyTitle), findsOneWidget);
      expect(find.text(en.cartStartShopping), findsOneWidget);
    });

    testWidgets('orders survive a restart of the app', (tester) async {
      final api = FakeShopApi();
      await pumpShopApp(tester, api, secure: signedInStorage);
      await placeAnOrder(tester);

      // The order is on the device: a fresh launch with the same storage still has it.
      await tester.pumpWidget(const SizedBox());
      await pumpShopApp(
        tester,
        api,
        secure: signedInStorage,
        preferences: {
          'orders.1':
              '[{"id":209,"placedAt":"2026-10-18T09:00:00.000Z","items":[{"productId":1,"title":"$_mascara","thumbnail":"","category":"beauty","unitPrice":9.99,"discountPercentage":10.48,"quantity":1,"stock":99}]}]',
        },
      );
      await tester.tap(find.text(en.navProfile));
      await settle(tester);
      await _scrollToOrdersRow(tester);
      await tester.tap(find.text(en.profileOrders));
      await settle(tester);

      expect(find.text(en.orderNumber(209)), findsOneWidget);
    });
  });

  group('the "/" shortcut', () {
    bool searchHasFocus(WidgetTester tester) => tester
        .widget<EditableText>(find.byType(EditableText, skipOffstage: false))
        .focusNode
        .hasFocus;

    testWidgets('jumps to the search box', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      expect(searchHasFocus(tester), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await settle(tester, const Duration(milliseconds: 300));

      expect(searchHasFocus(tester), isTrue);
    });

    testWidgets('does nothing while another tab is showing', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      await tester.tap(find.text(en.navCart));
      await settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await settle(tester, const Duration(milliseconds: 300));

      expect(searchHasFocus(tester), isFalse);
    });
  });
}
