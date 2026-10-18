import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/presentation/bloc/categories_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_list_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/selected_product_cubit.dart';
import 'package:shopsphere/features/products/presentation/pages/product_details_page.dart';
import 'package:shopsphere/features/products/presentation/widgets/category_chips.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_grid.dart';
import 'package:shopsphere/features/products/presentation/widgets/sort_sheet.dart';
import 'package:shopsphere/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The Shop tab: search, categories, sort and an endless grid of products.
///
/// On a wide window the details of the chosen product open beside the grid instead of on a
/// new page.
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProductListCubit>()..load()),
        BlocProvider(create: (_) => sl<CategoriesCubit>()..load()),
        BlocProvider(create: (_) => SelectedProductCubit()),
      ],
      child: const _ShopView(),
    );
  }
}

class _ShopView extends StatefulWidget {
  const _ShopView();

  @override
  State<_ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<_ShopView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _search.dispose();
    super.dispose();
  }

  /// Ask for the next page a little before the user reaches the bottom.
  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 720) {
      context.read<ProductListCubit>().loadMore();
    }
  }

  void _openProduct(Product product, {required bool split}) {
    // Otherwise the search box keeps focus and the keyboard returns with this page.
    FocusScope.of(context).unfocus();
    if (split) {
      context.read<SelectedProductCubit>().select(product.id);
    } else {
      context.push(
        Routes.product(product.id),
        extra: ProductRouteArgs(
          product: product,
          heroTag: productHeroTag('shop', product.id),
        ),
      );
    }
  }

  Future<void> _pickSort(ProductSort current) async {
    final cubit = context.read<ProductListCubit>();
    FocusScope.of(context).unfocus();
    final picked = await showSortSheet(context, current);
    if (picked != null) cubit.selectSort(picked);
  }

  @override
  Widget build(BuildContext context) {
    final split = context.windowSize.isExpanded;
    final list = _ShopList(
      scroll: _scroll,
      search: _search,
      split: split,
      onOpen: (product) => _openProduct(product, split: split),
      onPickSort: _pickSort,
    );

    return MultiBlocListener(
      listeners: [
        // Typed text and the cubit's query can drift apart (a category clears the search).
        BlocListener<ProductListCubit, ProductListState>(
          listenWhen: (prev, curr) => prev.query.search != curr.query.search,
          listener: (context, state) {
            if (_search.text.trim() != state.query.search) {
              _search.text = state.query.search;
            }
          },
        ),
        BlocListener<ProductListCubit, ProductListState>(
          listenWhen: (prev, curr) =>
              curr is ProductListLoaded &&
              curr.refreshFailure != null &&
              (prev is! ProductListLoaded ||
                  prev.refreshFailure != curr.refreshFailure),
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(context.l10n.shopRefreshFailed)),
              );
          },
        ),
      ],
      child: split
          ? Row(
              children: [
                SizedBox(
                  width: math.min(560, MediaQuery.sizeOf(context).width * 0.46),
                  child: list,
                ),
                VerticalDivider(color: context.colors.outlineVariant),
                Expanded(
                  child: BlocBuilder<SelectedProductCubit, int?>(
                    builder: (context, id) => id == null
                        ? const _SelectPrompt()
                        : ProductDetailsPage(
                            key: ValueKey(id),
                            productId: id,
                            embedded: true,
                          ),
                  ),
                ),
              ],
            )
          : list,
    );
  }
}

class _ShopList extends StatelessWidget {
  const _ShopList({
    required this.scroll,
    required this.search,
    required this.split,
    required this.onOpen,
    required this.onPickSort,
  });

