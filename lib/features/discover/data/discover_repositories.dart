import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/discover/domain/discover.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Search words on the device, one list per user.
///
/// This is a convenience, not data anyone depends on: a list that cannot be read is dropped
/// and a save that fails is ignored, rather than getting in the way of a search.
class PrefsSearchHistoryRepository implements SearchHistoryRepository {
  const PrefsSearchHistoryRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int userId) => 'search.history.$userId';

  @override
  Future<List<String>> load(int userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return const [];
    try {
      return [
        for (final item in asJsonList(jsonDecode(raw)))
          if (item is String) item,
      ];
    } on Object {
      await _prefs.remove(_key(userId));
      return const [];
    }
  }

  @override
  Future<void> save(int userId, List<String> terms) async {
    try {
      await _prefs.setString(_key(userId), jsonEncode(terms));
    } on Object {
      // Not worth interrupting a search over.
    }
  }
}

/// Recently opened products on the device, one list per user, as the same JSON the cache uses.
class PrefsRecentlyViewedRepository implements RecentlyViewedRepository {
  const PrefsRecentlyViewedRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int userId) => 'viewed.products.$userId';

  @override
  Future<List<Product>> load(int userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return const [];
    try {
      return [
        for (final item in asJsonList(jsonDecode(raw)))
          ProductModel.fromJson(asJsonMap(item, context: 'viewed')).toEntity(),
      ];
    } on Object {
      await _prefs.remove(_key(userId));
      return const [];
    }
  }

  @override
  Future<void> save(int userId, List<Product> products) async {
    try {
      await _prefs.setString(
        _key(userId),
        jsonEncode([
          for (final product in products)
            ProductModel.fromEntity(product).toJson(),
        ]),
      );
    } on Object {
      // Not worth interrupting browsing over.
    }
  }
}
