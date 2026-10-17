import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

/// Loads a page of the catalogue for a query: browsing, a category, a search, any sort order.
class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  /// The brief fixes the page size at 20.
  static const int pageSize = 20;

  final ProductRepository _repository;

  Future<Result<ProductPage>> call({
    required ProductQuery query,
    int skip = 0,
    int limit = pageSize,
  }) {
    return _repository.getProducts(
      // Whitespace around a search is never meaningful.
      query: query.copyWith(search: query.search.trim()),
      skip: skip,
      limit: limit,
    );
  }
}

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final ProductRepository _repository;

  Future<Result<List<ProductCategory>>> call() => _repository.getCategories();
}

class GetProductDetailsUseCase {
  const GetProductDetailsUseCase(this._repository);

  final ProductRepository _repository;

  Future<Result<Product>> call(int id) => _repository.getProduct(id);
}
