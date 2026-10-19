import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/presentation/bloc/checkout_extras_cubit.dart';

import '../../helpers/builders.dart';

/// The summary of a cart that is worth exactly [total] dollars.
CartSummary _summary(double total) =>
    Cart([buildCartItem(unitPrice: total)]).summary;

void main() {
  group('Coupon', () {
    test('a percentage code takes that share off', () {
      expect(Coupons.welcome.discountFor(8.94), 0.89);
      expect(Coupons.welcome.discountFor(100), 10);
    });

    test('a flat code takes its amount off, once the minimum is reached', () {
      expect(Coupons.save5.discountFor(24.99), 0);
      expect(Coupons.save5.discountFor(25), 5);
      expect(Coupons.save5.discountFor(80), 5);
    });

    test('a capped code never takes more than its cap', () {
      expect(Coupons.orbit20.discountFor(99.99), 0);
      expect(Coupons.orbit20.discountFor(150), 30);
      expect(Coupons.orbit20.discountFor(400), 40);
    });

    test('a code never takes more than the order is worth', () {
      const big = Coupon(code: 'TEN', kind: CouponKind.flat, value: 10);

      expect(big.discountFor(3.5), 3.5);
    });
  });

  group('Coupons.check', () {
    test('ignores case and spaces', () {
      final check = Coupons.check('  welcome 10 ', 20);

      expect(check, const CouponAccepted(Coupons.welcome));
    });

    test('an unknown code is unknown', () {
      expect(Coupons.check('FREEBIES', 50), isA<CouponUnknown>());
    });

    test('a real code below its minimum says how far short the order is', () {
      final check = Coupons.check('SAVE5', 18.5);

      expect(check, const CouponTooSmall(Coupons.save5, 6.5));
    });
  });

  group('DonationChoice', () {
    test('none gives nothing and a fixed choice gives its amount', () {
      expect(DonationChoice.none.amountFor(12.3), 0);
      expect(DonationChoice.two.amountFor(12.3), 2);
      expect(DonationChoice.five.amountFor(0.5), 5);
    });

    test('a round-up brings the order to the next whole dollar', () {
      expect(DonationChoice.roundUp.amountFor(8.05), 0.95);
      expect(DonationChoice.roundUp.amountFor(8.99), 0.01);
    });

    test('rounding up an order that is already whole adds a dollar', () {
      expect(DonationChoice.roundUp.amountFor(9), 1);
    });
  });

  group('CheckoutTotals', () {
    test('with nothing chosen, the total is the cart total', () {
      final totals = CheckoutTotals.of(_summary(40));

      expect(totals.total, 40);
      expect(totals.hasCoupon, isFalse);
      expect(totals.hasDonation, isFalse);
    });

    test('works out the code first, then the donation on what is left', () {
      final totals = CheckoutTotals.of(
        _summary(8.94),
        const CheckoutExtras(
          coupon: Coupons.welcome,
          donation: DonationChoice.roundUp,
        ),
      );

      expect(totals.couponDiscount, 0.89);
      expect(totals.payable, 8.05);
      expect(totals.donation, 0.95);
      expect(totals.total, 9);
    });

    test('a code the cart no longer qualifies for takes nothing off', () {
      final totals = CheckoutTotals.of(
        _summary(20),
        const CheckoutExtras(coupon: Coupons.save5),
      );

      expect(totals.couponDiscount, 0);
      expect(totals.hasCoupon, isFalse);
      expect(totals.total, 20);
    });
  });

  group('CheckoutExtrasCubit', () {
    blocTest<CheckoutExtrasCubit, CheckoutExtrasState>(
      'a good code is applied',
      build: CheckoutExtrasCubit.new,
      act: (cubit) => cubit.applyCode('WELCOME10', 30),
      expect: () => [
        const CheckoutExtrasState(
          extras: CheckoutExtras(coupon: Coupons.welcome),
        ),
      ],
    );

    blocTest<CheckoutExtrasCubit, CheckoutExtrasState>(
      'a bad code is rejected and nothing is applied',
      build: CheckoutExtrasCubit.new,
      act: (cubit) => cubit.applyCode('NOPE', 30),
      expect: () => [const CheckoutExtrasState(rejection: CouponUnknown())],
    );

    blocTest<CheckoutExtrasCubit, CheckoutExtrasState>(
      'an empty box does nothing',
      build: CheckoutExtrasCubit.new,
      act: (cubit) => cubit.applyCode('   ', 30),
      expect: () => <CheckoutExtrasState>[],
    );

    blocTest<CheckoutExtrasCubit, CheckoutExtrasState>(
      'removing the code keeps the donation, and a donation keeps the code',
      build: CheckoutExtrasCubit.new,
      act: (cubit) {
        cubit
          ..applyCode('WELCOME10', 30)
          ..chooseDonation(DonationChoice.two)
          ..removeCoupon();
      },
      expect: () => [
        const CheckoutExtrasState(
          extras: CheckoutExtras(coupon: Coupons.welcome),
        ),
        const CheckoutExtrasState(
          extras: CheckoutExtras(
            coupon: Coupons.welcome,
            donation: DonationChoice.two,
          ),
        ),
        const CheckoutExtrasState(
          extras: CheckoutExtras(donation: DonationChoice.two),
        ),
      ],
    );
  });
}
