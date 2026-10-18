import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('a fresh install lands on the login screen', (tester) async {
    final api = FakeShopApi();

    await pumpShopApp(tester, api);

    expect(find.text(en.loginHeadline), findsOneWidget);
    expect(api.to('/auth/me'), isEmpty, reason: 'no session, nothing to check');
  });

  testWidgets('a stored session skips login and opens the shop', (
    tester,
  ) async {
    final api = FakeShopApi();

    await pumpShopApp(tester, api, secure: signedInStorage);

    expect(find.text(en.loginHeadline), findsNothing);
    expect(find.text('Essence Mascara Lash Princess'), findsOneWidget);
    expect(find.text(en.shopGreeting('Emily')), findsOneWidget);
  });
}
