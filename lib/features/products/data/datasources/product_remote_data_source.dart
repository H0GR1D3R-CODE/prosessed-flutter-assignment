import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_config.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

abstract interface class ProductRemoteDataSource {
  Future<ProductPageModel> all({
    required int skip,
    required int limit,
    required ProductSort sort,
  });

  Future<ProductPageModel> search(
    String text, {
    required int skip,
    required int limit,
    required ProductSort sort,
  });

  Future<ProductPageModel> byCategory(
    String slug, {
    required int skip,
    required int limit,
    required ProductSort sort,
  });

  Future<List<CategoryModel>> categories();

  Future<ProductModel> product(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  const ProductRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  /// The fields a list card needs. Asking for only these keeps each page small: reviews,
  /// images and descriptions are left for the details page.
  static const String listFields =
      'id,title,price,discountPercentage,rating,thumbnail,category,brand,stock,'
      'availabilityStatus,minimumOrderQuantity';

  @override
  Future<ProductPageModel> all({
    required int skip,
    required int limit,
    required ProductSort sort,
  }) async {
    final json = await _client.getMap(
      Endpoints.products,
      query: _query(skip: skip, limit: limit, sort: sort),
    );
    return ProductPageModel.fromJson(json);
  }

  @override
  Future<ProductPageModel> search(
    String text, {
    required int skip,
    required int limit,
    required ProductSort sort,
  }) async {
    final json = await _client.getMap(
      Endpoints.productSearch,
      query: {
        'q': text,
        ..._query(skip: skip, limit: limit, sort: sort),
      },
    );
    return ProductPageModel.fromJson(json);
  }

  @override
  Future<ProductPageModel> byCategory(
    String slug, {
    required int skip,
    required int limit,
    required ProductSort sort,
  }) async {
    final json = await _client.getMap(
      Endpoints.productsInCategory(slug),
      query: _query(skip: skip, limit: limit, sort: sort),
    );
    return ProductPageModel.fromJson(json);
  }

  @override
  Future<List<CategoryModel>> categories() async {
    final raw = await _client.getList(Endpoints.categories);
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) CategoryModel.fromJson(item),
    ];
  }

  @override
  Future<ProductModel> product(int id) async {
    final json = await _client.getMap(Endpoints.product(id));
    return ProductModel.fromJson(json);
  }

  Map<String, Object?> _query({
    required int skip,
    required int limit,
    required ProductSort sort,
  }) {
    final (sortBy, order) = switch (sort) {
      ProductSort.relevance => (null, null),
      ProductSort.priceLowToHigh => ('price', 'asc'),
      ProductSort.priceHighToLow => ('price', 'desc'),
      ProductSort.topRated => ('rating', 'desc'),
      ProductSort.titleAZ => ('title', 'asc'),
    };
    return {
      'limit': limit,
      'skip': skip,
      'select': listFields,
      'sortBy': ?sortBy,
      'order': ?order,
    };
  }
}
