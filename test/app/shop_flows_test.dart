import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_config.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

const String _mascara = 'Essence Mascara Lash Princess';

void main() {
  group('browsing the shop', () {
    testWidgets(
      'searching waits for a pause in typing, then asks the API once',
      (tester) async {
        final api = FakeShopApi();
        await pumpShopApp(tester, api, secure: signedInStorage);

        await tester.enterText(find.byType(TextField), 'ph');
        await tester.pump(const Duration(milliseconds: 200));
        await tester.enterText(find.byType(TextField), 'phone');
        expect(
          api.to(Endpoints.productSearch),
          isEmpty,
          reason: 'still debouncing',
        );

        await settle(tester, const Duration(milliseconds: 800));

        expect(api.to(Endpoints.productSearch), hasLength(1));
        expect(
          api.to(Endpoints.productSearch).single.queryParameters['q'],
          'phone',
        );
        expect(find.text('Apple AirPods Max Silver'), findsOneWidget);
        expect(find.text(_mascara), findsNothing);
      },
    );

    testWidgets(
      'choosing a category lists it, and All brings everything back',
      (tester) async {
        final api = FakeShopApi();
        await pumpShopApp(tester, api, secure: signedInStorage);

        await tester.tap(find.bySemanticsLabel('Beauty'));
        await settle(tester);
        expect(api.to('/products/category/beauty'), hasLength(1));

        await tester.tap(find.bySemanticsLabel(en.categoryAll));
        await settle(tester);
        expect(find.text(_mascara), findsOneWidget);
      },
    );

    testWidgets('the sort sheet changes the order the API is asked for', (
      tester,
    ) async {
      final api = FakeShopApi();
      await pumpShopApp(tester, api, secure: signedInStorage);

      await tester.tap(find.text(en.sortRelevance));
      await settle(tester);
      await tester.tap(find.text(en.sortPriceLow));
      await settle(tester);

      final request = api.to(Endpoints.products).last;
      expect(request.queryParameters['sortBy'], 'price');
      expect(request.queryParameters['order'], 'asc');
    });

    testWidgets('a server error shows a retry that recovers', (tester) async {
      final api = FakeShopApi()..productListStatus = 500;
      await pumpShopApp(tester, api, secure: signedInStorage);

      expect(find.text(en.errorServerTitle), findsOneWidget);
      expect(find.text(_mascara), findsNothing);

      api.productListStatus = 200;
      await tester.tap(find.text(en.retry));
      await settle(tester);

      expect(find.text(_mascara), findsOneWidget);
      expect(find.text(en.errorServerTitle), findsNothing);
    });

    testWidgets(
      'starting offline shows the offline state, and retry works once back',
      (tester) async {
        final api = FakeShopApi()..offline = true;
        await pumpShopApp(tester, api, secure: signedInStorage);

        expect(find.text(en.errorNetworkTitle), findsWidgets);

        api.offline = false;
        // The category strip and the list each offer their own retry.
        for (final retry in find.text(en.retry).evaluate().toList()) {
          await tester.tap(
            find.byWidget(retry.widget).first,
            warnIfMissed: false,
          );
          await settle(tester);
        }

        expect(find.text(_mascara), findsOneWidget);
      },
    );

    testWidgets('pull to refresh keeps the list when the refresh fails', (
      tester,
    ) async {
      final api = FakeShopApi();
      await pumpShopApp(tester, api, secure: signedInStorage);

      api.offline = true;
      await tester.fling(find.text(_mascara), const Offset(0, 500), 1000);
      await settle(tester, const Duration(seconds: 2));

      expect(
        find.text(_mascara),
        findsOneWidget,
        reason: 'the list stays on screen',
      );
    });

    testWidgets('a product can be saved and found on the Saved tab', (
      tester,
    ) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);

      await tester.tap(find.byIcon(Icons.favorite_border_rounded).first);
      await settle(tester);
      await tester.tap(find.text(en.navSaved));
      await settle(tester);

      expect(find.text(_mascara), findsOneWidget);
      expect(find.text(en.savedEmptyTitle), findsNothing);

      // Un-saving empties the tab again.
      await tester.tap(find.byIcon(Icons.favorite_rounded).first);
      await settle(tester);
      expect(find.text(en.savedEmptyTitle), findsOneWidget);
    });

    testWidgets('the theme button switches to dark and back', (tester) async {
      await pumpShopApp(tester, FakeShopApi(), secure: signedInStorage);
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

      expect(brightness(), Brightness.light);
      await tester.tap(find.byTooltip(en.themeToggleToDark));
      await settle(tester);
      expect(brightness(), Brightness.dark);

      await tester.tap(find.byTooltip(en.themeToggleToLight));
      await settle(tester);
      expect(brightness(), Brightness.light);
    });
  });

  group('product details', () {
    testWidgets('a sold-out product cannot be added to the cart', (
      tester,
    ) async {
      final api = FakeShopApi()
        ..editProduct = (product) => {
          ...product,
          'stock': 0,
          'availabilityStatus': 'Out of Stock',
        };
      await pumpShopApp(tester, api, secure: signedInStorage);

      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.outOfStock), findsWidgets);
      expect(find.textContaining(en.addToCart), findsNothing);
    });

    testWidgets('a product without a brand still shows its details', (
      tester,
    ) async {
      final api = FakeShopApi()
        ..editProduct = (product) => {...product}..remove('brand');
      await pumpShopApp(tester, api, secure: signedInStorage);

      await tester.tap(find.text(_mascara));
      await settle(tester, const Duration(seconds: 1));

      expect(find.text(en.productAbout), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
