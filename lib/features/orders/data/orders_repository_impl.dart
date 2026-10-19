import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/cart/data/models/cart_models.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';

/// Placed orders on the device, one list per user, using the same JSON as the saved cart.
///
/// A list that cannot be read is dropped rather than blocking the app, and a save that fails
/// is ignored: the order itself has already been placed.
class PrefsOrdersRepository implements OrdersRepository {
  const PrefsOrdersRepository(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int userId) => 'orders.$userId';

  @override
  Future<List<PlacedOrder>> load(int userId) async {
    final raw = _prefs.getString(_key(userId));
    if (raw == null) return const [];
    try {
      return [
        for (final item in asJsonList(jsonDecode(raw)))
          _fromJson(asJsonMap(item, context: 'order')),
      ];
    } on Object {
      await _prefs.remove(_key(userId));
      return const [];
    }
  }

  @override
  Future<void> save(int userId, List<PlacedOrder> orders) async {
    try {
      await _prefs.setString(
        _key(userId),
        jsonEncode([for (final order in orders) _toJson(order)]),
      );
    } on Object {
      // The order was placed; failing to remember it should not undo that.
    }
  }

  static Map<String, dynamic> _toJson(PlacedOrder order) => {
    'id': order.id,
    'placedAt': order.placedAt.toUtc().toIso8601String(),
    'items': [
      for (final item in order.items) CartItemModel.fromEntity(item).toJson(),
    ],
    if (order.couponCode != null) 'couponCode': order.couponCode,
    if (order.couponDiscount > 0) 'couponDiscount': order.couponDiscount,
    if (order.donation > 0) 'donation': order.donation,
  };

  static PlacedOrder _fromJson(Map<String, dynamic> json) => PlacedOrder(
    id: json.integer('id'),
    placedAt: DateTime.parse(json.string('placedAt')),
    items: [
      for (final item in asJsonList(json['items']))
        CartItemModel.fromJson(asJsonMap(item, context: 'order line'))
            .toEntity(),
    ],
    // Orders saved before codes and donations existed have neither.
    couponCode: json.stringOrNull('couponCode'),
    couponDiscount: json.decimalOr('couponDiscount', 0),
    donation: json.decimalOr('donation', 0),
  );
}
