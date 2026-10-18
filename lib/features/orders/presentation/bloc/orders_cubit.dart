import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/orders/domain/orders.dart';

class OrdersState extends Equatable {
  const OrdersState({this.orders = const [], this.loaded = false});

  final List<PlacedOrder> orders;

  /// The saved list has been read from the device.
  final bool loaded;

  @override
  List<Object?> get props => [orders, loaded];
}

/// The orders whoever is signed in has placed. Loaded on sign-in, put away on sign-out.
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required this._load, required this._record})
    : super(const OrdersState());

  final LoadOrdersUseCase _load;
  final RecordOrderUseCase _record;
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    final orders = await _load(userId);
    if (_userId != userId) return;
    emit(OrdersState(orders: orders, loaded: true));
  }

  void unload() {
    _userId = null;
    emit(const OrdersState());
  }

  Future<void> record(PlacedOrder order) async {
    final userId = _userId;
    if (userId == null) return;
    final orders = await _record(
      userId: userId,
      current: state.orders,
      order: order,
    );
    if (_userId == userId) emit(OrdersState(orders: orders, loaded: true));
  }
}
