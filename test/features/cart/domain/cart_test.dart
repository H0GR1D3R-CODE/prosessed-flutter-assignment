import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';

import '../../../helpers/builders.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  group('Cart totals', () {
    test('an empty cart totals nothing', () {
      expect(const Cart().summary, CartSummary.empty);
      expect(const Cart().summary.isEmpty, isTrue);
    });

    test('subtotal, discount and total add up exactly, in whole cents', () {
      final cart = Cart([
        buildCartItem(
          productId: 1,
          unitPrice: 9.99,
          discount: 10.48,
          quantity: 1,
        ),
        buildCartItem(
          productId: 2,
          unitPrice: 44.99,
          discount: 9.64,
          quantity: 2,
        ),
      ]);

      final summary = cart.summary;

      // 9.99 -> 8.94 (10.48% off); 44.99 -> 40.65 (9.64% off) x 2 = 81.30.
      expect(summary.subtotal, 99.97);
      expect(summary.total, 90.24);
      expect(summary.discount, 9.73);
      expect(
        summary.subtotal - summary.discount,
        closeTo(summary.total, 0.0001),
      );
      expect(summary.itemCount, 3);
      expect(summary.lineCount, 2);
    });

    test('classic floating point sums do not drift', () {
      final cart = Cart([
        buildCartItem(productId: 1, unitPrice: 0.1, quantity: 3),
        buildCartItem(productId: 2, unitPrice: 0.2, quantity: 3),
      ]);

      expect(cart.summary.total, 0.9);
    });

    test('a line reports its own saving and total', () {
      final item = buildCartItem(unitPrice: 20, discount: 25, quantity: 2);

      expect(item.discountedUnitPrice, 15);
      expect(item.listTotal, 40);
      expect(item.total, 30);
      expect(item.savings, 10);
    });
  });

  group('Cart changes', () {
    test('adding the same product merges into one line', () {
      final product = buildProduct(id: 5, stock: 10);

      final cart = const Cart().add(product, quantity: 2).add(product);

      expect(cart.items, hasLength(1));
      expect(cart.find(5)?.quantity, 3);
    });

    test('adding never exceeds the stock', () {
      final product = buildProduct(stock: 3);

      final cart = const Cart()
          .add(product, quantity: 2)
          .add(product, quantity: 5);

      expect(cart.find(1)?.quantity, 3);
    });

    test('an out-of-stock product cannot be added', () {
      final soldOut = buildProduct(stock: 0, availability: 'Out of Stock');

      expect(const Cart().add(soldOut), const Cart());
    });

    test('a quantity below one is ignored when adding', () {
      expect(const Cart().add(buildProduct(), quantity: 0).isEmpty, isTrue);
    });

    test('setQuantity clamps between one and the stock, never negative', () {
      final cart = const Cart().add(buildProduct(stock: 4));

      expect(cart.setQuantity(1, 0).find(1)?.quantity, 1);
      expect(cart.setQuantity(1, -3).find(1)?.quantity, 1);
      expect(cart.setQuantity(1, 99).find(1)?.quantity, 4);
      expect(cart.setQuantity(1, 3).find(1)?.quantity, 3);
    });

    test('setQuantity on an unknown product changes nothing', () {
      final cart = const Cart().add(buildProduct());

      expect(cart.setQuantity(42, 3), cart);
    });

    test(
      'remove drops only that line, and insertAt puts it back where it was',
      () {
        final cart = const Cart()
            .add(buildProduct(id: 1))
            .add(buildProduct(id: 2))
            .add(buildProduct(id: 3));
        final removed = cart.find(2)!;

        final without = cart.remove(2);
        final restored = without.insertAt(1, removed);

        expect(without.items.map((i) => i.productId), [1, 3]);
        expect(restored.items.map((i) => i.productId), [1, 2, 3]);
      },
    );

    test('carts are immutable: changes return a new cart', () {
      const original = Cart();
      final changed = original.add(buildProduct());

      expect(original.isEmpty, isTrue);
      expect(changed.isEmpty, isFalse);
    });
  });

  group('cart use cases', () {
    late MockCartRepository repository;

    setUpAll(() => registerFallbackValue(const Cart()));

    setUp(() => repository = MockCartRepository());

    test('AddToCartUseCase returns the new cart and saves it', () async {
      when(() => repository.save(any(), any()))
          .thenAnswer((_) async => const Result.success(null));

      final change = await AddToCartUseCase(repository)(
        userId: 1,
        cart: const Cart(),
        product: buildProduct(),
        quantity: 2,
      );

      expect(change.cart.itemCount, 2);
      expect(change.saveFailure, isNull);
      verify(() => repository.save(1, change.cart)).called(1);
    });

    test('a failed save still returns the updated cart, with the failure alongside', () async {
      when(() => repository.save(any(), any())).thenAnswer(
        (_) async => const Result.failure(CacheFailure('disk full')),
      );

      final change = await AddToCartUseCase(repository)(
        userId: 1,
        cart: const Cart(),
        product: buildProduct(),
      );

      expect(
        change.cart.itemCount,
        1,
        reason: 'the screen must not show stale contents',
      );
      expect(change.saveFailure, isA<CacheFailure>());
    });

    test('ClearCartUseCase saves an empty cart', () async {
      when(() => repository.save(any(), any()))
          .thenAnswer((_) async => const Result.success(null));

      final change = await ClearCartUseCase(repository)(userId: 7);

      expect(change.cart.isEmpty, isTrue);
      verify(() => repository.save(7, const Cart())).called(1);
    });

    test('CalculateCartTotalsUseCase is the cart summary', () {
      final cart = const Cart().add(
        buildProduct(price: 12.5, discount: 20),
        quantity: 2,
      );

      expect(const CalculateCartTotalsUseCase()(cart).total, 20);
    });
  });
}
