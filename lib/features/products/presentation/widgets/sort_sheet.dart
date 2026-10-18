import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/l10n/l10n.dart';

extension ProductSortLabel on ProductSort {
  String label(AppLocalizations l10n) => switch (this) {
    ProductSort.relevance => l10n.sortRelevance,
    ProductSort.priceLowToHigh => l10n.sortPriceLow,
    ProductSort.priceHighToLow => l10n.sortPriceHigh,
    ProductSort.topRated => l10n.sortRating,
    ProductSort.titleAZ => l10n.sortTitle,
  };

  IconData get icon => switch (this) {
    ProductSort.relevance => Icons.auto_awesome_rounded,
    ProductSort.priceLowToHigh => Icons.trending_up_rounded,
    ProductSort.priceHighToLow => Icons.trending_down_rounded,
    ProductSort.topRated => Icons.star_rounded,
    ProductSort.titleAZ => Icons.sort_by_alpha_rounded,
  };
}

/// Opens the sort options and returns the one picked, or null if dismissed.
Future<ProductSort?> showSortSheet(BuildContext context, ProductSort current) {
  return showModalBottomSheet<ProductSort>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (context) => _SortSheet(current: current),
  );
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final ProductSort current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.s, 0, Gap.s, Gap.m),
            child: Text(
              l10n.sortSheetTitle,
              style: context.text.headlineMedium,
            ),
          ),
          for (final sort in ProductSort.values)
            Semantics(
              button: true,
              selected: sort == current,
              label: sort.label(l10n),
              excludeSemantics: true,
              child: ListTile(
                minTileHeight: 56,
                shape: const RoundedRectangleBorder(borderRadius: Radii.brM),
                tileColor: sort == current ? context.shop.volt : null,
                leading: Icon(
                  sort.icon,
                  color: sort == current ? context.shop.onVolt : null,
                ),
                title: Text(
                  sort.label(l10n),
                  style: context.text.titleMedium?.copyWith(
                    color: sort == current
                        ? context.shop.onVolt
                        : colors.onSurface,
                  ),
                ),
                trailing: sort == current
                    ? Icon(Icons.check_rounded, color: context.shop.onVolt)
                    : null,
                onTap: () => Navigator.of(context).pop(sort),
              ),
            ),
        ],
      ),
    );
  }
}
