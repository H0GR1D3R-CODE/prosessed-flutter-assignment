import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Reads the saved cart of a user.
class LoadCartUseCase {
  const LoadCartUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call(int userId) => _repository.load(userId);
}

/// Every mutation below follows one rule: change the cart in memory, then save it. The new
/// cart is returned even when saving fails, so the screen never shows stale contents; the
/// failure is reported alongside.
class CartChange {
  const CartChange(this.cart, {this.saveFailure});

  final Cart cart;
  final Failure? saveFailure;
}

Future<CartChange> _persist(
  CartRepository repository,
  int userId,
  Cart cart,
) async {
  final saved = await repository.save(userId, cart);
  return CartChange(cart, saveFailure: saved.failureOrNull);
}

class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({
    required int userId,
    required Cart cart,
    required Product product,
    int quantity = 1,
  }) {
    return _persist(_repository, userId, cart.add(product, quantity: quantity));
  }
}

/// Puts the lines of an earlier order back in the cart ("Buy again").
class AddLinesToCartUseCase {
  const AddLinesToCartUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({
    required int userId,
    required Cart cart,
    required List<CartItem> lines,
  }) {
    return _persist(_repository, userId, cart.addLines(lines));
  }
}

class UpdateCartQuantityUseCase {
  const UpdateCartQuantityUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({
    required int userId,
    required Cart cart,
    required int productId,
    required int quantity,
  }) {
    return _persist(_repository, userId, cart.setQuantity(productId, quantity));
  }
}

class RemoveFromCartUseCase {
  const RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({
    required int userId,
    required Cart cart,
    required int productId,
  }) {
    return _persist(_repository, userId, cart.remove(productId));
  }
}

/// Puts back a line the shopper just removed.
class RestoreCartItemUseCase {
  const RestoreCartItemUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({
    required int userId,
    required Cart cart,
    required int index,
    required CartItem item,
  }) {
    return _persist(_repository, userId, cart.insertAt(index, item));
  }
}

class ClearCartUseCase {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  Future<CartChange> call({required int userId}) {
    return _persist(_repository, userId, const Cart());
  }
}

/// Subtotal, discount and grand total of a cart.
class CalculateCartTotalsUseCase {
  const CalculateCartTotalsUseCase();

  CartSummary call(Cart cart) => cart.summary;
}

/// Sends the cart as an order.
class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);

  final CartRepository _repository;

  Future<Result<OrderReceipt>> call({required int userId, required Cart cart}) {
    return _repository.placeOrder(userId: userId, cart: cart);
  }
}
