import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Money is calculated in whole cents, so a basket of 0.1 + 0.2 style prices never drifts.
int _cents(double amount) => (amount * 100).round();
double _fromCents(int cents) => cents / 100;

/// One product in the cart, frozen at the price it had when it was added.
class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.category,
    required this.unitPrice,
    required this.discountPercentage,
    required this.quantity,
    required this.stock,
  });

  factory CartItem.fromProduct(Product product, {required int quantity}) {
    return CartItem(
      productId: product.id,
      title: product.title,
      thumbnail: product.thumbnail,
      category: product.category,
      unitPrice: product.price,
      discountPercentage: product.discountPercentage,
      quantity: quantity,
      stock: product.stock,
    );
  }

  final int productId;
  final String title;
  final String thumbnail;
  final String category;

  /// Price of one unit before discount.
  final double unitPrice;
  final double discountPercentage;
  final int quantity;

  /// How many are in stock: the most that can be ordered.
  final int stock;

  bool get hasDiscount => discountPercentage >= 1;

  int get _unitCents => _cents(unitPrice);
  int get _discountedUnitCents =>
      (_unitCents * (100 - discountPercentage) / 100).round();

  double get discountedUnitPrice => _fromCents(_discountedUnitCents);

  /// What the line costs before discount.
  double get listTotal => _fromCents(_unitCents * quantity);

  /// What the line costs after discount.
  double get total => _fromCents(_discountedUnitCents * quantity);

  double get savings =>
      _fromCents(_unitCents * quantity - _discountedUnitCents * quantity);

  /// The most of this product one order may hold.
  int get maxQuantity => math.max(1, math.min(stock, Cart.maxPerLine));

  CartItem withQuantity(int value) => CartItem(
    productId: productId,
    title: title,
    thumbnail: thumbnail,
    category: category,
    unitPrice: unitPrice,
    discountPercentage: discountPercentage,
    quantity: value,
    stock: stock,
  );

  @override
  List<Object?> get props => [
    productId,
    title,
    thumbnail,
    category,
    unitPrice,
    discountPercentage,
    quantity,
    stock,
  ];
}

/// The three figures the cart and checkout show.
class CartSummary extends Equatable {
  const CartSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.itemCount,
    required this.lineCount,
  });

  static const CartSummary empty = CartSummary(
    subtotal: 0,
    discount: 0,
    total: 0,
    itemCount: 0,
    lineCount: 0,
  );

  /// Everything at list price.
  final double subtotal;

  /// How much the discounts take off.
  final double discount;

  /// What the shopper pays: `subtotal - discount`.
  final double total;

  /// Units across all lines.
  final int itemCount;
  final int lineCount;

  bool get isEmpty => lineCount == 0;

  @override
  List<Object?> get props => [subtotal, discount, total, itemCount, lineCount];
}

/// The shopping cart. Immutable: every change returns a new cart.
class Cart extends Equatable {
  const Cart([this.items = const []]);

  /// A single line never holds more than this, whatever the stock.
  static const int maxPerLine = 99;

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartItem? find(int productId) {
    for (final item in items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  CartSummary get summary {
    var subtotal = 0;
    var total = 0;
    var units = 0;
    for (final item in items) {
      subtotal += _cents(item.unitPrice) * item.quantity;
      total += item._discountedUnitCents * item.quantity;
      units += item.quantity;
    }
    return CartSummary(
      subtotal: _fromCents(subtotal),
      discount: _fromCents(subtotal - total),
      total: _fromCents(total),
      itemCount: units,
      lineCount: items.length,
    );
  }

  /// Adds [quantity] of [product], merging with an existing line and never exceeding stock.
  /// An unavailable product leaves the cart as it was.
  Cart add(Product product, {int quantity = 1}) {
    if (!product.isAvailable || quantity < 1) return this;
    final existing = find(product.id);
    final base = existing ?? CartItem.fromProduct(product, quantity: 0);
    final wanted = (existing?.quantity ?? 0) + quantity;
    final merged = base.withQuantity(math.min(wanted, base.maxQuantity));
    return existing == null
        ? Cart([...items, merged])
        : Cart([
            for (final item in items)
              item.productId == product.id ? merged : item,
          ]);
  }

  /// Sets a line's quantity, kept between 1 and the most that may be ordered.
  Cart setQuantity(int productId, int quantity) {
    final existing = find(productId);
    if (existing == null) return this;
    final clamped = quantity.clamp(1, existing.maxQuantity);
    return Cart([
      for (final item in items)
        item.productId == productId ? item.withQuantity(clamped) : item,
    ]);
  }

  Cart remove(int productId) => Cart([
    for (final item in items)
      if (item.productId != productId) item,
  ]);

  /// Puts a removed line back where it was (for "undo").
  Cart insertAt(int index, CartItem item) {
    if (find(item.productId) != null) return this;
    final list = [...items];
    list.insert(index.clamp(0, list.length), item);
    return Cart(list);
  }

  @override
  List<Object?> get props => [items];
}
