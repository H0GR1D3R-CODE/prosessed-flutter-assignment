import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/core/widgets/resizable_split.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_widgets.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The Cart tab. On a phone the summary rides under the list; on a wide window it sits beside it.
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _summaryCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading) {
            return const Center(child: OrbitSpinner(size: 44));
          }
          if (state.cart.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(count: 0),
                Expanded(
                  child: EmptyView(
                    icon: Icons.shopping_bag_outlined,
                    tint: OrbTints.peach,
                    title: l10n.cartEmptyTitle,
                    message: l10n.cartEmptyMessage,
                    actionLabel: l10n.cartStartShopping,
                    onAction: () => context.go(Routes.shop),
                  ),
                ),
              ],
            );
          }

          final wide = MediaQuery.sizeOf(context).width >= 840;
          final list = ListView.separated(
            padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xl),
            itemCount: state.cart.items.length + 1,
            separatorBuilder: (_, _) => Gap.hm,
            itemBuilder: (context, index) {
              if (index == state.cart.items.length) {
                // Under the lines: what is being saved, and where a promo code goes.
                return Reveal(
                  key: const ValueKey('cart-extras'),
                  index: index,
                  child: Column(
                    children: [
                      if (state.summary.discount > 0) ...[
                        CartSavingsCard(amount: state.summary.discount),
                        Gap.hm,
                      ],
                      const CartPromoCard(),
                    ],
                  ),
                );
              }
              final item = state.cart.items[index];
              return Reveal(
                key: ValueKey('reveal-${item.productId}'),
                index: index,
                child: CartItemTile(item: item),
              );
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(count: state.itemCount),
              Expanded(
                child: wide
                    ? ResizableSplit(
                        primary: list,
                        initialSecondaryWidth: 400,
                        minSecondaryWidth: 320,
                        minPrimaryWidth: 420,
                        collapsed: _summaryCollapsed,
                        onCollapsedChanged: (value) =>
                            setState(() => _summaryCollapsed = value),
                        collapseTooltip: l10n.summaryHide,
                        expandTooltip: l10n.summaryShow,
                        resizeLabel: l10n.panelResize,
                        collapsedOverlay: CartMiniBar(summary: state.summary),
                        secondary: Padding(
                          padding: const EdgeInsets.only(
                            right: Gap.l,
                            bottom: Gap.xl,
                          ),
                          child: CartSummaryCard(summary: state.summary),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(child: list),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Gap.l,
                              0,
                              Gap.l,
                              Gap.m,
                            ),
                            child: CartSummaryCard(summary: state.summary),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(l10n.cartTitle, style: context.text.displaySmall),
          ),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.cartItemCount(count),
                style: context.text.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
