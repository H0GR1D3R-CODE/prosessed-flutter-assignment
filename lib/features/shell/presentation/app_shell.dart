import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The frame around the four tabs.
///
/// Phones get a bottom navigation bar; wider windows get a navigation rail on the left, which
/// leaves the full height for content.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    // Tapping the tab you are already on returns it to its first page.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = context.windowSize;

    final destinations = <_Destination>[
      _Destination(
        label: l10n.navShop,
        icon: Icons.storefront_outlined,
        selectedIcon: Icons.storefront_rounded,
      ),
      _Destination(
        label: l10n.navSaved,
        icon: Icons.favorite_border_rounded,
        selectedIcon: Icons.favorite_rounded,
      ),
      _Destination(
        label: l10n.navCart,
        icon: Icons.shopping_bag_outlined,
        selectedIcon: Icons.shopping_bag_rounded,
        showsCartCount: true,
      ),
      _Destination(
        label: l10n.navProfile,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    if (size.isCompact) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                label: d.label,
                icon: d.buildIcon(selected: false),
                selectedIcon: d.buildIcon(selected: true),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _select,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: Gap.l),
                child: OrbitLogo(size: 52),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    label: Text(d.label),
                    icon: d.buildIcon(selected: false),
                    selectedIcon: d.buildIcon(selected: true),
                    padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                  ),
              ],
            ),
          ),
          VerticalDivider(color: context.colors.outlineVariant),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.showsCartCount = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool showsCartCount;

  Widget buildIcon({required bool selected}) {
    final glyph = Icon(selected ? selectedIcon : icon);
    if (!showsCartCount) return glyph;
    // The cart tab carries a live count that bounces whenever it goes up.
    return BlocSelector<CartCubit, CartState, int>(
      selector: (state) => state.itemCount,
      builder: (context, count) => BouncingBadge(count: count, child: glyph),
    );
  }
}
