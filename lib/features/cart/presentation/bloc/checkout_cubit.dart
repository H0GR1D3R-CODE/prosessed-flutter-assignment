import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/bloc/cart_cubit.dart';

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

/// Places the order for the current cart and empties the cart once the server accepts it.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required this._placeOrder, required this._cartCubit})
    : super(const CheckoutReview());

  final PlaceOrderUseCase _placeOrder;
  final CartCubit _cartCubit;

  Future<void> placeOrder() async {
    if (state is CheckoutPlacing || state is CheckoutPlaced) return;
    final userId = _cartCubit.userId;
    final cart = _cartCubit.state.cart;
    if (userId == null || cart.isEmpty) return;

    emit(const CheckoutPlacing());
    final result = await _placeOrder(userId: userId, cart: cart);
    await result.fold(
      onFailure: (failure) async => emit(CheckoutFailed(failure)),
      onSuccess: (receipt) async {
        await _cartCubit.clear();
        emit(CheckoutPlaced(receipt));
      },
    );
  }
}
