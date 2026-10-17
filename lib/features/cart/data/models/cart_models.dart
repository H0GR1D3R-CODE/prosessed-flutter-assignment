import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/cart/domain/entities/order_receipt.dart';

/// A cart line as it is stored on the device.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.category,
    required this.unitPrice,
    required this.discountPercentage,
    required this.quantity,
    required this.stock,
  });

  factory CartItemModel.fromEntity(CartItem item) => CartItemModel(
    productId: item.productId,
    title: item.title,
    thumbnail: item.thumbnail,
    category: item.category,
    unitPrice: item.unitPrice,
    discountPercentage: item.discountPercentage,
    quantity: item.quantity,
    stock: item.stock,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    productId: json.integer('productId'),
    title: json.string('title'),
    thumbnail: json.stringOrNull('thumbnail') ?? '',
    category: json.stringOrNull('category') ?? '',
    unitPrice: json.decimal('unitPrice'),
    discountPercentage: json.decimalOr('discountPercentage', 0),
    quantity: json.integer('quantity'),
    stock: json.integerOr('stock', 99),
  );

  final int productId;
  final String title;
  final String thumbnail;
  final String category;
  final double unitPrice;
  final double discountPercentage;
  final int quantity;
  final int stock;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title': title,
    'thumbnail': thumbnail,
    'category': category,
    'unitPrice': unitPrice,
    'discountPercentage': discountPercentage,
    'quantity': quantity,
    'stock': stock,
  };

  CartItem toEntity() => CartItem(
    productId: productId,
    title: title,
    thumbnail: thumbnail,
    category: category,
    unitPrice: unitPrice,
    discountPercentage: discountPercentage,
    quantity: quantity,
    stock: stock,
  );
}

/// The reply to `POST /carts/add`.
class OrderResponseModel {
  const OrderResponseModel({required this.id, required this.totalQuantity});

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) =>
      OrderResponseModel(
        id: json.integer('id'),
        totalQuantity: json.integerOr('totalQuantity', 0),
      );

  final int id;
  final int totalQuantity;

  OrderReceipt toReceipt({required Cart cart, required DateTime placedAt}) {
    return OrderReceipt(
      orderId: id,
      // The app's own figures: the API rounds its totals to whole dollars.
      itemCount: cart.itemCount,
      total: cart.summary.total,
      placedAt: placedAt,
    );
  }
}
