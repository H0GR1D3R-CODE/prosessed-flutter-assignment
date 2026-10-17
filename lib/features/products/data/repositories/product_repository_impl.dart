import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required this._remote, required this._local});

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  @override
  Future<Result<ProductPage>> getProducts({
    required ProductQuery query,
    required int skip,
    required int limit,
  }) async {
    final result = await guard(() => _fetch(query, skip, limit));
    final cacheable = query.isDefault && skip == 0;

    switch (result) {
      case Success(:final value):
        if (cacheable) await _quietly(() => _local.saveFirstPage(value));
        return Result.success(value.toEntity());
      case Fail(:final failure):
        // Only the plain first page is kept for offline use; it is shown when the store cannot
        // be reached, not when the request itself was wrong.
        final recoverable =
            failure is NetworkFailure ||
            failure is TimeoutFailure ||
            failure is ServerFailure;
        if (cacheable && recoverable) {
          final cached = await _readQuietly(_local.readFirstPage);
          if (cached != null) {
            return Result.success(cached.toEntity(fromCache: true));
          }
        }
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<List<ProductCategory>>> getCategories() async {
    final result = await guard(_remote.categories);
    switch (result) {
      case Success(:final value):
        await _quietly(() => _local.saveCategories(value));
        return Result.success([for (final c in value) c.toEntity()]);
      case Fail(:final failure):
        final cached = await _readQuietly(_local.readCategories);
        if (cached != null && cached.isNotEmpty) {
          return Result.success([for (final c in cached) c.toEntity()]);
        }
        return Result.failure(failure);
    }
  }

  @override
  Future<Result<Product>> getProduct(int id) {
    return guard(() async => (await _remote.product(id)).toEntity());
  }

  Future<ProductPageModel> _fetch(ProductQuery query, int skip, int limit) {
    if (query.hasSearch) {
      return _remote.search(
        query.search,
        skip: skip,
        limit: limit,
        sort: query.sort,
      );
    }
    final category = query.categorySlug;
    if (category != null) {
      return _remote.byCategory(
        category,
        skip: skip,
        limit: limit,
        sort: query.sort,
      );
    }
    return _remote.all(skip: skip, limit: limit, sort: query.sort);
  }

  /// A cache that cannot be written is a missed optimisation, never a reason to fail.
  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on AppException {
      // Ignored on purpose.
    }
  }

  Future<T?> _readQuietly<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } on AppException {
      return null;
    }
  }
}
