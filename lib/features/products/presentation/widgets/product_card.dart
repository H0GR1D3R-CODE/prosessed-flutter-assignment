import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The Hero tag shared by a card's photo and the details page's first photo. [scope] keeps
/// the same product on two tabs from sharing a tag.
Object productHeroTag(String scope, int productId) => '$scope-photo-$productId';

/// One product in the grid: an orb with the photo on it, then name, price and rating.
class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    required this.heroTag,
    this.selected = false,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;
  final Object heroTag;

  /// Highlights the card whose details are open in the side pane.
  final bool selected;

  /// Height of everything under the orb at normal text size: title, brand, price row, padding.
  static const double textBlockHeight = 108;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = OrbTints.forCategory(product.category);
    final price = Formatters.money(
      product.hasDiscount ? product.discountedPrice : product.price,
    );

    return Semantics(
      label: '${product.title}, $price',
      child: PressableScale(
        onTap: onTap,
        borderRadius: Radii.brXl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: Radii.brXl,
            border: Border.all(
              color: selected ? colors.onSurface : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(Gap.s, Gap.s, Gap.s, Gap.m),
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ProductOrb(
                      imageUrl: product.thumbnail,
                      tint: tint,
                      heroTag: heroTag,
                      imageScale: 0.94,
                      fallbackIcon: CategoryIcons.of(product.category),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        left: Gap.xs,
                        top: Gap.xs,
                        child: DiscountPill(
                          percent: product.discountPercentage,
                        ),
                      ),
                    Positioned(
                      right: -Gap.xs,
                      top: -Gap.xs,
                      child: WishlistHeart(product: product),
                    ),
                    if (!product.isAvailable)
                      Positioned.fill(
                        child: _SoldOutVeil(label: context.l10n.outOfStock),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.s),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand ??
                            Formatters.slugToTitle(product.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall,
                      ),
                      const SizedBox(height: Gap.s),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    price,
                                    style: AppTypography.price(
                                      colors.onSurface,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                if (product.hasDiscount)
                                  Text(
                                    Formatters.money(product.price),
                                    style: context.text.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          RatingPill(rating: product.rating, dense: true),
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
    );
  }
}

/// Dims a sold-out product and says so in words.
class _SoldOutVeil extends StatelessWidget {
  const _SoldOutVeil({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest.withValues(alpha: 0.62),
        borderRadius: Radii.brL,
      ),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.inverseSurface,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: 6),
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: context.colors.onInverseSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The save-for-later heart. Reads and writes the shared wishlist.
class WishlistHeart extends StatelessWidget {
  const WishlistHeart({
    required this.product,
    this.onSurface = true,
    super.key,
  });

  final Product product;

  /// Draws a soft disc behind the heart so it reads on top of photos.
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shop = context.shop;
    return BlocSelector<WishlistCubit, WishlistState, bool>(
      selector: (state) => state.contains(product.id),
      builder: (context, saved) {
        final label = saved
            ? context.l10n.wishlistRemove(product.title)
            : context.l10n.wishlistAdd(product.title);
        return Semantics(
          button: true,
          toggled: saved,
          label: label,
          excludeSemantics: true,
          child: InkResponse(
            radius: 26,
            onTap: () {
              HapticFeedback.selectionClick();
              context.read<WishlistCubit>().toggle(product);
            },
            child: SizedBox.square(
              dimension: 48,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onSurface
                        ? colors.surfaceContainerLowest.withValues(alpha: 0.86)
                        : Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(saved),
                        size: 20,
                        color: saved ? shop.saleText : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
