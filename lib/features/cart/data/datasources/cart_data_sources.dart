import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_config.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

/// The cart on this device, one per user, so it survives restarts and sign-outs.
abstract interface class CartLocalDataSource {
  Future<List<CartItemModel>> read(int userId);
  Future<void> write(int userId, List<CartItemModel> items);
}

class PrefsCartLocalDataSource implements CartLocalDataSource {
  const PrefsCartLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int userId) => 'cart.$userId';

  @override
  Future<List<CartItemModel>> read(int userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return const [];
    try {
      return [
        for (final item in asJsonList(jsonDecode(raw)))
          CartItemModel.fromJson(asJsonMap(item, context: 'cart item')),
      ];
    } on Object {
      // A damaged cart is dropped rather than blocking the shop.
      await _prefs.remove(_key(userId));
      return const [];
    }
  }

  @override
  Future<void> write(int userId, List<CartItemModel> items) async {
    final saved = await _prefs.setString(
      _key(userId),
      jsonEncode([for (final item in items) item.toJson()]),
    );
    if (!saved) throw const CacheException('Could not save the cart');
  }
}

abstract interface class CartRemoteDataSource {
  Future<OrderResponseModel> placeOrder({
    required int userId,
    required Cart cart,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  const CartRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<OrderResponseModel> placeOrder({
    required int userId,
    required Cart cart,
  }) async {
    final json = await _client.postMap(
      Endpoints.addCart,
      authenticated: true,
      body: {
        'userId': userId,
        'products': [
          for (final item in cart.items)
            {'id': item.productId, 'quantity': item.quantity},
        ],
      },
    );
    return OrderResponseModel.fromJson(json);
  }
}
