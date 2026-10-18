import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/bloc/categories_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The horizontal strip of category chips, loaded from the API.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.state,
    required this.selectedSlug,
    required this.onSelected,
    required this.onRetry,
    super.key,
  });

  final CategoriesState state;
  final String? selectedSlug;

  /// `null` means "All".
  final ValueChanged<String?> onSelected;
  final VoidCallback onRetry;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: height,
      child: switch (state) {
        CategoriesLoading() => const _ChipsSkeleton(),
        CategoriesFailure() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.l),
          child: Align(
            alignment: Alignment.centerLeft,
            child: InlineBanner(
              tone: BannerTone.warning,
              icon: Icons.category_outlined,
              message: l10n.categoriesFailed,
              actionLabel: l10n.retry,
              onAction: onRetry,
            ),
          ),
        ),
        CategoriesLoaded(:final categories) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Gap.l),
          itemCount: categories.length + 1,
          separatorBuilder: (_, _) => Gap.ws,
          itemBuilder: (context, index) {
            if (index == 0) {
              return OrbChip(
                label: l10n.categoryAll,
                icon: Icons.apps_rounded,
                tint: const OrbTint(
                  light: Color(0xFFF1FFB4),
                  deep: Palette.volt,
                ),
                selected: selectedSlug == null,
                onTap: () => onSelected(null),
              );
            }
            final ProductCategory category = categories[index - 1];
            return OrbChip(
              label: category.name,
              icon: CategoryIcons.of(category.slug),
              tint: OrbTints.forCategory(category.slug),
              selected: selectedSlug == category.slug,
              onTap: () => onSelected(category.slug),
            );
          },
        ),
      },
    );
  }
}

/// A pill with a little orb on its left. Selected, it turns to ink.
class OrbChip extends StatelessWidget {
  const OrbChip({
    required this.label,
    required this.icon,
    required this.tint,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final OrbTint tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = selected
        ? colors.onSurface
        : colors.surfaceContainerLowest;
    final foreground = selected ? colors.surface : colors.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 48,
            padding: const EdgeInsets.fromLTRB(Gap.s, 0, Gap.l, 0),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: selected ? colors.onSurface : colors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 32,
                  child: Orb(
                    tint: tint,
                    showShadow: false,
                    child: Icon(icon, size: 17, color: Palette.ink),
                  ),
                ),
                Gap.ws,
                Text(
                  label,
                  style: context.text.labelLarge?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Gap.l),
        itemCount: 6,
        separatorBuilder: (_, _) => Gap.ws,
        itemBuilder: (_, index) => Center(
          child: SkeletonBox(
            width: 84.0 + (index % 3) * 22,
            height: 44,
            radius: 22,
          ),
        ),
      ),
    );
  }
}