  final ScrollController scroll;
  final TextEditingController search;
  final bool split;
  final ValueChanged<Product> onOpen;
  final ValueChanged<ProductSort> onPickSort;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductListCubit>();
    final scaler = MediaQuery.textScalerOf(context);
    final searchHeight = math.max(56.0, scaler.scale(16) + 40);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: context.colors.onSurface,
        backgroundColor: context.colors.surfaceContainerLowest,
        onRefresh: cubit.refresh,
        child: CustomScrollView(
          controller: scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          // Scrolling the results puts the keyboard away.
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(child: _ShopHeader()),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FiltersHeader(
                height: searchHeight + CategoryChips.height + Gap.l + Gap.s,
                search: search,
                searchHeight: searchHeight,
              ),
            ),
            BlocBuilder<ProductListCubit, ProductListState>(builder: _body),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ProductListState state) {
    final cubit = context.read<ProductListCubit>();
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final paneWidth = split ? math.min(560.0, width * 0.46) : width;
    final columns = Breakpoints.gridColumns(paneWidth - Gap.l * 2);

    return switch (state) {
      ProductListInitial() || ProductListLoading() => SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(Gap.l, 0, Gap.l, Gap.xxl),
            sliver: ProductGridSkeleton(columns: columns),
          ),
        ],
      ),
      ProductListFailure(:final failure) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(failure: failure, onRetry: cubit.load),
      ),
      ProductListEmpty(:final query) => SliverFillRemaining(
        hasScrollBody: false,
        child: query.hasSearch
            ? EmptyView(
                icon: Icons.search_off_rounded,
                title: l10n.shopEmptySearchTitle(query.search),
                message: l10n.shopEmptySearchMessage,
                actionLabel: l10n.shopClearSearch,
                onAction: cubit.clearSearch,
              )
            : EmptyView(
                icon: Icons.inventory_2_outlined,
                title: l10n.shopEmptyTitle,
                message: l10n.shopEmptyMessage,
                actionLabel: l10n.categoryAll,
                onAction: () => cubit.selectCategory(null),
              ),
      ),
      final ProductListLoaded loaded => SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: _ResultsBar(
              total: loaded.total,
              sort: loaded.query.sort,
              onSort: () => onPickSort(loaded.query.sort),
              showOffline: loaded.fromCache,
              onRetry: cubit.load,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.l),
            sliver: BlocSelector<SelectedProductCubit, int?, int?>(
              selector: (id) => id,
              builder: (context, selectedId) => ProductSliverGrid(
                products: loaded.items,
                columns: columns,
                selectedId: split ? selectedId : null,
                onTap: onOpen,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ProductListFooter(
              isLoadingMore: loaded.isLoadingMore,
              hasMore: loaded.hasMore,
              total: loaded.total,
              loadMoreFailure: loaded.loadMoreFailure,
              onRetry: cubit.loadMore,
            ),
          ),
        ],
      ),
    };
  }
}

/// "Hi, Emily" and a theme toggle.
class _ShopHeader extends StatelessWidget {
  const _ShopHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = context.shop.isDark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.l, Gap.m, Gap.s, Gap.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: BlocSelector<AuthCubit, AuthState, String?>(
              selector: (state) =>
                  state is Authenticated ? state.user?.firstName : null,
              builder: (context, name) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name == null ? l10n.shopWelcome : l10n.shopGreeting(name),
                      style: context.text.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Gap.xs),
                    Text(
                      l10n.shopPrompt,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          IconButton(
            tooltip: dark ? l10n.themeToggleToLight : l10n.themeToggleToDark,
            onPressed: () =>
                context.read<SettingsCubit>().toggleTheme(currentlyDark: dark),
            icon: Icon(
              dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

/// The pinned block under the header: the search box and the category chips.
class _FiltersHeader extends SliverPersistentHeaderDelegate {
  _FiltersHeader({
    required this.height,
    required this.search,
    required this.searchHeight,
  });

  final double height;
  final TextEditingController search;
  final double searchHeight;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cubit = context.read<ProductListCubit>();
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent
                ? context.colors.outlineVariant
                : Colors.transparent,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.l),
            child: SizedBox(
              height: searchHeight,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: search,
                builder: (context, value, _) => TextField(
                  controller: search,
                  textInputAction: TextInputAction.search,
                  onChanged: cubit.searchChanged,
                  onSubmitted: cubit.searchSubmitted,
                  decoration: InputDecoration(
                    hintText: l10n.shopSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Gap.l,
                    ),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.shopClearSearch,
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              search.clear();
                              cubit.clearSearch();
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          BlocBuilder<CategoriesCubit, CategoriesState>(
            builder: (context, categories) =>
                BlocSelector<ProductListCubit, ProductListState, String?>(
                  selector: (state) => state.query.categorySlug,
                  builder: (context, slug) => CategoryChips(
                    state: categories,
                    selectedSlug: slug,
                    onSelected: cubit.selectCategory,
                    onRetry: context.read<CategoriesCubit>().load,
                  ),
                ),
          ),
          const SizedBox(height: Gap.s),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FiltersHeader old) =>
      old.height != height || old.search != search;
}

/// "194 products", the sort control, and the offline notice when it applies.
class _ResultsBar extends StatelessWidget {
  const _ResultsBar({
    required this.total,
    required this.sort,
    required this.onSort,
    required this.showOffline,
    required this.onRetry,
  });

  final int total;
  final ProductSort sort;
  final VoidCallback onSort;
  final bool showOffline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.s, Gap.s),
      child: Column(
        children: [
          if (showOffline)
            Padding(
              padding: const EdgeInsets.only(right: Gap.m, bottom: Gap.s),
              child: InlineBanner(
                tone: BannerTone.warning,
                message: l10n.shopOfflineBanner,
                actionLabel: l10n.retry,
                onAction: onRetry,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.shopResultsCount(total),
                  style: context.text.labelLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onSort,
                icon: Icon(sort.icon, size: 18),
                label: Text(sort.label(l10n)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The empty details pane on a wide screen.
class _SelectPrompt extends StatelessWidget {
  const _SelectPrompt();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyView(
      icon: Icons.touch_app_rounded,
      title: l10n.shopSelectTitle,
      message: l10n.shopSelectMessage,
    );
  }
}
