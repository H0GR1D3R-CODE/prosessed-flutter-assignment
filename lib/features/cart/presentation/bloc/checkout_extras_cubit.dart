import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';

class CheckoutExtrasState extends Equatable {
  const CheckoutExtrasState({
    this.extras = CheckoutExtras.none,
    this.rejection,
  });

  final CheckoutExtras extras;

  /// Why the last code typed in was not accepted, if it was not.
  final CouponCheck? rejection;

  @override
  List<Object?> get props => [extras, rejection];
}

/// The promo code and donation chosen on the checkout page. It lives only as long as the page:
/// leaving checkout starts the next order afresh.
class CheckoutExtrasCubit extends Cubit<CheckoutExtrasState> {
  CheckoutExtrasCubit() : super(const CheckoutExtrasState());

  /// Tries the typed [input] against an order worth [amount] (after product discounts).
  void applyCode(String input, double amount) {
    if (input.trim().isEmpty) return;
    final check = Coupons.check(input, amount);
    switch (check) {
      case CouponAccepted(:final coupon):
        emit(
          CheckoutExtrasState(
            extras: CheckoutExtras(
              coupon: coupon,
              donation: state.extras.donation,
            ),
          ),
        );
      case CouponUnknown() || CouponTooSmall():
        emit(CheckoutExtrasState(extras: state.extras, rejection: check));
    }
  }

  void removeCoupon() {
    emit(
      CheckoutExtrasState(
        extras: CheckoutExtras(donation: state.extras.donation),
      ),
    );
  }

  void chooseDonation(DonationChoice choice) {
    emit(
      CheckoutExtrasState(
        extras: CheckoutExtras(coupon: state.extras.coupon, donation: choice),
        rejection: state.rejection,
      ),
    );
  }
}
