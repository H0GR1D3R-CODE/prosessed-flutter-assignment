import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_cubit.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';

import '../../../helpers/builders.dart';

class MockCartRepository extends Mock implements CartRepository {}

/// Order history held in memory.
class _MemoryOrdersRepository implements OrdersRepository {
  List<PlacedOrder> saved = const [];

  @override
  Future<List<PlacedOrder>> load(int userId) async => saved;

  @override
  Future<void> save(int userId, List<PlacedOrder> orders) async {
    saved = orders;
  }
}

/// An in-memory repository: remembers whatever was saved last.
class _MemoryCartRepository extends Mock implements CartRepository {
  Cart saved = const Cart();

  @override
  Future<Result<Cart>> load(int userId) async => Result.success(saved);

  @override
  Future<Result<void>> save(int userId, Cart cart) async {
    saved = cart;
    return const Result.success(null);
  }
}

CartCubit _cubit(CartRepository repository) => CartCubit(
  load: LoadCartUseCase(repository),
  add: AddToCartUseCase(repository),
  addLines: AddLinesToCartUseCase(repository),
  updateQuantity: UpdateCartQuantityUseCase(repository),
  remove: RemoveFromCartUseCase(repository),
  restore: RestoreCartItemUseCase(repository),
  clear: ClearCartUseCase(repository),
);

