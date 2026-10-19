import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_extras_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A titled white card on the checkout page.
class CheckoutSection extends StatelessWidget {
  const CheckoutSection({
    required this.title,
    required this.icon,
    required this.child,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
                Gap.ws,
                Expanded(child: Text(title, style: context.text.titleMedium)),
              ],
            ),
            Gap.hm,
            child,
          ],
        ),
      ),
    );
  }
}

/// What each known code does, in words.
String couponNote(AppLocalizations l10n, Coupon coupon) {
  return switch (coupon.code) {
    'WELCOME10' => l10n.couponWelcomeNote,
    'SAVE5' => l10n.couponSave5Note,
    'ORBIT20' => l10n.couponOrbit20Note,
    _ => '',
  };
}

/// The promo code box: type a code or tap one of the suggestions.
class PromoSection extends StatefulWidget {
  const PromoSection({super.key});

  @override
  State<PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends State<PromoSection> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _apply(String code) {
    FocusScope.of(context).unfocus();
    final amount = context.read<CartCubit>().state.summary.total;
    context.read<CheckoutExtrasCubit>().applyCode(code, amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CheckoutSection(
      title: l10n.couponTitle,
      icon: Icons.local_offer_outlined,
      child: BlocConsumer<CheckoutExtrasCubit, CheckoutExtrasState>(
        listenWhen: (previous, current) =>
            previous.extras.coupon != current.extras.coupon,
        listener: (context, state) {
          // Removing a code leaves the box ready for the next one.
          if (state.extras.coupon == null) _code.clear();
        },
        builder: (context, state) {
          final applied = state.extras.coupon;
          return AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: applied != null
                ? _AppliedCode(coupon: applied)
                : _CodeEntry(
                    controller: _code,
                    rejection: state.rejection,
                    onApply: _apply,
                  ),
          );
        },
      ),
    );
  }
}

class _CodeEntry extends StatelessWidget {
  const _CodeEntry({
    required this.controller,
    required this.rejection,
    required this.onApply,
  });

  final TextEditingController controller;
  final CouponCheck? rejection;
  final ValueChanged<String> onApply;

  String? _message(AppLocalizations l10n) {
    return switch (rejection) {
      CouponUnknown() => l10n.couponUnknown,
      CouponTooSmall(:final coupon, :final shortBy) => l10n.couponTooSmall(
        coupon.code,
        Formatters.money(shortBy),
      ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final message = _message(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                ],
                onSubmitted: onApply,
                decoration: InputDecoration(
                  labelText: l10n.couponHint,
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  errorText: message,
                  errorMaxLines: 2,
                ),
              ),
            ),
            Gap.wm,
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: () => onApply(controller.text),
                child: Text(l10n.couponApply),
              ),
            ),
          ],
        ),
        Gap.hm,
        Text(
          l10n.couponAvailable,
          style: context.text.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Gap.xs),
        for (final coupon in Coupons.all)
          _CodeRow(
            key: ValueKey('coupon-${coupon.code}'),
            coupon: coupon,
            onTap: () {
              controller.text = coupon.code;
              onApply(coupon.code);
            },
          ),
      ],
    );
  }
}

/// One code the shopper can use, with what it does, as a tappable row.
class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.coupon, required this.onTap, super.key});

  final Coupon coupon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Semantics(
      button: true,
      label: '${coupon.code}, ${couponNote(l10n, coupon)}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: Radii.brM,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.xs),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.shop.volt,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 18,
                      color: context.shop.onVolt,
                    ),
                  ),
                ),
                Gap.wm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.code,
                        style: context.text.titleSmall?.copyWith(
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        couponNote(l10n, coupon),
                        style: context.text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.wm,
                Text(
                  l10n.couponTap,
                  style: context.text.labelLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The accepted code, what it saves, and a way to take it off.
class _AppliedCode extends StatelessWidget {
  const _AppliedCode({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shop = context.shop;
    final saving = context.select(
      (CartCubit cart) => coupon.discountFor(cart.state.summary.total),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: shop.volt.withValues(alpha: shop.isDark ? 0.16 : 0.45),
        borderRadius: Radii.brL,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.xs, Gap.s),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: shop.success),
            Gap.wm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.couponApplied(coupon.code),
                    style: context.text.titleSmall,
                  ),
                  Text(
                    saving > 0
                        ? '${couponNote(l10n, coupon)} · −${Formatters.money(saving)}'
                        : couponNote(l10n, coupon),
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.couponRemove,
              onPressed: () =>
                  context.read<CheckoutExtrasCubit>().removeCoupon(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// The donation choices: nothing, the change from the order, or a few set amounts.
class GivingSection extends StatelessWidget {
  const GivingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = context.select((CartCubit cart) => cart.state.summary);
    return CheckoutSection(
      title: l10n.giveTitle,
      icon: Icons.volunteer_activism_outlined,
      child: BlocBuilder<CheckoutExtrasCubit, CheckoutExtrasState>(
        builder: (context, state) {
          // A round-up is worked out from what the order costs once any code has been taken off.
          final payable = CheckoutTotals.of(
            summary,
            CheckoutExtras(coupon: state.extras.coupon),
          ).payable;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.giveBody,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Gap.hm,
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.xs,
                children: [
                  for (final choice in DonationChoice.options)
                    _DonationPill(
                      choice: choice,
                      payable: payable,
                      selected: state.extras.donation == choice,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DonationPill extends StatelessWidget {
  const _DonationPill({
    required this.choice,
    required this.payable,
    required this.selected,
  });

  final DonationChoice choice;
  final double payable;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shop = context.shop;
    final label = switch (choice.kind) {
      DonationKind.none => l10n.giveNone,
      DonationKind.roundUp => l10n.giveRoundUp(
        Formatters.money(choice.amountFor(payable)),
      ),
      DonationKind.fixed => '+${Formatters.money(choice.amount)}',
    };
    return ChoiceChip(
      key: ValueKey('donation-${choice.kind.name}-${choice.amount}'),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: shop.volt,
      labelStyle: context.text.labelLarge?.copyWith(
        color: selected ? shop.onVolt : context.colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        context.read<CheckoutExtrasCubit>().chooseDonation(choice);
      },
    );
  }
}
