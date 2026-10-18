import 'package:equatable/equatable.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Route paths, in one place.
abstract final class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String shop = '/shop';
  static const String saved = '/saved';
  static const String cart = '/cart';
  static const String profile = '/me';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String devTools = '/dev-tools';

  static String product(int id) => '/product/$id';
}

/// What the product page is handed when it is opened from a card: the product (so the page can
/// paint at once) and the Hero tag of the card's photo.
class ProductRouteArgs extends Equatable {
  const ProductRouteArgs({required this.product, this.heroTag});

  final Product product;
  final Object? heroTag;

  @override
  List<Object?> get props => [product, heroTag];
}
