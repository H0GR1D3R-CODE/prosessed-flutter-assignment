import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';

/// What the shopper is shown after placing an order.
///
/// DummyJSON only simulates orders: it returns an id and totals but stores nothing.
class OrderReceipt extends Equatable {
  const OrderReceipt({
    required this.orderId,
    required this.itemCount,
    required this.total,
    required this.placedAt,
    this.couponCode,
    this.couponDiscount = 0,
    this.donation = 0,
  });

  final int orderId;
  final int itemCount;

  /// What the shopper paid as the app calculated it: the cart, less any code, plus any donation.
  final double total;
  final DateTime placedAt;

  /// The promo code used, what it took off, and what was given to the cause.
  final String? couponCode;
  final double couponDiscount;
  final double donation;

  /// This receipt with the checkout choices worked in.
  OrderReceipt withTotals(CheckoutTotals totals) => OrderReceipt(
    orderId: orderId,
    itemCount: itemCount,
    total: totals.total,
    placedAt: placedAt,
    couponCode: totals.hasCoupon ? totals.coupon?.code : null,
    couponDiscount: totals.couponDiscount,
    donation: totals.donation,
  );

  @override
  List<Object?> get props => [
    orderId,
    itemCount,
    total,
    placedAt,
    couponCode,
    couponDiscount,
    donation,
  ];
}
