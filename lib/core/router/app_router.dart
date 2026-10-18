import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/presentation/pages/cart_page.dart';
import 'package:shopsphere/features/cart/presentation/pages/checkout_page.dart';
import 'package:shopsphere/features/cart/presentation/pages/order_success_page.dart';
import 'package:shopsphere/features/dev_tools/presentation/pages/error_lab_page.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';
import 'package:shopsphere/features/products/presentation/pages/product_list_page.dart';
import 'package:shopsphere/features/profile/presentation/pages/profile_page.dart';
import 'package:shopsphere/features/shell/presentation/app_shell.dart';
import 'package:shopsphere/features/splash/presentation/splash_page.dart';
import 'package:shopsphere/features/wishlist/presentation/pages/saved_page.dart';

/// Lets the router re-run its redirect whenever a stream emits.
class StreamRefreshListenable extends ChangeNotifier {
  StreamRefreshListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// The app's routes.
///
/// Splash and login sit outside the tabs. The four tabs share a shell (bottom bar or rail) and
/// keep their own state while you switch between them. Product details, checkout and the other
/// full-screen pages open on the root navigator, above the shell.
GoRouter createRouter(AuthCubit auth) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: StreamRefreshListenable(auth.stream),
    redirect: (context, state) {
      final location = state.matchedLocation;
      return switch (auth.state) {
        AuthUnknown() => location == Routes.splash ? null : Routes.splash,
        Unauthenticated() => location == Routes.login ? null : Routes.login,
        Authenticated() =>
          location == Routes.splash || location == Routes.login
              ? Routes.shop
              : null,
      };
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.shop,
                builder: (context, state) => const ProductListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.saved,
                builder: (context, state) => const SavedPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.cart,
                builder: (context, state) => const CartPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/product/:id',
        builder: (context, state) {
          final args = state.extra is ProductRouteArgs
              ? state.extra! as ProductRouteArgs
              : null;
          return ProductDetailsPage(
            productId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            args: args,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: Routes.checkout,
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: Routes.orderSuccess,
        redirect: (context, state) =>
            state.extra is OrderReceipt ? null : Routes.shop,
        builder: (context, state) =>
            OrderSuccessPage(receipt: state.extra! as OrderReceipt),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: Routes.devTools,
        builder: (context, state) => const ErrorLabPage(),
      ),
    ],
  );
}
