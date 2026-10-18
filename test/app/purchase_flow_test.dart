import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_config.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

const String _mascara = 'Essence Mascara Lash Princess';

void main() {
  Future<void> signInWithDemo(WidgetTester tester) async {
    await tester.tap(find.text(en.useDemoAccount));
    await tester.pump();
    await tester.tap(find.text(en.signIn));
    await settle(tester, const Duration(seconds: 1));
  }

  testWidgets('sign in, add a product, check out and see the confirmation', (
    tester,
  ) async {
    final api = FakeShopApi();
    await pumpShopApp(tester, api);

    // Login with the demo account.
    await signInWithDemo(tester);
    expect(find.text(_mascara), findsOneWidget);
    expect(api.to('/auth/login'), hasLength(1));

    // Open the product and add two of them.
    await tester.tap(find.text(_mascara));
    await settle(tester, const Duration(seconds: 1));
    expect(find.text(en.productAbout), findsOneWidget);
    await tester.tap(find.byTooltip(en.increaseQuantity));
    await tester.pump();
    await tester.tap(find.textContaining(en.addToCart));
    await settle(tester, const Duration(milliseconds: 600));
    expect(find.textContaining('Added 2 × $_mascara'), findsOneWidget);

    // Back to the shop; the cart badge shows 2.
    await tester.tap(find.byTooltip(en.back));
    await settle(tester);
    await tester.tap(find.text(en.navCart));
    await settle(tester);
    // Let the "Added" snackbar finish so it is not covering the checkout button.
    await settle(tester, const Duration(seconds: 5));
    expect(find.text(en.cartTitle), findsOneWidget);
    expect(find.text(_mascara), findsOneWidget);

    // Checkout and place the order.
    await tester.tap(find.text(en.cartCheckout));
    await settle(tester);
    expect(find.textContaining(en.checkoutPlaceOrder), findsWidgets);
    await tester.tap(find.textContaining(en.checkoutPlaceOrder).last);
    await settle(tester, const Duration(seconds: 2));

    expect(api.to(Endpoints.addCart), hasLength(1));
    expect(find.text(en.orderPlacedTitle), findsOneWidget);
    expect(find.text(en.orderPlacedMessage(209)), findsOneWidget);
    // Two mascaras at 8.94 each: the app's own total, not the API's rounded one.
    expect(find.textContaining('\$17.88'), findsWidgets);

    // The cart was emptied by the order.
    await tester.tap(find.text(en.orderContinue));
    await settle(tester);
    await tester.tap(find.text(en.navCart));
    await settle(tester);
    expect(find.text(en.cartEmptyTitle), findsOneWidget);
  });
}
