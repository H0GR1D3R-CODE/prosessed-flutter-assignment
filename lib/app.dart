import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_event_listener.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';
import 'package:shopsphere/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

class ShopSphereApp extends StatefulWidget {
  const ShopSphereApp({super.key});

  @override
  State<ShopSphereApp> createState() => _ShopSphereAppState();
}

class _ShopSphereAppState extends State<ShopSphereApp> {
  late final AuthCubit _auth = sl<AuthCubit>();
  late final CartCubit _cart = sl<CartCubit>();
  late final WishlistCubit _wishlist = sl<WishlistCubit>();
  late final OrdersCubit _orders = sl<OrdersCubit>();
  late final SearchHistoryCubit _searches = sl<SearchHistoryCubit>();
  late final RecentlyViewedCubit _viewed = sl<RecentlyViewedCubit>();
  late final SettingsCubit _settings = sl<SettingsCubit>();
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  /// The cart and the wishlist belong to a user: load theirs on sign-in, put them away on
  /// sign-out. (They stay saved on the device for next time.)
  void _onAuthChanged(BuildContext context, AuthState state) {
    switch (state) {
      case Authenticated(:final user) when user != null:
        _cart.load(user.id);
        _wishlist.load(user.id);
        _orders.load(user.id);
        _searches.load(user.id);
        _viewed.load(user.id);
      case Authenticated():
        // Signed in but the profile is not known yet (offline start): try to fetch it.
        _auth.refreshUser();
      case Unauthenticated():
        _cart.unload();
        _wishlist.unload();
        _orders.unload();
        _searches.unload();
        _viewed.unload();
      case AuthUnknown():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _auth),
        BlocProvider<CartCubit>.value(value: _cart),
        BlocProvider<WishlistCubit>.value(value: _wishlist),
        BlocProvider<OrdersCubit>.value(value: _orders),
        BlocProvider<SearchHistoryCubit>.value(value: _searches),
        BlocProvider<RecentlyViewedCubit>.value(value: _viewed),
        BlocProvider<SettingsCubit>.value(value: _settings),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: _onAuthChanged,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp.router(
              onGenerateTitle: (context) => context.l10n.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: switch (settings.theme) {
                ThemeChoice.system => ThemeMode.system,
                ThemeChoice.light => ThemeMode.light,
                ThemeChoice.dark => ThemeMode.dark,
              },
              locale: settings.languageCode == null
                  ? null
                  : Locale(settings.languageCode!),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
              builder: (context, child) =>
                  CartEventListener(router: _router, child: child!),
            );
          },
        ),
      ),
    );
  }
}
