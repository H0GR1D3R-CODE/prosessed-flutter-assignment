import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/network_photo.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:shopsphere/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';
import 'package:shopsphere/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The Me tab: who is signed in, how the app looks, and the way out.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final knownUser = authState is Authenticated ? authState.user : null;
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(param1: knownUser)..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const _ProfileSkeleton(),
            ProfileFailure(:final failure) => ErrorView(
              failure: failure,
              onRetry: context.read<ProfileCubit>().load,
            ),
            ProfileLoaded(:final user) => _ProfileBody(user: user),
          };
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.xxl),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.m),
              child: Text(l10n.profileTitle, style: context.text.displaySmall),
            ),
            Reveal(
              index: 0,
              child: _Card(
                child: Column(
                  children: [
                    _Avatar(user: user),
                    Gap.hm,
                    Text(
                      user.fullName,
                      textAlign: TextAlign.center,
                      style: context.text.headlineLarge,
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      '@${user.username}',
                      style: context.text.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap.hm,
            Reveal(
              index: 1,
              child: _Card(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      label: l10n.profileEmail,
                      value: user.email,
                    ),
                    if (user.phone != null)
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.profilePhone,
                        value: user.phone!,
                      ),
                    if (user.address != null)
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: l10n.profileAddress,
                        value: user.address!.oneLine,
                      ),
                  ],
                ),
              ),
            ),
            Gap.hm,
            const Reveal(index: 2, child: _AppearanceCard()),
            Gap.hm,
            Reveal(
              index: 3,
              child: _Card(
                padding: EdgeInsets.zero,
                child: BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, orders) => ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(
                      l10n.profileOrders,
                      style: context.text.titleMedium,
                    ),
                    subtitle: Text(
                      orders.orders.isEmpty
                          ? l10n.profileOrdersNote
                          : l10n.ordersCount(orders.orders.length),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.orders),
                  ),
                ),
              ),
            ),
            Gap.hm,
            Reveal(
              index: 4,
              child: _Card(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(
                    l10n.profileDevTools,
                    style: context.text.titleMedium,
                  ),
                  subtitle: Text(l10n.profileDevToolsNote),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.devTools),
                ),
              ),
            ),
            Gap.hxl,
            AppButton(
              kind: AppButtonKind.outline,
              icon: Icons.logout_rounded,
              label: l10n.signOut,
              onPressed: () => _confirmSignOut(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final auth = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await auth.signOut();
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(Gap.xl),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // A Material rather than a DecoratedBox, so a ListTile inside can paint its ink splash.
    return Material(
      color: context.colors.surfaceContainerLowest,
      borderRadius: Radii.brXl,
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

/// The photo on an orb, or the initials when there is no photo.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final initials = Center(
      child: Text(
        user.initials,
        style: context.text.headlineMedium?.copyWith(color: Palette.ink),
      ),
    );
    return SizedBox.square(
      dimension: 124,
      child: Orb(
        tint: OrbTints.forSeed(user.username),
        child: SizedBox.square(
          dimension: 84,
          child: ClipOval(
            child: user.imageUrl == null
                ? initials
                : NetworkPhoto(
                    url: user.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: initials,
                    fallback: initials,
                  ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.colors.onSurfaceVariant),
          Gap.wl,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: context.text.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme and language, each a row of three choices.
class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shop = context.shop;
    final settings = context.read<SettingsCubit>();
    final style = SegmentedButton.styleFrom(
      selectedBackgroundColor: shop.volt,
      selectedForegroundColor: shop.onVolt,
      visualDensity: VisualDensity.standard,
      minimumSize: const Size(0, 48),
      textStyle: context.text.labelLarge,
    );

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.profileAppearance, style: context.text.titleMedium),
              Gap.hm,
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeChoice>(
                  style: style,
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeChoice.system,
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeChoice.light,
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeChoice.dark,
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {state.theme},
                  onSelectionChanged: (choice) =>
                      settings.setTheme(choice.first),
                ),
              ),
              _Hint(switch (state.theme) {
                ThemeChoice.system =>
                  MediaQuery.platformBrightnessOf(context) == Brightness.dark
                      ? l10n.themeHintSystemDark
                      : l10n.themeHintSystemLight,
                ThemeChoice.light => l10n.themeHintLight,
                ThemeChoice.dark => l10n.themeHintDark,
              }),
              Gap.hxl,
              Text(l10n.profileLanguage, style: context.text.titleMedium),
              Gap.hm,
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  style: style,
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'system',
                      label: Text(l10n.languageSystem),
                    ),
                    ButtonSegment(
                      value: 'en',
                      label: Text(l10n.languageEnglish),
                    ),
                    ButtonSegment(value: 'hi', label: Text(l10n.languageHindi)),
                  ],
                  selected: {state.languageCode ?? 'system'},
                  onSelectionChanged: (choice) => settings.setLanguage(
                    choice.first == 'system' ? null : choice.first,
                  ),
                ),
              ),
              _Hint(switch (state.languageCode) {
                'en' => l10n.languageHintEnglish,
                'hi' => l10n.languageHintHindi,
                _ => l10n.languageHintSystem,
              }),
            ],
          ),
        );
      },
    );
  }
}

/// One line under a switch saying what the current choice does.
class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.s),
      child: Text(
        text,
        style: context.text.bodyMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(Gap.l),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 220, height: 34, radius: 10),
            SizedBox(height: Gap.l),
            SkeletonBox(height: 220, radius: 32),
            SizedBox(height: Gap.m),
            SkeletonBox(height: 160, radius: 32),
          ],
        ),
      ),
    );
  }
}
