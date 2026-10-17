import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';
import 'package:shopsphere/features/splash/presentation/splash_page.dart';

/// Route paths, in one place.
abstract final class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String shop = '/shop';
}

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

GoRouter createRouter(AuthCubit auth) {
  return GoRouter(
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
      GoRoute(
        path: Routes.shop,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Shop'))),
      ),
    ],
  );
}
