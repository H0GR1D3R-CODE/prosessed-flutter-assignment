import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/domain/wishlist.dart';

/// Keeps each user's saved products on the device, as the same JSON the cache uses.
class WishlistRepositoryImpl implements WishlistRepository {
  const WishlistRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int userId) => 'wishlist.$userId';

  @override
  Future<Result<List<Product>>> load(int userId) {
    return guard(() async {
      final raw = _prefs.getString(_key(userId));
      if (raw == null) return const <Product>[];
      try {
        return [
          for (final item in asJsonList(jsonDecode(raw)))
            ProductModel.fromJson(asJsonMap(item, context: 'wishlist'))
                .toEntity(),
        ];
      } on Object {
        await _prefs.remove(_key(userId));
        return const <Product>[];
      }
    });
  }

  @override
  Future<Result<void>> save(int userId, List<Product> items) {
    return guard(() async {
      final saved = await _prefs.setString(
        _key(userId),
        jsonEncode([
          for (final item in items) ProductModel.fromEntity(item).toJson(),
        ]),
      );
      if (!saved) throw const CacheException('Could not save the wishlist');
    });
  }
}
