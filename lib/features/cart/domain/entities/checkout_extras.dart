import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

/// Checkout works in whole cents too, so a coupon and a round-up never drift by a cent.
int _cents(double amount) => (amount * 100).round();
double _dollars(int cents) => cents / 100;

enum CouponKind {
  /// A share of the amount: `value` is a percentage.
  percent,

  /// A fixed amount off: `value` is in dollars.
  flat,
}

/// A promo code. DummyJSON has no coupons, so these are the app's own, and the rules live here
/// where they can be tested without a screen.
class Coupon extends Equatable {
  const Coupon({
    required this.code,
    required this.kind,
    required this.value,
    this.minimumSpend = 0,
    this.maxDiscount,
  });

  final String code;
  final CouponKind kind;
  final double value;

  /// The amount (after product discounts) the order must reach before the code works.
  final double minimumSpend;

  /// The most a percentage code may take off.
  final double? maxDiscount;

  bool isEligible(double amount) => _cents(amount) >= _cents(minimumSpend);

  /// What the code takes off [amount]: nothing if it is not eligible, never more than the amount.
  double discountFor(double amount) {
    if (!isEligible(amount)) return 0;
    final available = _cents(amount);
    var off = switch (kind) {
      CouponKind.percent => (available * value / 100).round(),
      CouponKind.flat => _cents(value),
    };
    if (maxDiscount != null) off = math.min(off, _cents(maxDiscount!));
    return _dollars(math.min(off, available));
  }

  @override
  List<Object?> get props => [code, kind, value, minimumSpend, maxDiscount];
}

/// What checking a typed code found.
sealed class CouponCheck extends Equatable {
  const CouponCheck();

  @override
  List<Object?> get props => [];
}

final class CouponAccepted extends CouponCheck {
  const CouponAccepted(this.coupon);

  final Coupon coupon;

  @override
  List<Object?> get props => [coupon];
}

/// No such code.
final class CouponUnknown extends CouponCheck {
  const CouponUnknown();
}

/// A real code, but the order is [shortBy] dollars away from its minimum.
final class CouponTooSmall extends CouponCheck {
  const CouponTooSmall(this.coupon, this.shortBy);

  final Coupon coupon;
  final double shortBy;

  @override
  List<Object?> get props => [coupon, shortBy];
}

/// The codes the app knows.
abstract final class Coupons {
  static const Coupon welcome = Coupon(
    code: 'WELCOME10',
    kind: CouponKind.percent,
    value: 10,
  );
  static const Coupon save5 = Coupon(
    code: 'SAVE5',
    kind: CouponKind.flat,
    value: 5,
    minimumSpend: 25,
  );
  static const Coupon orbit20 = Coupon(
    code: 'ORBIT20',
    kind: CouponKind.percent,
    value: 20,
    minimumSpend: 100,
    maxDiscount: 40,
  );

  static const List<Coupon> all = [welcome, save5, orbit20];

  /// Codes are not case sensitive and spaces do not matter.
  static String normalise(String input) =>
      input.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  /// Looks [input] up and says whether it works for an order worth [amount].
  static CouponCheck check(String input, double amount) {
    final code = normalise(input);
    for (final coupon in all) {
      if (coupon.code != code) continue;
      if (coupon.isEligible(amount)) return CouponAccepted(coupon);
      return CouponTooSmall(
        coupon,
        _dollars(_cents(coupon.minimumSpend) - _cents(amount)),
      );
    }
    return const CouponUnknown();
  }
}

enum DonationKind { none, roundUp, fixed }

/// How much the shopper chooses to give to the cause at checkout.
class DonationChoice extends Equatable {
  const DonationChoice._(this.kind, this.amount);

  static const DonationChoice none = DonationChoice._(DonationKind.none, 0);
  static const DonationChoice roundUp = DonationChoice._(
    DonationKind.roundUp,
    0,
  );
  static const DonationChoice one = DonationChoice._(DonationKind.fixed, 1);
  static const DonationChoice two = DonationChoice._(DonationKind.fixed, 2);
  static const DonationChoice five = DonationChoice._(DonationKind.fixed, 5);

  static const List<DonationChoice> options = [none, roundUp, one, two, five];

  final DonationKind kind;

  /// The fixed amount, in dollars. Unused for the other kinds.
  final double amount;

  /// What this choice adds to an order that would otherwise cost [payable].
  ///
  /// A round-up brings the order to the next whole dollar, and adds a dollar if it already is one.
  double amountFor(double payable) {
    switch (kind) {
      case DonationKind.none:
        return 0;
      case DonationKind.fixed:
        return amount;
      case DonationKind.roundUp:
        final remainder = _cents(payable) % 100;
        return _dollars(remainder == 0 ? 100 : 100 - remainder);
    }
  }

  @override
  List<Object?> get props => [kind, amount];
}

/// What the shopper picked on the checkout page, besides the products.
class CheckoutExtras extends Equatable {
  const CheckoutExtras({this.coupon, this.donation = DonationChoice.none});

  static const CheckoutExtras none = CheckoutExtras();

  final Coupon? coupon;
  final DonationChoice donation;

  @override
  List<Object?> get props => [coupon, donation];
}

/// Every figure checkout shows: the cart's own, then the code, then the donation.
class CheckoutTotals extends Equatable {
  const CheckoutTotals({
    required this.summary,
    required this.couponDiscount,
    required this.donation,
    this.coupon,
  });

  factory CheckoutTotals.of(
    CartSummary summary, [
    CheckoutExtras extras = CheckoutExtras.none,
  ]) {
    final coupon = extras.coupon;
    // A code that no longer fits (the cart shrank) takes nothing off instead of being dropped.
    final couponDiscount = coupon?.discountFor(summary.total) ?? 0;
    final payable = _dollars(_cents(summary.total) - _cents(couponDiscount));
    return CheckoutTotals(
      summary: summary,
      coupon: coupon,
      couponDiscount: couponDiscount,
      donation: extras.donation.amountFor(payable),
    );
  }

  final CartSummary summary;
  final Coupon? coupon;
  final double couponDiscount;
  final double donation;

  /// What the order costs before any donation.
  double get payable =>
      _dollars(_cents(summary.total) - _cents(couponDiscount));

  /// What the shopper pays, donation included.
  double get total => _dollars(_cents(payable) + _cents(donation));

  bool get hasCoupon => coupon != null && couponDiscount > 0;
  bool get hasDonation => donation > 0;

  @override
  List<Object?> get props => [summary, coupon, couponDiscount, donation];
}
