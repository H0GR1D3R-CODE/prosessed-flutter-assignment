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
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
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
                      imageScale: 0.96,
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
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              Formatters.money(item.discountedUnitPrice),
                              style: context.text.labelLarge,
                            ),
                            if (item.hasDiscount) ...[
                              Gap.ws,
                              Text(
                                Formatters.money(item.unitPrice),
                                style: context.text.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
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
                                  child: Text(
                                    Formatters.money(item.total),
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

/// Subtotal, discount and total, as the cart and checkout both show them.
class OrderTotals extends StatelessWidget {
  const OrderTotals({required this.summary, super.key});

  final CartSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      children: [
        _TotalRow(
          label: l10n.cartSubtotal,
          value: Formatters.money(summary.subtotal),
        ),
        if (summary.discount > 0) ...[
          Gap.hs,
          _TotalRow(
            label: l10n.cartDiscount,
            value: '−${Formatters.money(summary.discount)}',
            valueColor: context.shop.success,
          ),
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
            Text(
              Formatters.money(summary.total),
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
  const _TotalRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
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
        Text(
          value,
          style: context.text.titleMedium?.copyWith(
            color: valueColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
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
