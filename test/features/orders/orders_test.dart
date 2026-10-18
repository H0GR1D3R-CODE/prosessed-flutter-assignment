import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/orders/data/orders_repository_impl.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';

import '../../helpers/builders.dart';

PlacedOrder _order(int id, {DateTime? at, int quantity = 2}) => PlacedOrder(
  id: id,
  placedAt: at ?? DateTime.utc(2026, 10, 18, 9),
  items: [
    buildCartItem(
      productId: 1,
      unitPrice: 20,
      discount: 50,
      quantity: quantity,
    ),
    buildCartItem(productId: 2, unitPrice: 10, quantity: 1),
  ],
);

void main() {
  group('PlacedOrder', () {
    test('works out its totals the way the cart does', () {
      final summary = _order(1).summary;

      // 2 x 10 (half of 20) + 1 x 10.
      expect(summary.total, 30);
      expect(summary.subtotal, 50);
      expect(summary.discount, 20);
      expect(_order(1).itemCount, 3);
    });
  });

  group('OrderHistory rules', () {
    test('the newest order goes first', () {
      final updated = OrderHistory.record([_order(1)], _order(2));

      expect(updated.map((o) => o.id), [2, 1]);
    });

    test('an order is never listed twice', () {
      final updated = OrderHistory.record([_order(2), _order(1)], _order(1));

      expect(updated.map((o) => o.id), [1, 2]);
    });

    test('only the latest fifty are kept', () {
      var orders = <PlacedOrder>[];
      for (var i = 1; i <= 60; i++) {
        orders = OrderHistory.record(orders, _order(i));
      }

      expect(orders, hasLength(OrderHistory.capacity));
      expect(orders.first.id, 60);
    });
  });

  group('stored on the device', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test(
      'an order comes back exactly as it went in, after a restart',
      () async {
        final order = _order(209, quantity: 3);
        await PrefsOrdersRepository(prefs).save(1, [order]);

        final loaded = await PrefsOrdersRepository(prefs).load(1);

        expect(loaded, [order]);
        expect(loaded.single.summary.total, order.summary.total);
      },
    );

    test('orders belong to one user', () async {
      await PrefsOrdersRepository(prefs).save(1, [_order(1)]);

      expect(await PrefsOrdersRepository(prefs).load(2), isEmpty);
    });

    test(
      'a damaged order list is dropped instead of blocking the app',
      () async {
        SharedPreferences.setMockInitialValues({'orders.1': '[{"id": "x"}]'});
        prefs = await SharedPreferences.getInstance();

        expect(await PrefsOrdersRepository(prefs).load(1), isEmpty);
        expect(prefs.containsKey('orders.1'), isFalse);
      },
    );
  });

  group('OrdersCubit', () {
    late PrefsOrdersRepository repository;
    late OrdersCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = PrefsOrdersRepository(await SharedPreferences.getInstance());
      cubit = OrdersCubit(
        load: LoadOrdersUseCase(repository),
        record: RecordOrderUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('loads what was saved, and says it has loaded', () async {
      await repository.save(1, [_order(7)]);
      expect(cubit.state.loaded, isFalse);

      await cubit.load(1);

      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.orders.single.id, 7);
    });

    test('records an order and saves it', () async {
      await cubit.load(1);

      await cubit.record(_order(209));

      expect(cubit.state.orders.single.id, 209);
      expect((await repository.load(1)).single.id, 209);
    });

    test(
      'ignores orders while signed out, and unload puts the list away',
      () async {
        await cubit.record(_order(1));
        expect(cubit.state.orders, isEmpty);

        await cubit.load(1);
        await cubit.record(_order(1));
        cubit.unload();

        expect(cubit.state.orders, isEmpty);
        expect(cubit.state.loaded, isFalse);
        expect(
          await repository.load(1),
          hasLength(1),
          reason: 'kept for next time',
        );
      },
    );
  });
}
