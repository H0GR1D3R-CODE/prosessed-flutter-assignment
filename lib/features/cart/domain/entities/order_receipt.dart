import 'package:equatable/equatable.dart';

/// What the shopper is shown after placing an order.
///
/// DummyJSON only simulates orders: it returns an id and totals but stores nothing.
class OrderReceipt extends Equatable {
  const OrderReceipt({
    required this.orderId,
    required this.itemCount,
    required this.total,
    required this.placedAt,
  });

  final int orderId;
  final int itemCount;

  /// The total as the app calculated it from the cart.
  final double total;
  final DateTime placedAt;

  @override
  List<Object?> get props => [orderId, itemCount, total, placedAt];
}
