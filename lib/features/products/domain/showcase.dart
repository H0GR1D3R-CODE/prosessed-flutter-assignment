import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Which of the loaded products the home page puts on its shelves. Pure rules, so they can be
/// tested without a screen: the shelves are built from products already on the device, which
/// keeps the home page free of extra requests.
abstract final class Showcase {
  /// A shelf holds at most this many products.
  static const int shelfSize = 8;

  /// A shelf with fewer products than this looks sparse, so it is left out.
  static const int minimumShelf = 3;

  /// The biggest discounts first, among products that can be bought. Ties keep list order.
  static List<Product> deals(List<Product> products) {
    final candidates = [
      for (final product in products)
        if (product.isAvailable && product.hasDiscount) product,
    ];
    return _best(candidates, (a, b) {
      return b.discountPercentage.compareTo(a.discountPercentage);
    });
  }

  /// The best rated first, among products that can be bought. Ties keep list order.
  static List<Product> topRated(List<Product> products) {
    final candidates = [
      for (final product in products)
        if (product.isAvailable && product.rating >= 4) product,
    ];
    return _best(candidates, (a, b) => b.rating.compareTo(a.rating));
  }

  /// `Iterable.sort` is not stable, so the list position breaks ties explicitly.
  static List<Product> _best(
    List<Product> candidates,
    int Function(Product a, Product b) compare,
  ) {
    final indexed = [
      for (var i = 0; i < candidates.length; i++) (i, candidates[i]),
    ];
    indexed.sort((a, b) {
      final byScore = compare(a.$2, b.$2);
      return byScore != 0 ? byScore : a.$1.compareTo(b.$1);
    });
    return [for (final entry in indexed.take(shelfSize)) entry.$2];
  }

  /// Whether a shelf is worth showing.
  static bool worthShowing(List<Product> shelf) => shelf.length >= minimumShelf;
}
