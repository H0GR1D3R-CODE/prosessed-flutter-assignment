import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/categories_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_details_cubit.dart';
import 'package:shopsphere/features/products/presentation/bloc/product_list_cubit.dart';

import '../../../helpers/builders.dart';

class MockProductRepository extends Mock implements ProductRepository {}

ProductPage _page(
  List<int> ids, {
  int total = 100,
  int skip = 0,
  bool cached = false,
}) => ProductPage(
  items: [for (final id in ids) buildProduct(id: id)],
  total: total,
  skip: skip,
  fromCache: cached,
);

void main() {
  late MockProductRepository repository;

  setUpAll(() => registerFallbackValue(const ProductQuery()));

  setUp(() => repository = MockProductRepository());

  void stubPage(ProductPage page) => when(
    () => repository.getProducts(
      query: any(named: 'query'),
      skip: any(named: 'skip'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => Result.success(page));

  ProductListCubit buildList() => ProductListCubit(
    getProducts: GetProductsUseCase(repository),
    searchDebounce: const Duration(milliseconds: 20),
  );

  group('ProductListCubit', () {
    blocTest<ProductListCubit, ProductListState>(
      'loads the first page: loading, then loaded with paging figures',
      setUp: () => stubPage(_page([1, 2, 3], total: 50)),
      build: buildList,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductListLoading(ProductQuery()),
        isA<ProductListLoaded>()
            .having((s) => s.items.length, 'items', 3)
            .having((s) => s.total, 'total', 50)
            .having((s) => s.hasMore, 'hasMore', isTrue)
            .having((s) => s.fromCache, 'fromCache', isFalse),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'an empty result is the empty state, not a blank list',
      setUp: () => stubPage(_page([], total: 0)),
      build: buildList,
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductListLoading(ProductQuery()),
        const ProductListEmpty(ProductQuery()),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'a failure shows the failure state, and load() again is the retry',
      setUp: () {
        var calls = 0;
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => calls++ == 0
              ? const Result.failure(NetworkFailure())
              : Result.success(_page([1])),
        );
      },
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.load();
      },
      expect: () => [
        const ProductListLoading(ProductQuery()),
        const ProductListFailure(ProductQuery(), NetworkFailure()),
        const ProductListLoading(ProductQuery()),
        isA<ProductListLoaded>(),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'offline with a saved copy shows it, flagged, and stops paging',
      setUp: () => stubPage(_page([1, 2], total: 50, cached: true)),
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.loadMore();
      },
      expect: () => [
        const ProductListLoading(ProductQuery()),
        isA<ProductListLoaded>().having(
          (s) => s.fromCache,
          'fromCache',
          isTrue,
        ),
      ],
      verify: (_) => verify(
        () => repository.getProducts(
          query: any(named: 'query'),
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
        ),
      ).called(1),
    );

    blocTest<ProductListCubit, ProductListState>(
      'loadMore appends the next page, skipping what is already shown',
      setUp: () {
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: 0,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Result.success(_page([1, 2], total: 4)));
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: 2,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => Result.success(_page([2, 3, 4], total: 4, skip: 2)),
        );
      },
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.loadMore();
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          isTrue,
        ),
        isA<ProductListLoaded>()
            .having((s) => s.items.map((p) => p.id), 'ids', [1, 2, 3, 4])
            .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
            .having((s) => s.hasMore, 'hasMore', isFalse),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'a failed next page keeps the products and offers a retry',
      setUp: () {
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: 0,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Result.success(_page([1, 2], total: 10)));
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: 2,
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const Result.failure(TimeoutFailure()));
      },
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.loadMore();
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>().having(
          (s) => s.isLoadingMore,
          'loading',
          isTrue,
        ),
        isA<ProductListLoaded>()
            .having((s) => s.items.length, 'items kept', 2)
            .having((s) => s.loadMoreFailure, 'failure', isA<TimeoutFailure>())
            .having((s) => s.isLoadingMore, 'loading', isFalse),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'loadMore does nothing once everything is loaded',
      setUp: () => stubPage(_page([1, 2], total: 2)),
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.loadMore();
      },
      skip: 2,
      expect: () => <ProductListState>[],
    );

    blocTest<ProductListCubit, ProductListState>(
      'typing searches once, after the debounce, and clears the category',
      setUp: () => stubPage(_page([1])),
      build: buildList,
      seed: () =>
          const ProductListLoading(ProductQuery(categorySlug: 'beauty')),
      act: (cubit) async {
        cubit
          ..searchChanged('p')
          ..searchChanged('ph')
          ..searchChanged('pho');
        await Future<void>.delayed(const Duration(milliseconds: 80));
      },
      expect: () => [
        const ProductListLoading(ProductQuery(search: 'pho')),
        isA<ProductListLoaded>(),
      ],
      verify: (_) => verify(
        () => repository.getProducts(
          query: const ProductQuery(search: 'pho'),
          skip: 0,
          limit: 20,
        ),
      ).called(1),
    );

    blocTest<ProductListCubit, ProductListState>(
      'choosing a category clears the search; choosing a sort keeps the category',
      setUp: () => stubPage(_page([1])),
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        cubit.selectCategory('smartphones');
        await Future<void>.delayed(Duration.zero);
        cubit.selectSort(ProductSort.priceLowToHigh);
      },
      verify: (cubit) {
        expect(
          cubit.state.query,
          const ProductQuery(
            categorySlug: 'smartphones',
            sort: ProductSort.priceLowToHigh,
          ),
        );
      },
    );

    test(
      'a slow answer for an old query cannot overwrite a newer one',
      () async {
        final slow = Completer<Result<ProductPage>>();
        when(
          () => repository.getProducts(
            query: const ProductQuery(),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) => slow.future);
        when(
          () => repository.getProducts(
            query: const ProductQuery(categorySlug: 'beauty'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Result.success(_page([7])));
        final cubit = buildList();

        final first = cubit.load();
        cubit.selectCategory('beauty');
        await Future<void>.delayed(Duration.zero);
        slow.complete(Result.success(_page([1, 2, 3])));
        await first;

        final state = cubit.state as ProductListLoaded;
        expect(state.items.map((p) => p.id), [7]);
        expect(state.query.categorySlug, 'beauty');
        await cubit.close();
      },
    );

    blocTest<ProductListCubit, ProductListState>(
      'pull-to-refresh keeps the list on screen and swaps in the fresh page',
      setUp: () {
        var calls = 0;
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async =>
              Result.success(calls++ == 0 ? _page([1, 2]) : _page([9])),
        );
      },
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>().having(
          (s) => s.items.map((p) => p.id),
          'ids',
          [9],
        ),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      'a failed refresh keeps the list and reports the failure once',
      setUp: () {
        var calls = 0;
        when(
          () => repository.getProducts(
            query: any(named: 'query'),
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer(
          (_) async => calls++ == 0
              ? Result.success(_page([1, 2], total: 2))
              : const Result.failure(NetworkFailure()),
        );
      },
      build: buildList,
      act: (cubit) async {
        await cubit.load();
        await cubit.refresh();
      },
      skip: 2,
      expect: () => [
        isA<ProductListLoaded>()
            .having((s) => s.items.length, 'items kept', 2)
            .having((s) => s.refreshFailure, 'failure', isA<NetworkFailure>()),
      ],
    );
  });

  group('ProductDetailsCubit', () {
    ProductDetailsCubit buildDetails(int id) => ProductDetailsCubit(
      productId: id,
      getProduct: GetProductDetailsUseCase(repository),
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'loads one product',
      setUp: () =>
          when(() => repository.getProduct(1))
              .thenAnswer((_) async => Result.success(buildProduct())),
      build: () => buildDetails(1),
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductDetailsLoading(),
        ProductDetailsLoaded(buildProduct()),
      ],
    );

    blocTest<ProductDetailsCubit, ProductDetailsState>(
      'a product that does not exist ends in NotFoundFailure',
      setUp: () => when(() => repository.getProduct(9999)).thenAnswer(
        (_) async => const Result<Product>.failure(NotFoundFailure()),
      ),
      build: () => buildDetails(9999),
      act: (cubit) => cubit.load(),
      expect: () => [
        const ProductDetailsLoading(),
        const ProductDetailsFailure(NotFoundFailure()),
      ],
    );
  });

  group('CategoriesCubit', () {
    blocTest<CategoriesCubit, CategoriesState>(
      'loads the chips',
      setUp: () => when(() => repository.getCategories()).thenAnswer(
        (_) async => const Result.success([
          ProductCategory(slug: 'beauty', name: 'Beauty'),
        ]),
      ),
      build: () => CategoriesCubit(GetCategoriesUseCase(repository)),
      act: (cubit) => cubit.load(),
      expect: () => [
        const CategoriesLoading(),
        const CategoriesLoaded([
          ProductCategory(slug: 'beauty', name: 'Beauty'),
        ]),
      ],
    );

    blocTest<CategoriesCubit, CategoriesState>(
      'a failure is reported so the strip can offer a retry',
      setUp: () =>
          when(() => repository.getCategories())
              .thenAnswer((_) async => const Result.failure(NetworkFailure())),
      build: () => CategoriesCubit(GetCategoriesUseCase(repository)),
      act: (cubit) => cubit.load(),
      expect: () => [
        const CategoriesLoading(),
        const CategoriesFailure(NetworkFailure()),
      ],
    );
  });
}
