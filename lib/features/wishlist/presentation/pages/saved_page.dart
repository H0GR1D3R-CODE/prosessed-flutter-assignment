import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_grid.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The Saved tab: every product the shopper has hearted.
class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  void _open(BuildContext context, Product product) {
    context.push(
      Routes.product(product.id),
      extra: ProductRouteArgs(
        product: product,
        heroTag: productHeroTag('saved', product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      bottom: false,
      child: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          final columns = Breakpoints.gridColumns(
            MediaQuery.sizeOf(context).width - Gap.l * 2 - 100,
          );
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.l,
                    Gap.m,
                    Gap.l,
                    Gap.m,
                  ),
                  child: Text(
                    l10n.savedTitle,
                    style: context.text.displaySmall,
                  ),
                ),
              ),
              if (state.loaded && state.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyView(
                    icon: Icons.favorite_border_rounded,
                    tint: OrbTints.rose,
                    title: l10n.savedEmptyTitle,
                    message: l10n.savedEmptyMessage,
                    actionLabel: l10n.savedBrowse,
                    onAction: () => context.go(Routes.shop),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Gap.l,
                    0,
                    Gap.l,
                    Gap.xxl + ProductSliverGrid.stagger,
                  ),
                  sliver: ProductSliverGrid(
                    products: state.items,
                    columns: columns,
                    heroScope: 'saved',
                    onTap: (product) => _open(context, product),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
