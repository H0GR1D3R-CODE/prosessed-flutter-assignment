import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/animated_money.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// One line of the cart: the product, its price, a quantity stepper and a remove button.
/// Swiping it away removes it too, with an undo.
class CartItemTile extends StatelessWidget {
  const CartItemTile({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final cart = context.read<CartCubit>();

    return Dismissible(
      key: ValueKey('cart-${item.productId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(item.productId),
      background: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: Radii.brXl,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: Gap.xl),
            child: Icon(Icons.delete_outline_rounded, color: colors.error),
          ),
        ),
      ),
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.cartRemove(item.title)): () =>
              cart.remove(item.productId),
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: Radii.brXl,
          ),
          child: InkWell(
            borderRadius: Radii.brXl,
            onTap: () => context.push(Routes.product(item.productId)),
            child: Padding(
              padding: const EdgeInsets.all(Gap.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(
                    dimension: 84,
                    child: ProductOrb(
                      imageUrl: item.thumbnail,
                      tint: OrbTints.forCategory(item.category),
                      imageScale: 0.9,
                    ),
                  ),
                  Gap.wm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.cartRemove(item.title),
                              onPressed: () => cart.remove(item.productId),
                              icon: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ],
                        ),
                        // A Wrap, so the struck-through price drops to the next line instead of
                        // overflowing when the column is narrow and the text is large.
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              Formatters.money(item.discountedUnitPrice),
                              style: context.text.labelLarge,
                            ),
                            if (item.hasDiscount)
                              Text(
                                Formatters.money(item.unitPrice),
                                style: context.text.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                        Gap.hs,
                        Row(
                          children: [
                            QuantityStepper(
                              dense: true,
                              value: item.quantity,
                              max: item.maxQuantity,
                              onChanged: (value) =>
                                  cart.setQuantity(item.productId, value),
                            ),
                            Gap.ws,
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AnimatedMoney(
                                    value: item.total,
                                    style: AppTypography.price(
                                      colors.onSurface,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtotal, discount and total, as the cart and checkout both show them. At checkout and in
/// order history it also lists the promo code and the donation, when there are any.
class OrderTotals extends StatelessWidget {
  const OrderTotals({
    required this.summary,
    this.couponCode,
    this.couponDiscount = 0,
    this.donation = 0,
    super.key,
  });

  final CartSummary summary;
  final String? couponCode;
  final double couponDiscount;
  final double donation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final total = CheckoutTotals(
      summary: summary,
      couponDiscount: couponDiscount,
      donation: donation,
    ).total;
    return Column(
      children: [
        _TotalRow(label: l10n.cartSubtotal, amount: summary.subtotal),
        if (summary.discount > 0) ...[
          Gap.hs,
          _TotalRow(
            label: l10n.cartDiscount,
            amount: summary.discount,
            prefix: '−',
            valueColor: context.shop.success,
          ),
        ],
        if (couponDiscount > 0) ...[
          Gap.hs,
          _TotalRow(
            label: couponCode == null
                ? l10n.cartDiscount
                : l10n.couponLine(couponCode!),
            amount: couponDiscount,
            prefix: '−',
            valueColor: context.shop.success,
          ),
        ],
        if (donation > 0) ...[
          Gap.hs,
          _TotalRow(label: l10n.giveLine, amount: donation, prefix: '+'),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.m),
          child: Divider(color: colors.outlineVariant),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(l10n.cartTotal, style: context.text.titleLarge),
            ),
            AnimatedMoney(
              value: total,
              style: AppTypography.price(
                colors.onSurface,
                size: 26,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.prefix = '',
    this.valueColor,
  });

  final String label;
  final double amount;
  final String prefix;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
        AnimatedMoney(
          value: amount,
          prefix: prefix,
          style: context.text.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

/// The summary card with the checkout button.
class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: Radii.brXl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          children: [
            OrderTotals(summary: summary),
            Gap.hxl,
            AppButton(
              kind: AppButtonKind.accent,
              label: context.l10n.cartCheckout,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.push(Routes.checkout),
            ),
          ],
        ),
      ),
    );
  }
}

/// The summary shrunk to a pill, for when the side panel is tucked away: the total and the
/// checkout button stay within reach.
class CartMiniBar extends StatelessWidget {
  const CartMiniBar({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Material(
      color: colors.inverseSurface,
      elevation: 8,
      shadowColor: colors.shadow.withValues(alpha: 0.3),
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.s, Gap.s, Gap.s),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.cartTotal,
              style: context.text.labelLarge?.copyWith(
                color: colors.onInverseSurface.withValues(alpha: 0.7),
              ),
            ),
            Gap.wm,
            AnimatedMoney(
              value: summary.total,
              style: AppTypography.price(colors.onInverseSurface, size: 20),
            ),
            Gap.wl,
            AppButton(
              kind: AppButtonKind.accent,
              label: l10n.cartCheckout,
              icon: Icons.arrow_forward_rounded,
              expanded: false,
              onPressed: () => context.push(Routes.checkout),
            ),
          ],
        ),
      ),
    );
  }
}
