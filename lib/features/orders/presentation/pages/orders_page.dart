import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_widgets.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// Every order the shopper has placed on this device, newest first.
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state.orders.isEmpty) {
            return EmptyView(
              icon: Icons.receipt_long_outlined,
              tint: OrbTints.butter,
              title: l10n.ordersEmptyTitle,
              message: l10n.ordersEmptyMessage,
              actionLabel: l10n.cartStartShopping,
              onAction: () => context.go(Routes.shop),
            );
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Gap.l,
                  Gap.s,
                  Gap.l,
                  Gap.xxl,
                ),
                // One more row for the count at the top.
                itemCount: state.orders.length + 1,
                separatorBuilder: (_, _) => Gap.hm,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: Gap.xs),
                      child: Text(
                        l10n.ordersCount(state.orders.length),
                        style: context.text.labelLarge?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final order = state.orders[index - 1];
                  return Reveal(
                    key: ValueKey('order-${order.id}-${order.placedAt}'),
                    index: index - 1,
                    child: OrderCard(order: order),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One order: a stack of its photos, when it was placed and what it cost. Tap to see the lines.
class OrderCard extends StatefulWidget {
  const OrderCard({required this.order, super.key});

  final PlacedOrder order;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final order = widget.order;
    final summary = order.summary;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: Radii.brXl,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: Radii.brXl,
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(Gap.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PhotoStack(items: order.items),
                    Gap.wl,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.orderNumber(order.id),
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.orderPlacedOn(
                              Formatters.date(order.placedAt, locale),
                            ),
                            style: context.text.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.cartItemCount(summary.itemCount),
                            style: context.text.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.money(order.total),
                          style: context.text.titleMedium,
                        ),
                        Tooltip(
                          message: _open
                              ? l10n.orderHideItems
                              : l10n.orderShowItems,
                          child: AnimatedRotation(
                            turns: _open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _open
                      ? Padding(
                          padding: const EdgeInsets.only(top: Gap.l),
                          child: Column(
                            children: [
                              Divider(color: colors.outlineVariant, height: 1),
                              Gap.hm,
                              for (final item in order.items) _Line(item: item),
                              Gap.hs,
                              OrderTotals(
                                summary: summary,
                                couponCode: order.couponCode,
                                couponDiscount: order.couponDiscount,
                                donation: order.donation,
                              ),
                              Gap.hm,
                              AppButton(
                                kind: AppButtonKind.outline,
                                icon: Icons.replay_rounded,
                                label: l10n.orderBuyAgain,
                                onPressed: () => context
                                    .read<CartCubit>()
                                    .reorder(order.items),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Up to three product photos, overlapping, with "+2" when there are more.
class _PhotoStack extends StatelessWidget {
  const _PhotoStack({required this.items});

  final List<CartItem> items;

  static const double _size = 44;
  static const double _step = 26;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(3).toList();
    final extra = items.length - shown.length;
    final width = _size + _step * (shown.length - 1) + (extra > 0 ? 30 : 0);
    return ExcludeSemantics(
      child: SizedBox(
        width: math.max(_size, width),
        height: _size,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: i * _step,
                child: SizedBox.square(
                  dimension: _size,
                  child: ProductOrb(
                    imageUrl: shown[i].thumbnail,
                    tint: OrbTints.forCategory(shown[i].category),
                    fallbackIcon: CategoryIcons.of(shown[i].category),
                  ),
                ),
              ),
            if (extra > 0)
              Positioned(
                left: shown.length * _step + 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text(
                    '+$extra',
                    style: context.text.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gap.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium,
            ),
          ),
          Gap.wm,
          Text(
            '×${item.quantity}',
            style: context.text.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Gap.wm,
          Text(Formatters.money(item.total), style: context.text.labelLarge),
        ],
      ),
    );
  }
}
