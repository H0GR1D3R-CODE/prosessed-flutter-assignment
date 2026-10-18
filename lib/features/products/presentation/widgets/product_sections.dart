import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The price as the details page shows it: big, with the list price struck out and the saving.
class PriceBlock extends StatelessWidget {
  const PriceBlock({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = product.hasDiscount ? product.discountedPrice : product.price;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: Gap.m,
          runSpacing: Gap.xs,
          children: [
            Text(
              Formatters.money(shown),
              style: AppTypography.price(
                colors.onSurface,
                size: 32,
                weight: FontWeight.w700,
              ),
            ),
            if (product.hasDiscount) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  Formatters.money(product.price),
                  style: context.text.titleMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: DiscountPill(percent: product.discountPercentage),
              ),
            ],
          ],
        ),
        if (product.hasDiscount) ...[
          const SizedBox(height: Gap.xs),
          Text(
            context.l10n.productYouSave(
              Formatters.money(product.savingPerUnit),
            ),
            style: context.text.labelLarge?.copyWith(
              color: context.shop.success,
            ),
          ),
        ],
      ],
    );
  }
}

/// A titled block of the details page.
class DetailsSection extends StatelessWidget {
  const DetailsSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.text.titleLarge),
          Gap.hm,
          child,
        ],
      ),
    );
  }
}

/// Key and value rows, shown only for the facts a product actually has.
class SpecList extends StatelessWidget {
  const SpecList({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <(String, String)>[
      if (product.brand != null) (l10n.specBrand, product.brand!),
      (l10n.specCategory, Formatters.slugToTitle(product.category)),
      if (product.sku != null) (l10n.specSku, product.sku!),
      if (product.weight != null)
        (
          l10n.specWeight,
          product.weight!.toStringAsFixed(product.weight! % 1 == 0 ? 0 : 1),
        ),
      if (product.warrantyInformation != null)
        (l10n.specWarranty, product.warrantyInformation!),
      if (product.shippingInformation != null)
        (l10n.specShipping, product.shippingInformation!),
      if (product.returnPolicy != null)
        (l10n.specReturns, product.returnPolicy!),
      if (product.minimumOrderQuantity > 1)
        (l10n.specMinOrder, '${product.minimumOrderQuantity}'),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: Radii.brL,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.s),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(color: context.colors.outlineVariant),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 108,
                      child: Text(
                        rows[i].$1,
                        style: context.text.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(rows[i].$2, style: context.text.titleSmall),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TagWrap extends StatelessWidget {
  const TagWrap({required this.tags, super.key});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Gap.s,
      runSpacing: Gap.s,
      children: [
        for (final tag in tags)
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.m,
                vertical: 6,
              ),
              child: Text('#$tag', style: context.text.labelMedium),
            ),
          ),
      ],
    );
  }
}

/// All reviews, with the average on top.
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return DetailsSection(
      title: l10n.productReviewsTitle,
      child: product.reviews.isEmpty
          ? Text(
              l10n.productNoReviews,
              style: context.text.bodyLarge?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RatingPill(rating: product.rating),
                    Gap.wm,
                    Text(
                      l10n.productReviewsCount(product.reviews.length),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Gap.hm,
                for (final review in product.reviews)
                  ReviewTile(review: review, locale: locale),
              ],
            ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({required this.review, required this.locale, super.key});

  final Review review;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = review.reviewerName.isEmpty
        ? '?'
        : review.reviewerName[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.m),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: Radii.brL,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 44,
                child: Orb(
                  tint: OrbTints.forSeed(review.reviewerName),
                  showShadow: false,
                  child: Text(
                    initial,
                    style: context.text.titleMedium?.copyWith(
                      color: Palette.ink,
                    ),
                  ),
                ),
              ),
              Gap.wm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.reviewerName,
                            style: context.text.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.date != null)
                          Text(
                            Formatters.date(review.date!, locale),
                            style: context.text.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    StarRow(rating: review.rating),
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: Gap.s),
                      Text(review.comment, style: context.text.bodyMedium),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Five stars, filled up to [rating].
class StarRow extends StatelessWidget {
  const StarRow({required this.rating, super.key});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.ratingOutOf('$rating'),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 17,
              color: i <= rating ? context.shop.star : context.colors.outline,
            ),
        ],
      ),
    );
  }
}

/// Grey blocks standing in for the parts of the page that need the full product.
class DetailsSectionsSkeleton extends StatelessWidget {
  const DetailsSectionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: Gap.xl),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 150, height: 20, radius: 8),
            SizedBox(height: Gap.m),
            SkeletonBox(height: 14, radius: 7),
            SizedBox(height: 8),
            SkeletonBox(height: 14, radius: 7),
            SizedBox(height: 8),
            SkeletonBox(width: 220, height: 14, radius: 7),
            SizedBox(height: Gap.xl),
            SkeletonBox(height: 150, radius: 24),
          ],
        ),
      ),
    );
  }
}
