import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';

abstract interface class CartRepository {
  /// The cart saved on this device for [userId]; empty when there is none.
  Future<Result<Cart>> load(int userId);

  /// Saves the cart so it survives an app restart.
  Future<Result<void>> save(int userId, Cart cart);

  /// Sends the order. DummyJSON simulates it: nothing is stored on the server.
  Future<Result<OrderReceipt>> placeOrder({
    required int userId,
    required Cart cart,
  });
}
