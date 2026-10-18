import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/fly_to_cart.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_gallery.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_sections.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// One product in full: photos, price, stock, description, specifications and reviews, with the
/// add-to-cart bar pinned to the bottom.
///
/// Opened from a card it paints at once from the product the card already had, and fills in the
/// rest (description, reviews) when the full record arrives. [embedded] drops the back button
/// and the Hero flight, for use in the side pane of a wide layout.
class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({
    required this.productId,
    this.args,
    this.embedded = false,
    super.key,
  });

  final int productId;
  final ProductRouteArgs? args;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailsCubit>(param1: productId)..load(),
      child: _DetailsView(args: args, embedded: embedded),
    );
  }
}

void _leave(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.shop);
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView({required this.args, required this.embedded});

  final ProductRouteArgs? args;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductDetailsCubit, ProductDetailsState>(
      // Opening a product puts it on the "recently viewed" shelf.
      listenWhen: (previous, current) => current is ProductDetailsLoaded,
      listener: (context, state) {
        if (state is ProductDetailsLoaded) {
          context.read<RecentlyViewedCubit>().record(state.product);
        }
      },
      child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        builder: (context, state) {
          final Product? product = switch (state) {
            ProductDetailsLoaded(:final product) => product,
            ProductDetailsLoading() => args?.product,
            ProductDetailsFailure() => null,
          };
          return Scaffold(
            // The bar lives in the Scaffold's own slot, so a floating snackbar rises above it.
            bottomNavigationBar: product == null
                ? null
                : _PurchaseBar(key: ValueKey(product.id), product: product),
            body: switch (state) {
              ProductDetailsLoading() =>
                product == null
                    ? _DetailsLoading(embedded: embedded)
                    : _DetailsContent(
                        product: product,
                        partial: true,
                        heroTag: args?.heroTag,
                        embedded: embedded,
                      ),
              ProductDetailsLoaded() => _DetailsContent(
                product: product!,
                partial: false,
                heroTag: args?.heroTag,
                embedded: embedded,
              ),
              ProductDetailsFailure(:final failure) => _DetailsFailure(
                failure: failure,
                embedded: embedded,
              ),
            },
          );
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  const _DetailsContent({
    required this.product,
    required this.partial,
    required this.heroTag,
    required this.embedded,
  });

  final Product product;

  /// Only the list-card fields are known so far; description and reviews are still loading.
  final bool partial;
  final Object? heroTag;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ProductGallery(
            product: product,
            heroTag: embedded ? null : heroTag,
            leading: embedded
                ? null
                : RoundOverlayButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: l10n.back,
                    onPressed: () => _leave(context),
                  ),
            trailing: WishlistHeart(product: product),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Gap.xl,
                  Gap.s,
                  Gap.xl,
                  Gap.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product.brand ??
                              Formatters.slugToTitle(product.category))
                          .toUpperCase(),
                      style: context.text.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(product.title, style: context.text.headlineMedium),
                    Gap.hm,
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Gap.l,
                      runSpacing: Gap.s,
                      children: [
                        RatingPill(rating: product.rating),
                        if (!partial)
                          Text(
                            l10n.productReviewsCount(product.reviews.length),
                            style: context.text.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        StockBadge(
                          stock: product.stock,
                          isAvailable: product.isAvailable,
                        ),
                      ],
                    ),
                    Gap.hl,
                    PriceBlock(product: product),
                    if (partial)
                      const DetailsSectionsSkeleton()
                    else ...[
                      if (product.description.isNotEmpty)
                        DetailsSection(
                          title: l10n.productAbout,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.description,
                                style: context.text.bodyLarge,
                              ),
                              if (product.tags.isNotEmpty) ...[
                                Gap.hm,
                                TagWrap(tags: product.tags),
                              ],
                            ],
                          ),
                        ),
                      DetailsSection(
                        title: l10n.productDetails,
                        child: SpecList(product: product),
                      ),
                      ReviewsSection(product: product),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Quantity and the add-to-cart button, always in reach.
class _PurchaseBar extends StatefulWidget {
  const _PurchaseBar({required this.product, super.key});

  final Product product;

  @override
  State<_PurchaseBar> createState() => _PurchaseBarState();
}

class _PurchaseBarState extends State<_PurchaseBar> {
  int _quantity = 1;
  final GlobalKey _addKey = GlobalKey(debugLabel: 'add-to-cart');

  Future<void> _add() async {
    unawaited(HapticFeedback.lightImpact());
    final cart = context.read<CartCubit>();
    await cart.add(widget.product, quantity: _quantity);
    if (!mounted) return;
    // Only celebrate an add that really happened (not one stopped at the stock limit).
    if (cart.state.event is CartItemAdded) {
      FlyToCart.play(context, from: _addKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final product = widget.product;
    final unit = product.hasDiscount ? product.discountedPrice : product.price;
    final total = Formatters.money(unit * _quantity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: context.shop.orbShadow.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.l, Gap.m),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                children: [
                  if (product.isAvailable) ...[
                    QuantityStepper(
                      dense: true,
                      value: _quantity,
                      max: product.maxOrderQuantity,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _quantity = value);
                      },
                    ),
                    Gap.wm,
                  ],
                  Expanded(
                    child: KeyedSubtree(
                      key: _addKey,
                      child: AppButton(
                        kind: AppButtonKind.accent,
                        icon: product.isAvailable
                            ? Icons.shopping_bag_outlined
                            : null,
                        label: product.isAvailable
                            ? l10n.addToCartWithPrice(total)
                            : l10n.outOfStock,
                        onPressed: product.isAvailable ? _add : null,
                      ),
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

/// A product opened with nothing to show yet (a deep link): skeletons under the back button.
class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading({required this.embedded});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.all(Gap.xl),
            child: Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 56),
                  AspectRatio(aspectRatio: 1.2, child: SkeletonBox(radius: 32)),
                  SizedBox(height: Gap.xl),
                  SkeletonBox(width: 90, height: 12, radius: 6),
                  SizedBox(height: Gap.m),
                  SkeletonBox(height: 22, radius: 8),
                  SizedBox(height: Gap.s),
                  SkeletonBox(width: 180, height: 22, radius: 8),
                  SizedBox(height: Gap.xl),
                  SkeletonBox(width: 150, height: 32, radius: 10),
                ],
              ),
            ),
          ),
          if (!embedded)
            Positioned(
              left: 8,
              top: 8,
              child: RoundOverlayButton(
                icon: Icons.arrow_back_rounded,
                tooltip: context.l10n.back,
                onPressed: () => _leave(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// A product that could not be loaded. A missing one offers only the way back.
class _DetailsFailure extends StatelessWidget {
  const _DetailsFailure({required this.failure, required this.embedded});

  final Failure failure;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final missing = failure is NotFoundFailure;
    return SafeArea(
      child: Stack(
        children: [
          ErrorView(
            failure: failure,
            onRetry: missing ? null : context.read<ProductDetailsCubit>().load,
            secondaryLabel: embedded ? null : l10n.errorGoHome,
            onSecondary: embedded ? null : () => context.go(Routes.shop),
          ),
          if (!embedded)
            Positioned(
              left: 8,
              top: 8,
              child: RoundOverlayButton(
                icon: Icons.arrow_back_rounded,
                tooltip: l10n.back,
                onPressed: () => _leave(context),
              ),
            ),
        ],
      ),
    );
  }
}