void main() {
  setUpAll(() => registerFallbackValue(const Cart()));

  group('CartCubit', () {
    late _MemoryCartRepository repository;
    late CartCubit cubit;

    setUp(() {
      repository = _MemoryCartRepository();
      cubit = _cubit(repository);
    });

    tearDown(() => cubit.close());

    test('starts signed out and empty', () {
      expect(cubit.state.status, CartStatus.signedOut);
      expect(cubit.state.cart.isEmpty, isTrue);
    });

    test('load reads the saved cart for that user', () async {
      repository.saved = Cart([buildCartItem(productId: 4, quantity: 2)]);

      await cubit.load(1);

      expect(cubit.state.status, CartStatus.ready);
      expect(cubit.state.itemCount, 2);
      expect(cubit.userId, 1);
    });

    test('add puts the product in, saves it and announces it', () async {
      await cubit.load(1);

      await cubit.add(buildProduct(id: 3, title: 'Lamp'), quantity: 2);

      expect(cubit.state.cart.find(3)?.quantity, 2);
      expect(repository.saved.find(3)?.quantity, 2, reason: 'persisted');
      expect(
        cubit.state.event,
        isA<CartItemAdded>()
            .having((e) => e.title, 'title', 'Lamp')
            .having((e) => e.quantity, 'quantity', 2),
      );
    });

    test(
      'adding beyond stock says so instead of pretending it worked',
      () async {
        await cubit.load(1);
        final product = buildProduct(stock: 2);
        await cubit.add(product, quantity: 2);

        await cubit.add(product);

        expect(cubit.state.cart.find(1)?.quantity, 2);
        expect(cubit.state.event, isA<CartLimitReached>());
      },
    );

    test(
      'two quick taps are both counted: updates run one at a time',
      () async {
        await cubit.load(1);
        final product = buildProduct(stock: 10);

        await Future.wait([
          cubit.add(product),
          cubit.add(product),
          cubit.add(product),
        ]);

        expect(cubit.state.cart.find(1)?.quantity, 3);
      },
    );

    test('setQuantity changes the line and stays within the limits', () async {
      await cubit.load(1);
      await cubit.add(buildProduct(stock: 5));

      await cubit.setQuantity(1, 4);
      expect(cubit.state.cart.find(1)?.quantity, 4);

      await cubit.setQuantity(1, 50);
      expect(cubit.state.cart.find(1)?.quantity, 5);

      await cubit.setQuantity(1, 0);
      expect(cubit.state.cart.find(1)?.quantity, 1);
    });

    test('remove can be undone, restoring the line in its place', () async {
      await cubit.load(1);
      await cubit.add(buildProduct(id: 1));
      await cubit.add(buildProduct(id: 2));
      await cubit.add(buildProduct(id: 3));

      await cubit.remove(2);
      final removed = cubit.state.event! as CartItemRemoved;
      expect(cubit.state.cart.items.map((i) => i.productId), [1, 3]);

      await cubit.undoRemove(removed);
      expect(cubit.state.cart.items.map((i) => i.productId), [1, 2, 3]);
      expect(repository.saved.items, hasLength(3));
    });

    test(
      'reorder puts an earlier order back and says how much it added',
      () async {
        await cubit.load(1);
        await cubit.add(buildProduct(id: 1, stock: 10));

        await cubit.reorder([
          buildCartItem(productId: 1, quantity: 2),
          buildCartItem(productId: 2, quantity: 1),
        ]);

        expect(cubit.state.cart.find(1)?.quantity, 3);
        expect(cubit.state.cart.find(2)?.quantity, 1);
        expect(repository.saved.itemCount, 4, reason: 'persisted');
        expect(
          cubit.state.event,
          isA<CartReordered>().having((e) => e.added, 'added', 3),
        );
      },
    );

    test('reorder says so when the cart already holds all of it', () async {
      await cubit.load(1);
      await cubit.add(buildProduct(id: 1, stock: 2), quantity: 2);

      await cubit.reorder([buildCartItem(productId: 1, quantity: 2, stock: 2)]);

      expect(cubit.state.cart.itemCount, 2);
      expect(
        cubit.state.event,
        isA<CartReordered>().having((e) => e.added, 'added', 0),
      );
    });

    test('clear empties the cart and the saved copy', () async {
      await cubit.load(1);
      await cubit.add(buildProduct());

      await cubit.clear();

      expect(cubit.state.cart.isEmpty, isTrue);
      expect(repository.saved.isEmpty, isTrue);
    });

    test(
      'unload forgets the in-memory cart without touching what was saved',
      () async {
        await cubit.load(1);
        await cubit.add(buildProduct());

        cubit.unload();

        expect(cubit.state.status, CartStatus.signedOut);
        expect(cubit.state.cart.isEmpty, isTrue);
        expect(repository.saved.itemCount, 1);
      },
    );

    test('changes are ignored while signed out', () async {
      await cubit.add(buildProduct());

      expect(cubit.state.cart.isEmpty, isTrue);
    });

    test(
      'a failed save is announced but the cart still shows the change',
      () async {
        final failing = MockCartRepository();
        when(() => failing.load(any()))
            .thenAnswer((_) async => const Result.success(Cart()));
        when(() => failing.save(any(), any())).thenAnswer(
          (_) async => const Result.failure(CacheFailure('disk full')),
        );
        final other = _cubit(failing);
        await other.load(1);

        await other.add(buildProduct());

        expect(other.state.cart.itemCount, 1);
        expect(other.state.event, isA<CartSaveFailed>());
        await other.close();
      },
    );
  });

  group('CheckoutCubit', () {
    late MockCartRepository repository;
    late _MemoryCartRepository memory;
    late CartCubit cart;
    late OrdersCubit orders;

    setUp(() async {
      repository = MockCartRepository();
      memory = _MemoryCartRepository();
      cart = _cubit(memory);
      await cart.load(1);
      await cart.add(buildProduct(price: 20, discount: 50), quantity: 2);

      final ordersRepository = _MemoryOrdersRepository();
      orders = OrdersCubit(
        load: LoadOrdersUseCase(ordersRepository),
        record: RecordOrderUseCase(ordersRepository),
      );
      await orders.load(1);
    });

    tearDown(() async {
      await cart.close();
      await orders.close();
    });

    CheckoutCubit buildCheckout() => CheckoutCubit(
      placeOrder: PlaceOrderUseCase(repository),
      cartCubit: cart,
      ordersCubit: orders,
    );

    final receipt = OrderReceipt(
      orderId: 209,
      itemCount: 2,
      total: 20,
      placedAt: DateTime(2026, 10, 18),
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'placing an order goes placing, then placed, and empties the cart',
      setUp: () => when(
        () => repository.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).thenAnswer((_) async => Result.success(receipt)),
      build: buildCheckout,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [const CheckoutPlacing(), CheckoutPlaced(receipt)],
      verify: (_) {
        expect(cart.state.cart.isEmpty, isTrue);
        final order = orders.state.orders.single;
        expect(order.id, 209, reason: 'the order is remembered');
        expect(order.items.single.quantity, 2);
        expect(order.placedAt, DateTime(2026, 10, 18));
        verify(() => repository.placeOrder(userId: 1, cart: any(named: 'cart')))
            .called(1);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a promo code and a donation are worked in and remembered',
      setUp: () => when(
        () => repository.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).thenAnswer((_) async => Result.success(receipt)),
      build: buildCheckout,
      // The cart holds 2 x 10.00 = 20.00 after the product discount.
      act: (cubit) => cubit.placeOrder(
        const CheckoutExtras(
          coupon: Coupons.welcome,
          donation: DonationChoice.two,
        ),
      ),
      verify: (cubit) {
        final order = orders.state.orders.single;
        expect(order.couponCode, 'WELCOME10');
        expect(order.couponDiscount, 2);
        expect(order.donation, 2);
        expect(order.total, 20, reason: '20.00 - 2.00 + 2.00');

        final placed = cubit.state as CheckoutPlaced;
        expect(placed.receipt.total, 20);
        expect(placed.receipt.couponCode, 'WELCOME10');
        expect(placed.receipt.donation, 2);
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'a failed order keeps the cart so the shopper can try again',
      setUp: () => when(
        () => repository.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).thenAnswer((_) async => const Result.failure(NetworkFailure())),
      build: buildCheckout,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        const CheckoutPlacing(),
        const CheckoutFailed(NetworkFailure()),
      ],
      verify: (_) {
        expect(cart.state.cart.itemCount, 2);
        expect(orders.state.orders, isEmpty, reason: 'nothing was ordered');
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'an order cannot be placed twice at once',
      setUp: () =>
          when(
            () => repository.placeOrder(
              userId: any(named: 'userId'),
              cart: any(named: 'cart'),
            ),
          ).thenAnswer((_) async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return Result.success(receipt);
          }),
      build: buildCheckout,
      act: (cubit) async {
        final first = cubit.placeOrder();
        await cubit.placeOrder();
        await first;
      },
      verify: (_) => verify(
        () => repository.placeOrder(
          userId: any(named: 'userId'),
          cart: any(named: 'cart'),
        ),
      ).called(1),
    );
  });
}
