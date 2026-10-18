import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';

/// An order the shopper placed: what was in the cart, at the prices it had, and when.
///
/// DummyJSON only simulates orders and stores nothing, so the app keeps its own record.
class PlacedOrder extends Equatable {
  const PlacedOrder({
    required this.id,
    required this.placedAt,
    required this.items,
  });

  final int id;
  final DateTime placedAt;
  final List<CartItem> items;

  /// Subtotal, discount and total worked out the same way the cart does.
  CartSummary get summary => Cart(items).summary;

  int get itemCount => summary.itemCount;

  @override
  List<Object?> get props => [id, placedAt, items];
}

/// Placed orders on the device, newest first. Kept per signed-in user.
abstract interface class OrdersRepository {
  Future<List<PlacedOrder>> load(int userId);
  Future<void> save(int userId, List<PlacedOrder> orders);
}

/// The rule for the order list: the newest goes first, and an order is never listed twice.
abstract final class OrderHistory {
  static const int capacity = 50;

  static List<PlacedOrder> record(
    List<PlacedOrder> current,
    PlacedOrder order,
  ) => [
    order,
    for (final existing in current)
      if (existing.id != order.id) existing,
  ].take(capacity).toList();
}

class LoadOrdersUseCase {
  const LoadOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<List<PlacedOrder>> call(int userId) => _repository.load(userId);
}

/// Adds an order to the history and saves it. Returns the list as it now stands.
class RecordOrderUseCase {
  const RecordOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<List<PlacedOrder>> call({
    required int userId,
    required List<PlacedOrder> current,
    required PlacedOrder order,
  }) async {
    final updated = OrderHistory.record(current, order);
    await _repository.save(userId, updated);
    return updated;
  }
}
