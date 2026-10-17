import 'package:equatable/equatable.dart';

/// Something for sale. The same entity serves list cards (a handful of fields) and the details
/// page (everything), so the optional fields are simply empty on a list item.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    this.description = '',
    this.brand,
    this.images = const [],
    this.tags = const [],
    this.reviews = const [],
    this.sku,
    this.weight,
    this.warrantyInformation,
    this.shippingInformation,
    this.returnPolicy,
    this.availabilityStatus = '',
    this.minimumOrderQuantity = 1,
  });

  final int id;
  final String title;
  final String description;

  /// The category slug, e.g. `mens-shirts`.
  final String category;

  /// Absent on many products, so never assume it exists.
  final String? brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<Review> reviews;
  final String? sku;
  final double? weight;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;
  final String availabilityStatus;
  final int minimumOrderQuantity;

  /// Whole percentages below 1 are noise: show no discount for them.
  bool get hasDiscount => discountPercentage >= 1;

  /// The price after discount, rounded to cents.
  double get discountedPrice {
    final value = price * (100 - discountPercentage) / 100;
    return (value * 100).round() / 100;
  }

  /// What the discount takes off a single unit.
  double get savingPerUnit => price - discountedPrice;

  /// Can be added to a cart.
  bool get isAvailable => stock > 0 && availabilityStatus != 'Out of Stock';

  /// The photos to show, falling back to the thumbnail.
  List<String> get gallery => images.isEmpty ? [thumbnail] : images;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    brand,
    price,
    discountPercentage,
    rating,
    stock,
    thumbnail,
    images,
    tags,
    reviews,
    sku,
    weight,
    warrantyInformation,
    shippingInformation,
    returnPolicy,
    availabilityStatus,
    minimumOrderQuantity,
  ];
}

/// One customer review.
class Review extends Equatable {
  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  @override
  List<Object?> get props => [rating, comment, reviewerName, date];
}

/// A product category as the API lists it.
class ProductCategory extends Equatable {
  const ProductCategory({required this.slug, required this.name});

  final String slug;
  final String name;

  @override
  List<Object?> get props => [slug, name];
}
