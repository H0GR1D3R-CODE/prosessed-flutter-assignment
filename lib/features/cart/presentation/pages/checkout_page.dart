import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/presentation/failure_copy.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_extras_cubit.dart';
import 'package:shopsphere/features/cart/presentation/widgets/cart_widgets.dart';
import 'package:shopsphere/features/cart/presentation/widgets/checkout_extras_sections.dart';
import 'package:shopsphere/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// Review the order, see where it goes, place it.
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final knownUser = authState is Authenticated ? authState.user : null;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CheckoutCubit>()),
        // The promo code and donation live only as long as this page.
        BlocProvider(create: (_) => CheckoutExtrasCubit()),
        // The address comes from the profile, which may be fresher than what sign-in returned.
        BlocProvider(
          create: (_) => sl<ProfileCubit>(param1: knownUser)..load(),
        ),
      ],
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutPlaced) {
          HapticFeedback.mediumImpact();
          context.go(Routes.orderSuccess, extra: state.receipt);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.checkoutTitle),
          leading: IconButton(
            tooltip: l10n.back,
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(Routes.cart),
          ),
        ),
        bottomNavigationBar: const _PlaceOrderBar(),
        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            if (cart.cart.isEmpty) {
              return EmptyView(
                icon: Icons.shopping_bag_outlined,
                tint: OrbTints.peach,
                title: l10n.cartEmptyTitle,
                message: l10n.cartEmptyMessage,
                actionLabel: l10n.cartStartShopping,
                onAction: () => context.go(Routes.shop),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.l,
                    Gap.s,
                    Gap.l,
                    Gap.xxl,
                  ),
                  children: [
                    CheckoutSection(
                      title: l10n.checkoutDeliverTo,
                      icon: Icons.place_outlined,
                      child: const _AddressBlock(),
                    ),
                    Gap.hm,
                    CheckoutSection(
                      title: l10n.checkoutPayment,
                      icon: Icons.credit_card_off_outlined,
                      child: Text(
                        l10n.checkoutPaymentNote,
                        style: context.text.bodyLarge,
                      ),
                    ),
                    Gap.hm,
                    const PromoSection(),
                    Gap.hm,
                    const GivingSection(),
                    Gap.hm,
                    CheckoutSection(
                      title: l10n.checkoutSummary,
                      icon: Icons.receipt_long_outlined,
                      child:
                          BlocBuilder<CheckoutExtrasCubit, CheckoutExtrasState>(
                            builder: (context, extras) {
                              final totals = CheckoutTotals.of(
                                cart.summary,
                                extras.extras,
                              );
                              return Column(
                                children: [
                                  for (final item in cart.cart.items)
                                    _SummaryLine(
                                      title: item.title,
                                      quantity: item.quantity,
                                      total: Formatters.money(item.total),
                                      imageUrl: item.thumbnail,
                                      category: item.category,
                                    ),
                                  Gap.hs,
                                  OrderTotals(
                                    summary: cart.summary,
                                    couponCode: totals.hasCoupon
                                        ? totals.coupon?.code
                                        : null,
                                    couponDiscount: totals.couponDiscount,
                                    donation: totals.donation,
                                  ),
                                ],
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return switch (state) {
          ProfileLoading() => const Shimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16, radius: 8),
                SizedBox(height: 8),
                SkeletonBox(width: 180, height: 16, radius: 8),
              ],
            ),
          ),
          ProfileFailure() => Text(
            l10n.checkoutNoAddress,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          ProfileLoaded(:final user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: context.text.titleSmall),
              const SizedBox(height: 2),
              Text(
                user.address?.oneLine ?? l10n.checkoutNoAddress,
                style: context.text.bodyLarge,
              ),
              if (user.phone != null) ...[
                const SizedBox(height: 2),
                Text(
                  user.phone!,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        };
      },
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.title,
    required this.quantity,
    required this.total,
    required this.imageUrl,
    required this.category,
  });

  final String title;
  final int quantity;
  final String total;
  final String imageUrl;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.m),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: ProductOrb(
              imageUrl: imageUrl,
              tint: OrbTints.forCategory(category),
              imageScale: 0.9,
            ),
          ),
          Gap.wm,
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall,
            ),
          ),
          Gap.wm,
          Text(
            '×$quantity',
            style: context.text.labelLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          Gap.wm,
          Text(total, style: context.text.titleSmall),
        ],
      ),
    );
  }
}

/// The place-order button, with the reason an order failed (if one did) just above it.
class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  final summary = context.select(
                    (CartCubit cart) => cart.state.summary,
                  );
                  final extras = context.select(
                    (CheckoutExtrasCubit cubit) => cubit.state.extras,
                  );
                  final total = CheckoutTotals.of(summary, extras).total;
                  final failed = state is CheckoutFailed ? state : null;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (failed != null) ...[
                        InlineBanner(
                          tone: BannerTone.error,
                          message:
                              '${l10n.checkoutFailed}. '
                              '${FailureCopy.of(context, failed.failure).message}',
                        ),
                        Gap.hm,
                      ],
                      AppButton(
                        kind: AppButtonKind.accent,
                        icon: failed == null
                            ? Icons.lock_outline_rounded
                            : Icons.refresh_rounded,
                        label: failed == null
                            ? l10n.checkoutPlaceOrderWithTotal(
                                Formatters.money(total),
                              )
                            : l10n.retry,
                        isLoading: state is CheckoutPlacing,
                        onPressed: () =>
                            context.read<CheckoutCubit>().placeOrder(extras),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
