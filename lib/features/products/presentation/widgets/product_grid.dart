import 'package:flutter/material.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/l10n/l10n.dart';

const double _gridSpacing = Gap.m;

/// How tall a card is, given how wide it is and how large the user's text is.
///
/// Fixing the height (rather than an aspect ratio) keeps every card the same size when text
/// scales up, and the text block grows with the scaler so nothing overflows at 1.3x.
double productCardExtent(double cardWidth, TextScaler scaler) {
  final orb = cardWidth - Gap.s * 2;
  return Gap.s +
      orb +
      Gap.s +
      scaler.scale(ProductCard.textBlockHeight) +
      Gap.m;
}

/// The product grid. Cards in every second column sit a little lower, so the rows read as a
/// loose brick pattern instead of a rigid table.
class ProductSliverGrid extends StatelessWidget {
  const ProductSliverGrid({
    required this.products,
    required this.columns,
    required this.onTap,
    this.heroScope = 'shop',
    this.selectedId,
    super.key,
  });

  final List<Product> products;
  final int columns;
  final ValueChanged<Product> onTap;
  final String heroScope;
  final int? selectedId;

  static const double stagger = 18;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.crossAxisExtent - _gridSpacing * (columns - 1)) /
            columns;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _gridSpacing,
            crossAxisSpacing: _gridSpacing,
            mainAxisExtent: productCardExtent(cardWidth, scaler),
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final lowered = columns > 1 && index % columns % 2 == 1;
            return Transform.translate(
              offset: Offset(0, lowered ? stagger : 0),
              child: Reveal(
                index: index % (columns * 3),
                child: ProductCard(
                  key: ValueKey(product.id),
                  product: product,
                  heroTag: productHeroTag(heroScope, product.id),
                  selected: product.id == selectedId,
                  onTap: () => onTap(product),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// The grid while the first page loads: the same cards, as shimmering outlines.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({required this.columns, this.count = 8, super.key});

  final int columns;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.crossAxisExtent - _gridSpacing * (columns - 1)) /
            columns;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: _gridSpacing,
            crossAxisSpacing: _gridSpacing,
            mainAxisExtent: productCardExtent(cardWidth, scaler),
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            final lowered = columns > 1 && index % columns % 2 == 1;
            return Transform.translate(
              offset: Offset(0, lowered ? ProductSliverGrid.stagger : 0),
              child: const _CardSkeleton(),
            );
          },
        );
      },
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: Radii.brXl,
      ),
      padding: const EdgeInsets.fromLTRB(Gap.s, Gap.s, Gap.s, Gap.m),
      child: const Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: SkeletonBox(circle: true),
              ),
            ),
            SizedBox(height: Gap.m),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 56, height: 10, radius: 5),
                  SizedBox(height: 8),
                  SkeletonBox(height: 13, radius: 6),
                  SizedBox(height: 6),
                  SkeletonBox(width: 90, height: 13, radius: 6),
                  SizedBox(height: 14),
                  SkeletonBox(width: 64, height: 16, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What sits under the last card: a spinner, a retry, or a quiet "that's everything".
class ProductListFooter extends StatelessWidget {
  const ProductListFooter({
    required this.isLoadingMore,
    required this.hasMore,
    required this.total,
    required this.loadMoreFailure,
    required this.onRetry,
    super.key,
  });

  final bool isLoadingMore;
  final bool hasMore;
  final int total;
  final Failure? loadMoreFailure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Widget child;
    if (loadMoreFailure != null) {
      child = InlineBanner(
        tone: BannerTone.error,
        message: l10n.shopLoadMoreFailed,
        actionLabel: l10n.retry,
        onAction: onRetry,
      );
    } else if (isLoadingMore) {
      child = const Center(child: OrbitSpinner(size: 34));
    } else if (!hasMore) {
      child = Center(
        child: Text(
          l10n.shopEndOfList(total),
          style: context.text.labelLarge?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      );
    } else {
      child = const SizedBox(height: 34);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Gap.l,
        Gap.xl + ProductSliverGrid.stagger,
        Gap.l,
        Gap.xxl,
      ),
      child: child,
    );
  }
}
