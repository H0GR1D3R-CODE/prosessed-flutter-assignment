import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/cart/domain/entities/cart.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// A product with sensible defaults, so each test only states what it cares about.
Product buildProduct({
  int id = 1,
  String title = 'Test product',
  double price = 10,
  double discount = 0,
  int stock = 10,
  String category = 'beauty',
  String availability = 'In Stock',
  String? brand = 'Acme',
  double rating = 4.2,
}) {
  return Product(
    id: id,
    title: title,
    category: category,
    price: price,
    discountPercentage: discount,
    rating: rating,
    stock: stock,
    thumbnail: 'https://example.test/$id.webp',
    brand: brand,
    availabilityStatus: availability,
  );
}

CartItem buildCartItem({
  int productId = 1,
  double unitPrice = 10,
  double discount = 0,
  int quantity = 1,
  int stock = 10,
}) {
  return CartItem(
    productId: productId,
    title: 'Item $productId',
    thumbnail: 'https://example.test/$productId.webp',
    category: 'beauty',
    unitPrice: unitPrice,
    discountPercentage: discount,
    quantity: quantity,
    stock: stock,
  );
}

const User testUser = User(
  id: 1,
  username: 'emilys',
  firstName: 'Emily',
  lastName: 'Johnson',
  email: 'emily.johnson@example.test',
);
