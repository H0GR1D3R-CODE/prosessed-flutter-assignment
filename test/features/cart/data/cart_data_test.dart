import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/fixtures.dart';

class MockRemote extends Mock implements CartRemoteDataSource {}

void main() {
  setUpAll(() => registerFallbackValue(const Cart()));

  group('PrefsCartLocalDataSource', () {
    test('keeps each user\'s cart separate and survives a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = PrefsCartLocalDataSource(prefs);

      await first.write(1, [
        CartItemModel.fromEntity(buildCartItem(productId: 9, quantity: 3)),
      ]);

      // A new data source over the same storage is what an app restart looks like.
      final restarted = PrefsCartLocalDataSource(prefs);
      expect((await restarted.read(1)).single.quantity, 3);
      expect(await restarted.read(2), isEmpty);
    });

    test(
      'a damaged saved cart is dropped instead of blocking the app',
      () async {
        SharedPreferences.setMockInitialValues({'cart.1': '{not json'});
        final prefs = await SharedPreferences.getInstance();

        expect(await PrefsCartLocalDataSource(prefs).read(1), isEmpty);
        expect(prefs.containsKey('cart.1'), isFalse);
      },
    );
  });

  group('CartRepositoryImpl', () {
    late MockRemote remote;
    late CartRepositoryImpl repository;
    late PrefsCartLocalDataSource local;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      local = PrefsCartLocalDataSource(await SharedPreferences.getInstance());
      remote = MockRemote();
      repository = CartRepositoryImpl(
        local: local,
        remote: remote,
        clock: () => DateTime(2026, 10, 18, 9),
      );
    });

    test('what is saved is what is loaded', () async {
      final cart = const Cart().add(
        buildProduct(id: 5, price: 12.5, discount: 20),
        quantity: 2,
      );

      await repository.save(1, cart);
      final loaded = await repository.load(1);

      expect(loaded.valueOrNull, cart);
    });

    test('an order uses the API id and the app\'s own totals', () async {
      when(
        () => remote.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).thenAnswer(
        (_) async => OrderResponseModel.fromJson(fixtureMap('carts_add')),
      );
      final cart = const Cart().add(
        buildProduct(price: 20, discount: 50),
        quantity: 3,
      );

      final receipt = (await repository.placeOrder(
        userId: 1,
        cart: cart,
      )).valueOrNull!;

      expect(receipt.orderId, 209);
      expect(receipt.itemCount, 3);
      expect(receipt.total, 30);
      expect(receipt.placedAt, DateTime(2026, 10, 18, 9));
    });

    test('a failed order is a typed failure', () async {
      when(
        () => remote.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).thenThrow(const RequestTimeoutException());

      final result = await repository.placeOrder(userId: 1, cart: const Cart());

      expect(result.failureOrNull, isA<TimeoutFailure>());
    });
  });

  group('OrderResponseModel', () {
    test('parses the simulated order the API returns', () {
      final response = OrderResponseModel.fromJson(fixtureMap('carts_add'));

      expect(response.id, 209);
      expect(response.totalQuantity, 3);
    });
  });
}
