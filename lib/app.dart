import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/router/app_router.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

class ShopSphereApp extends StatefulWidget {
  const ShopSphereApp({super.key});

  @override
  State<ShopSphereApp> createState() => _ShopSphereAppState();
}

class _ShopSphereAppState extends State<ShopSphereApp> {
  late final AuthCubit _auth = sl<AuthCubit>();
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>.value(value: _auth)],
      child: MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
      ),
    );
  }
}
