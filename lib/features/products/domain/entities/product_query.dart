import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// How the catalogue can be ordered.
enum ProductSort {
  /// The API's own order.
  relevance,
  priceLowToHigh,
  priceHighToLow,
  topRated,
  titleAZ,
}

/// What the shopper has asked to see: a search, a category and an order.
///
/// A search takes precedence over a category, because the API cannot combine the two.
class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.categorySlug,
    this.sort = ProductSort.relevance,
  });

  final String search;
  final String? categorySlug;
  final ProductSort sort;

  bool get hasSearch => search.trim().isNotEmpty;

  /// The plain, unfiltered catalogue: the only list that is cached for offline use.
  bool get isDefault =>
      !hasSearch && categorySlug == null && sort == ProductSort.relevance;

  ProductQuery copyWith({
    String? search,
    String? categorySlug,
    bool clearCategory = false,
    ProductSort? sort,
  }) {
    return ProductQuery(
      search: search ?? this.search,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [search, categorySlug, sort];
}

/// One page of results.
class ProductPage extends Equatable {
  const ProductPage({
    required this.items,
    required this.total,
    required this.skip,
    this.fromCache = false,
  });

  final List<Product> items;

  /// How many products match in all, across every page.
  final int total;

  /// How many were skipped before this page began.
  final int skip;

  /// True when the network failed and this is the copy saved on the device.
  final bool fromCache;

  int get nextSkip => skip + items.length;
  bool get hasMore => nextSkip < total;

  @override
  List<Object?> get props => [items, total, skip, fromCache];
}
