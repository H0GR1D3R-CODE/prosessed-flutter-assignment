import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';
import 'package:shopsphere/features/orders/presentation/bloc/orders_cubit.dart';

sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

final class CheckoutReview extends CheckoutState {
  const CheckoutReview();
}

final class CheckoutPlacing extends CheckoutState {
  const CheckoutPlacing();
}

final class CheckoutPlaced extends CheckoutState {
  const CheckoutPlaced(this.receipt);

  final OrderReceipt receipt;

  @override
  List<Object?> get props => [receipt];
}

final class CheckoutFailed extends CheckoutState {
  const CheckoutFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Places the order for the current cart. Once the server accepts it, the order is recorded in
/// the shopper's history and the cart is emptied.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required this._placeOrder,
    required this._cartCubit,
    required this._ordersCubit,
  }) : super(const CheckoutReview());

  final PlaceOrderUseCase _placeOrder;
  final CartCubit _cartCubit;
  final OrdersCubit _ordersCubit;

  /// Places the order. [extras] are the promo code and donation chosen on the checkout page.
  Future<void> placeOrder([CheckoutExtras extras = CheckoutExtras.none]) async {
    if (state is CheckoutPlacing || state is CheckoutPlaced) return;
    final userId = _cartCubit.userId;
    final cart = _cartCubit.state.cart;
    if (userId == null || cart.isEmpty) return;

    final totals = CheckoutTotals.of(cart.summary, extras);
    emit(const CheckoutPlacing());
    final result = await _placeOrder(userId: userId, cart: cart);
    await result.fold(
      onFailure: (failure) async => emit(CheckoutFailed(failure)),
      onSuccess: (receipt) async {
        // Keep a record of what was ordered, then empty the cart.
        await _ordersCubit.record(
          PlacedOrder(
            id: receipt.orderId,
            placedAt: receipt.placedAt,
            items: cart.items,
            couponCode: totals.hasCoupon ? totals.coupon?.code : null,
            couponDiscount: totals.couponDiscount,
            donation: totals.donation,
          ),
        );
        await _cartCubit.clear();
        emit(CheckoutPlaced(receipt.withTotals(totals)));
      },
    );
  }
}
