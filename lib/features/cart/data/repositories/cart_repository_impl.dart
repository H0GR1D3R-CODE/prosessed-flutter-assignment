import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl({
    required this._local,
    required this._remote,
    this._clock = DateTime.now,
  });

  final CartLocalDataSource _local;
  final CartRemoteDataSource _remote;
  final DateTime Function() _clock;

  @override
  Future<Result<Cart>> load(int userId) {
    return guard(() async {
      final models = await _local.read(userId);
      return Cart([for (final model in models) model.toEntity()]);
    });
  }

  @override
  Future<Result<void>> save(int userId, Cart cart) {
    return guard(
      () => _local.write(userId, [
        for (final item in cart.items) CartItemModel.fromEntity(item),
      ]),
    );
  }

  @override
  Future<Result<OrderReceipt>> placeOrder({
    required int userId,
    required Cart cart,
  }) {
    return guard(() async {
      final response = await _remote.placeOrder(userId: userId, cart: cart);
      return response.toReceipt(cart: cart, placedAt: _clock());
    });
  }
}
