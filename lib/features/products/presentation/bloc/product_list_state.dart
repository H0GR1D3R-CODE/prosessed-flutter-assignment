import 'package:equatable/equatable.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

/// Every screen state of the catalogue, made explicit. Each carries the [query] it belongs to,
/// so the search box, category chips and sort control stay in step even while loading or failed.
sealed class ProductListState extends Equatable {
  const ProductListState(this.query);

  final ProductQuery query;

  @override
  List<Object?> get props => [query];
}

/// Nothing has been requested yet.
final class ProductListInitial extends ProductListState {
  const ProductListInitial(super.query);
}

/// The first page is on its way (first launch, a new query, or a retry): show skeletons.
final class ProductListLoading extends ProductListState {
  const ProductListLoading(super.query);
}

/// There are products to show.
final class ProductListLoaded extends ProductListState {
  const ProductListLoaded(
    super.query, {
    required this.items,
    required this.total,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailure,
    this.refreshFailure,
    this.fromCache = false,
  });

  final List<Product> items;
  final int total;
  final bool hasMore;

  /// The footer spinner is showing: the next page is being fetched.
  final bool isLoadingMore;

  /// The next page failed. The footer offers a retry; the products already shown stay.
  final Failure? loadMoreFailure;

  /// A pull-to-refresh failed. The list stays; the screen tells the user once.
  final Failure? refreshFailure;

  /// The device is offline and these are the products saved by the last visit.
  final bool fromCache;

  ProductListLoaded copyWith({
    List<Product>? items,
    int? total,
    bool? hasMore,
    bool? isLoadingMore,
    Failure? loadMoreFailure,
    bool clearLoadMoreFailure = false,
    Failure? refreshFailure,
    bool clearRefreshFailure = false,
  }) {
    return ProductListLoaded(
      query,
      items: items ?? this.items,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailure: clearLoadMoreFailure
          ? null
          : (loadMoreFailure ?? this.loadMoreFailure),
      refreshFailure: clearRefreshFailure
          ? null
          : (refreshFailure ?? this.refreshFailure),
      fromCache: fromCache,
    );
  }

  @override
  List<Object?> get props => [
    query,
    items,
    total,
    hasMore,
    isLoadingMore,
    loadMoreFailure,
    refreshFailure,
    fromCache,
  ];
}

/// The request worked and matched nothing.
final class ProductListEmpty extends ProductListState {
  const ProductListEmpty(super.query);
}

/// The first page could not be loaded and there is nothing saved to fall back on.
final class ProductListFailure extends ProductListState {
  const ProductListFailure(super.query, this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [query, failure];
}
