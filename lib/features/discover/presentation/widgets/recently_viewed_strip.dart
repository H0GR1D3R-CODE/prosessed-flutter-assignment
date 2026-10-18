import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A row of the products the shopper opened lately, for getting back to one in a tap.
/// It takes no room when there is nothing to show.
class RecentlyViewedStrip extends StatelessWidget {
  const RecentlyViewedStrip({required this.onOpen, super.key});

  final ValueChanged<Product> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<RecentlyViewedCubit, RecentlyViewedState>(
      builder: (context, state) {
        final products = state.products;
        return AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: products.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: Gap.s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Gap.l,
                          Gap.s,
                          Gap.xs,
                          0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.viewedTitle,
                                style: context.text.titleMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.read<RecentlyViewedCubit>().clear(),
                              child: Text(l10n.viewedClear),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Gap.l,
                          ),
                          itemCount: products.length,
                          separatorBuilder: (_, _) => Gap.wm,
                          itemBuilder: (context, index) => Reveal(
                            key: ValueKey('viewed-${products[index].id}'),
                            index: index,
                            child: _ViewedTile(
                              product: products[index],
                              onTap: () => onOpen(products[index]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _ViewedTile extends StatelessWidget {
  const _ViewedTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: PressableScale(
        onTap: onTap,
        semanticLabel: product.title,
        borderRadius: Radii.brL,
        child: Padding(
          padding: const EdgeInsets.all(Gap.xs),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 64,
                child: ProductOrb(
                  imageUrl: product.thumbnail,
                  tint: OrbTints.forCategory(product.category),
                  fallbackIcon: CategoryIcons.of(product.category),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
