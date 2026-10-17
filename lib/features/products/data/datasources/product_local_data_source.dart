import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';

/// Offline copies of the two lists the shop needs to open without a connection.
abstract interface class ProductLocalDataSource {
  Future<ProductPageModel?> readFirstPage();
  Future<void> saveFirstPage(ProductPageModel page);
  Future<List<CategoryModel>?> readCategories();
  Future<void> saveCategories(List<CategoryModel> categories);
}

class PrefsProductLocalDataSource implements ProductLocalDataSource {
  const PrefsProductLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const String _pageKey = 'cache.products.first_page';
  static const String _categoriesKey = 'cache.products.categories';

  @override
  Future<ProductPageModel?> readFirstPage() async {
    final raw = _prefs.getString(_pageKey);
    if (raw == null) return null;
    try {
      return ProductPageModel.fromJson(asJsonMap(jsonDecode(raw)));
    } on Object {
      await _prefs.remove(_pageKey);
      return null;
    }
  }

  @override
  Future<void> saveFirstPage(ProductPageModel page) =>
      _write(_pageKey, jsonEncode(page.toJson()));

  @override
  Future<List<CategoryModel>?> readCategories() async {
    final raw = _prefs.getString(_categoriesKey);
    if (raw == null) return null;
    try {
      final list = asJsonList(jsonDecode(raw));
      return [
        for (final item in list)
          CategoryModel.fromJson(asJsonMap(item, context: 'category')),
      ];
    } on Object {
      await _prefs.remove(_categoriesKey);
      return null;
    }
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) => _write(
    _categoriesKey,
    jsonEncode([for (final category in categories) category.toJson()]),
  );

  Future<void> _write(String key, String value) async {
    final saved = await _prefs.setString(key, value);
    if (!saved) throw CacheException('Could not save $key');
  }
}
