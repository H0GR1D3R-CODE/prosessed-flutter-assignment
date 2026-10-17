import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Whether the cart has been read from the device yet.
enum CartStatus { signedOut, loading, ready }

/// Something the screen should tell the user about, once.
///
/// Each event carries a [serial] so two identical events in a row (adding the same product
/// twice) still count as different, and the snackbar listener fires both times.
sealed class CartEvent extends Equatable {
  const CartEvent(this.serial);

  final int serial;

  @override
  List<Object?> get props => [serial];
}

final class CartItemAdded extends CartEvent {
  const CartItemAdded(
    super.serial, {
    required this.title,
    required this.quantity,
  });

  final String title;
  final int quantity;
}

/// Nothing was added: the cart already holds everything that is in stock.
final class CartLimitReached extends CartEvent {
  const CartLimitReached(
    super.serial, {
    required this.title,
    required this.limit,
  });

  final String title;
  final int limit;
}

/// A line was removed. Carries what is needed to put it back.
final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(
    super.serial, {
    required this.item,
    required this.index,
  });

  final CartItem item;
  final int index;
}

final class CartSaveFailed extends CartEvent {
  const CartSaveFailed(super.serial, this.failure);

  final Failure failure;
}

class CartState extends Equatable {
  const CartState({
    this.cart = const Cart(),
    this.status = CartStatus.signedOut,
    this.event,
  });

  final Cart cart;
  final CartStatus status;
  final CartEvent? event;

  CartSummary get summary => cart.summary;
  int get itemCount => cart.itemCount;

  CartState copyWith({Cart? cart, CartStatus? status, CartEvent? event}) {
    return CartState(
      cart: cart ?? this.cart,
      status: status ?? this.status,
      event: event,
    );
  }

  @override
  List<Object?> get props => [cart, status, event];
}

/// The shopping cart for whoever is signed in. One instance for the whole app, so the badge,
/// the product page and the cart screen always agree.
class CartCubit extends Cubit<CartState> {
  CartCubit({
    required this._load,
    required this._add,
    required this._updateQuantity,
    required this._remove,
    required this._restore,
    required this._clear,
  }) : super(const CartState());

  final LoadCartUseCase _load;
  final AddToCartUseCase _add;
  final UpdateCartQuantityUseCase _updateQuantity;
  final RemoveFromCartUseCase _remove;
  final RestoreCartItemUseCase _restore;
  final ClearCartUseCase _clear;

  int? _userId;
  int _serial = 0;
  Future<void> _tail = Future<void>.value();

  int? get userId => _userId;

  /// Mutations run one after another, so two quick taps on "+" cannot both start from the same
  /// cart and lose an update.
  Future<void> _enqueue(Future<void> Function() operation) {
    final next = _tail.then((_) => operation());
    _tail = next.catchError((Object _) {});
    return next;
  }

  /// Reads the cart saved for [userId] and starts tracking it.
  Future<void> load(int userId) async {
    if (_userId == userId && state.status == CartStatus.ready) return;
    _userId = userId;
    emit(const CartState(status: CartStatus.loading));
    final result = await _load(userId);
    if (_userId != userId) return;
    emit(
      CartState(
        cart: result.valueOrNull ?? const Cart(),
        status: CartStatus.ready,
        event: result.failureOrNull == null
            ? null
            : CartSaveFailed(++_serial, result.failureOrNull!),
      ),
    );
  }

  /// Forgets the in-memory cart (the saved one stays on the device for next time).
  void unload() {
    _userId = null;
    emit(const CartState());
  }

  Future<void> add(Product product, {int quantity = 1}) {
    return _enqueue(() async {
      final userId = _userId;
      if (userId == null) return;
      final before = state.cart.find(product.id)?.quantity ?? 0;
      final change = await _add(
        userId: userId,
        cart: state.cart,
        product: product,
        quantity: quantity,
      );
      final added = (change.cart.find(product.id)?.quantity ?? 0) - before;
      emit(
        state.copyWith(
          cart: change.cart,
          status: CartStatus.ready,
          event: added <= 0
              ? CartLimitReached(++_serial, title: product.title, limit: before)
              : CartItemAdded(++_serial, title: product.title, quantity: added),
        ),
      );
      _reportSaveFailure(change);
    });
  }

  Future<void> setQuantity(int productId, int quantity) {
    return _enqueue(() async {
      final userId = _userId;
      if (userId == null) return;
      final change = await _updateQuantity(
        userId: userId,
        cart: state.cart,
        productId: productId,
        quantity: quantity,
      );
      emit(state.copyWith(cart: change.cart));
      _reportSaveFailure(change);
    });
  }

  Future<void> remove(int productId) {
    return _enqueue(() async {
      final userId = _userId;
      final item = state.cart.find(productId);
      if (userId == null || item == null) return;
      final index = state.cart.items.indexOf(item);
      final change = await _remove(
        userId: userId,
        cart: state.cart,
        productId: productId,
      );
      emit(
        state.copyWith(
          cart: change.cart,
          event: CartItemRemoved(++_serial, item: item, index: index),
        ),
      );
      _reportSaveFailure(change);
    });
  }

  /// Puts back the line [event] describes.
  Future<void> undoRemove(CartItemRemoved event) {
    return _enqueue(() async {
      final userId = _userId;
      if (userId == null) return;
      final change = await _restore(
        userId: userId,
        cart: state.cart,
        index: event.index,
        item: event.item,
      );
      emit(state.copyWith(cart: change.cart));
      _reportSaveFailure(change);
    });
  }

  /// Empties the cart, e.g. after an order is placed.
  Future<void> clear() {
    return _enqueue(() async {
      final userId = _userId;
      if (userId == null) return;
      final change = await _clear(userId: userId);
      emit(state.copyWith(cart: change.cart));
      _reportSaveFailure(change);
    });
  }

  void _reportSaveFailure(CartChange change) {
    final failure = change.saveFailure;
    if (failure != null) {
      emit(state.copyWith(event: CartSaveFailed(++_serial, failure)));
    }
  }
}
