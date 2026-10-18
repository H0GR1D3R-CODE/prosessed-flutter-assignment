import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

import '../../../helpers/fake_adapter.dart';
import '../../../helpers/fixtures.dart';

class MockRemote extends Mock implements ProductRemoteDataSource {}

class MockLocal extends Mock implements ProductLocalDataSource {}

ProductPageModel _page() =>
    ProductPageModel.fromJson(fixtureMap('products_list_page'));

void main() {
  setUpAll(() {
    registerFallbackValue(_page());
    registerFallbackValue(ProductSort.relevance);
    registerFallbackValue(<CategoryModel>[]);
  });

  group('ProductModel', () {
    test('parses a list item: only the selected fields are present', () {
      final page = _page();
      final first = page.products.first;

      expect(page.total, 194);
      expect(page.products, hasLength(3));
      expect(first.title, 'Essence Mascara Lash Princess');
      expect(first.brand, 'Essence');
      expect(first.discountPercentage, 10.48);
      expect(first.reviews, isEmpty);
      expect(first.description, isEmpty);
    });

    test('parses the full record with images, reviews and policies', () {
      final product = ProductModel.fromJson(fixtureMap('product_details'));

      expect(product.images, hasLength(1));
      expect(product.reviews, hasLength(3));
      expect(product.reviews.first.reviewerName, 'Eleanor Collins');
      expect(product.reviews.first.date, isNotNull);
      expect(product.warrantyInformation, '1 week warranty');
      expect(product.minimumOrderQuantity, 48);
    });

    test('a product without a brand parses with brand null', () {
      final json = {...fixtureMap('products_list_page')['products'][0] as Map<String, dynamic>}
        ..remove('brand');

      expect(ProductModel.fromJson(json).brand, isNull);
    });

    test('survives a trip through JSON, which is how the offline cache stores it', () {
      final original = _page();
      final again = ProductPageModel.fromJson(original.toJson());

      expect(again.toEntity(), original.toEntity());
    });
  });

  group('Product entity', () {
    test('discountedPrice rounds to cents and hasDiscount ignores noise', () {
      final product = _page().products.first.toEntity();

      expect(product.discountedPrice, 8.94);
      expect(product.hasDiscount, isTrue);
      expect(product.savingPerUnit, closeTo(1.05, 0.001));
    });

    test('availability and the order limit follow stock', () {
      final page = _page().products.first.toEntity();
      expect(page.isAvailable, isTrue);
      expect(page.maxOrderQuantity, 99, reason: 'stock 99 is capped at 99');

      final soldOut = ProductModel.fromJson({
        ...fixtureMap('product_details'),
        'stock': 0,
        'availabilityStatus': 'Out of Stock',
      }).toEntity();
      expect(soldOut.isAvailable, isFalse);
      expect(soldOut.maxOrderQuantity, 0);
    });
  });

  group('ProductRemoteDataSourceImpl', () {
    late FakeAdapter network;
    late ProductRemoteDataSourceImpl remote;

    setUp(() {
      network = FakeAdapter(
        (_) => FakeAdapter.json(200, fixtureMap('products_list_page')),
      );
      remote = ProductRemoteDataSourceImpl(ApiClient(dioWith(network)));
    });

    test('asks for a light payload with limit, skip and the list fields', () async {
      await remote.all(skip: 20, limit: 20, sort: ProductSort.relevance);

      final query = network.requests.single.queryParameters;
      expect(network.requests.single.path, '/products');
      expect(query['limit'], 20);
      expect(query['skip'], 20);
      expect(query['select'], ProductRemoteDataSourceImpl.listFields);
      expect(query.containsKey('sortBy'), isFalse);
    });

    test('maps every sort order to the API parameters', () async {
      final expected = {
        ProductSort.priceLowToHigh: ('price', 'asc'),
        ProductSort.priceHighToLow: ('price', 'desc'),
        ProductSort.topRated: ('rating', 'desc'),
        ProductSort.titleAZ: ('title', 'asc'),
      };
      for (final entry in expected.entries) {
        await remote.all(skip: 0, limit: 20, sort: entry.key);
        final query = network.requests.last.queryParameters;
        expect((query['sortBy'], query['order']), entry.value, reason: '${entry.key}');
      }
    });

    test('search and category use their own endpoints', () async {
      await remote.search('phone', skip: 0, limit: 20, sort: ProductSort.relevance);
      await remote.byCategory('smartphones', skip: 0, limit: 20, sort: ProductSort.relevance);

      expect(network.requests[0].path, '/products/search');
      expect(network.requests[0].queryParameters['q'], 'phone');
      expect(network.requests[1].path, '/products/category/smartphones');
    });

    test('a missing product surfaces as NotFoundException', () async {
      network = FakeAdapter(
        (_) => FakeAdapter.json(404, fixtureMap('product_not_found')),
      );
      remote = ProductRemoteDataSourceImpl(ApiClient(dioWith(network)));

      await expectLater(
        remote.product(9999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('ProductRepositoryImpl', () {
    late MockRemote remote;
    late MockLocal local;
    late ProductRepositoryImpl repository;
    const plain = ProductQuery();

    setUp(() {
      remote = MockRemote();
      local = MockLocal();
      repository = ProductRepositoryImpl(remote: remote, local: local);
      when(() => local.saveFirstPage(any())).thenAnswer((_) async {});
      when(() => local.saveCategories(any())).thenAnswer((_) async {});
    });

    void remoteReturnsPage() => when(
      () => remote.all(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
      ),
    ).thenAnswer((_) async => _page());

    void remoteThrows(AppException error) => when(
      () => remote.all(
        skip: any(named: 'skip'),
        limit: any(named: 'limit'),
        sort: any(named: 'sort'),
      ),
    ).thenThrow(error);

    test('the plain first page is returned and saved for offline use', () async {
      remoteReturnsPage();

      final result = await repository.getProducts(query: plain, skip: 0, limit: 20);

      expect(result.valueOrNull?.items, hasLength(3));
      expect(result.valueOrNull?.fromCache, isFalse);
      verify(() => local.saveFirstPage(any())).called(1);
    });

    test('later pages are not cached', () async {
      remoteReturnsPage();

      await repository.getProducts(query: plain, skip: 20, limit: 20);

      verifyNever(() => local.saveFirstPage(any()));
    });

    test('a server failure falls back to the saved page, flagged as cached', () async {
      remoteThrows(const ServerException(statusCode: 500));
      when(() => local.readFirstPage()).thenAnswer((_) async => _page());

      final result = await repository.getProducts(query: plain, skip: 0, limit: 20);

      expect(result.valueOrNull?.fromCache, isTrue);
      expect(result.valueOrNull?.items, isNotEmpty);
    });

    test('offline with nothing saved is a NetworkFailure', () async {
      remoteThrows(const NetworkException('offline'));
      when(() => local.readFirstPage()).thenAnswer((_) async => null);

      final result = await repository.getProducts(query: plain, skip: 0, limit: 20);

      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('a filtered query never falls back to the unfiltered cache', () async {
      when(
        () => remote.byCategory(
          any(),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        ),
      ).thenThrow(const NetworkException('offline'));

      final result = await repository.getProducts(
        query: const ProductQuery(categorySlug: 'beauty'),
        skip: 0,
        limit: 20,
      );

      expect(result.failureOrNull, isA<NetworkFailure>());
      verifyNever(() => local.readFirstPage());
    });

    test('a search takes precedence over a category', () async {
      when(
        () => remote.search(
          any(),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => _page());

      await repository.getProducts(
        query: const ProductQuery(search: 'phone', categorySlug: 'beauty'),
        skip: 0,
        limit: 20,
      );

      verify(
        () => remote.search('phone', skip: 0, limit: 20, sort: ProductSort.relevance),
      ).called(1);
      verifyNever(
        () => remote.byCategory(
          any(),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          sort: any(named: 'sort'),
        ),
      );
    });

    test('categories fall back to the saved list when the request fails', () async {
      when(() => remote.categories()).thenThrow(const NetworkException('offline'));
      when(() => local.readCategories()).thenAnswer(
        (_) async => [const CategoryModel(slug: 'beauty', name: 'Beauty')],
      );

      final result = await repository.getCategories();

      expect(result.valueOrNull?.single.slug, 'beauty');
    });

    test('an unknown product is a NotFoundFailure', () async {
      when(() => remote.product(9999)).thenThrow(const NotFoundException());

      expect((await repository.getProduct(9999)).failureOrNull, isA<NotFoundFailure>());
    });

    test('a broken cache write does not fail a good response', () async {
      remoteReturnsPage();
      when(() => local.saveFirstPage(any())).thenThrow(const CacheException('full'));

      final result = await repository.getProducts(query: plain, skip: 0, limit: 20);

      expect(result.isSuccess, isTrue);
    });
  });
}
