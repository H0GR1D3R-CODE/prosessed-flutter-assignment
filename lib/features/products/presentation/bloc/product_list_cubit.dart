import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/utils/debouncer.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_list_state.dart';

export 'package:shopsphere/features/products/presentation/bloc/product_list_state.dart';

/// Drives the catalogue: first page, infinite scroll, pull-to-refresh, search, category and sort.
class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit({
    required this._getProducts,
    Duration searchDebounce = const Duration(milliseconds: 400),
  }) : _debouncer = Debouncer(searchDebounce),
       super(const ProductListInitial(ProductQuery()));

  final GetProductsUseCase _getProducts;
  final Debouncer _debouncer;

  /// Bumped whenever a new first page is requested. A response that arrives for an older
  /// generation belongs to a query the user has already left, and is dropped.
  int _generation = 0;

  /// Loads the first page of the current query. Also the retry action after a failure.
  Future<void> load() => _loadFirstPage(state.query);

  /// Pull-to-refresh. With products on screen they stay put while the new page loads.
  Future<void> refresh() async {
    final current = state;
    if (current is! ProductListLoaded) return load();

    final generation = ++_generation;
    final result = await _getProducts(query: current.query);
    if (generation != _generation) return;
    result.fold(
      onFailure: (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          clearLoadMoreFailure: true,
          refreshFailure: failure,
        ),
      ),
      onSuccess: (page) => emit(_stateFor(current.query, page)),
    );
  }

  /// Fetches the next page when the list is scrolled near its end.
  Future<void> loadMore() async {
    final current = state;
    if (current is! ProductListLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.fromCache) {
      return;
    }

    final generation = _generation;
    emit(current.copyWith(isLoadingMore: true, clearLoadMoreFailure: true));
    final result = await _getProducts(
      query: current.query,
      skip: current.items.length,
    );
    if (generation != _generation) return;

    result.fold(
      onFailure: (failure) => emit(
        current.copyWith(isLoadingMore: false, loadMoreFailure: failure),
      ),
      onSuccess: (page) {
        final known = {for (final product in current.items) product.id};
        final merged = <Product>[
          ...current.items,
          ...page.items.where((product) => !known.contains(product.id)),
        ];
        emit(
          current.copyWith(
            items: merged,
            total: page.total,
            hasMore: page.hasMore && page.items.isNotEmpty,
            isLoadingMore: false,
            clearLoadMoreFailure: true,
          ),
        );
      },
    );
  }

  /// Called on every keystroke; the search runs once typing pauses.
  void searchChanged(String text) {
    final trimmed = text.trim();
    _debouncer.run(() {
      // A search replaces the category, because the API cannot combine them.
      _applyQuery(
        state.query.copyWith(
          search: trimmed,
          clearCategory: trimmed.isNotEmpty,
        ),
      );
    });
  }

  /// The keyboard's search key: run the search now instead of waiting for the pause.
  void searchSubmitted(String text) {
    _debouncer.cancel();
    final trimmed = text.trim();
    _applyQuery(
      state.query.copyWith(search: trimmed, clearCategory: trimmed.isNotEmpty),
    );
  }

  void clearSearch() {
    _debouncer.cancel();
    _applyQuery(state.query.copyWith(search: ''));
  }

  /// `null` selects "All".
  void selectCategory(String? slug) {
    _debouncer.cancel();
    _applyQuery(
      ProductQuery(search: '', categorySlug: slug, sort: state.query.sort),
    );
  }

  void selectSort(ProductSort sort) {
    _debouncer.cancel();
    _applyQuery(state.query.copyWith(sort: sort));
  }

  void _applyQuery(ProductQuery query) {
    if (query == state.query && state is! ProductListInitial) return;
    _loadFirstPage(query);
  }

  Future<void> _loadFirstPage(ProductQuery query) async {
    final generation = ++_generation;
    emit(ProductListLoading(query));
    final result = await _getProducts(query: query);
    if (generation != _generation) return;
    result.fold(
      onFailure: (failure) => emit(ProductListFailure(query, failure)),
      onSuccess: (page) => emit(_stateFor(query, page)),
    );
  }

  ProductListState _stateFor(ProductQuery query, ProductPage page) {
    if (page.items.isEmpty) return ProductListEmpty(query);
    return ProductListLoaded(
      query,
      items: page.items,
      total: page.total,
      hasMore: page.hasMore,
      fromCache: page.fromCache,
    );
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}
