import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

abstract interface class ProductRepository {
  /// One page of products for [query], starting after [skip] items.
  ///
  /// For the plain catalogue, a failed first page falls back to the copy saved on the device
  /// (flagged [ProductPage.fromCache]) when there is one.
  Future<Result<ProductPage>> getProducts({
    required ProductQuery query,
    required int skip,
    required int limit,
  });

  /// Every category, falling back to the saved list when offline.
  Future<Result<List<ProductCategory>>> getCategories();

  /// A single product with its photos and reviews. An unknown id is a `NotFoundFailure`.
  Future<Result<Product>> getProduct(int id);
}
