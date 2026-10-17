import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/entities/product_query.dart';

/// A product as DummyJSON sends it, and as it is cached on the device.
///
/// The list endpoint is asked for a handful of fields (`select=`), the details endpoint returns
/// everything, so almost every field except the basics is optional here.
class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json.integer('id'),
      title: json.string('title'),
      description: json.stringOrNull('description') ?? '',
      category: json.stringOrNull('category') ?? '',
      brand: json.stringOrNull('brand'),
      price: json.decimal('price'),
      discountPercentage: json.decimalOr('discountPercentage', 0),
      rating: json.decimalOr('rating', 0),
      stock: json.integerOr('stock', 0),
      thumbnail: json.stringOrNull('thumbnail') ?? '',
      images: json.strings('images'),
      tags: json.strings('tags'),
      reviews: json.objects('reviews', ReviewModel.fromJson),
      sku: json.stringOrNull('sku'),
      weight: json.decimalOrNull('weight'),
      warrantyInformation: json.stringOrNull('warrantyInformation'),
      shippingInformation: json.stringOrNull('shippingInformation'),
      returnPolicy: json.stringOrNull('returnPolicy'),
      availabilityStatus: json.stringOrNull('availabilityStatus') ?? '',
      minimumOrderQuantity: json.integerOr('minimumOrderQuantity', 1),
    );
  }

  final int id;
  final String title;
  final String description;
  final String category;
  final String? brand;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;
  final List<ReviewModel> reviews;
  final String? sku;
  final double? weight;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? returnPolicy;
  final String availabilityStatus;
  final int minimumOrderQuantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'brand': brand,
    'price': price,
    'discountPercentage': discountPercentage,
    'rating': rating,
    'stock': stock,
    'thumbnail': thumbnail,
    'images': images,
    'tags': tags,
    'reviews': [for (final review in reviews) review.toJson()],
    'sku': sku,
    'weight': weight,
    'warrantyInformation': warrantyInformation,
    'shippingInformation': shippingInformation,
    'returnPolicy': returnPolicy,
    'availabilityStatus': availabilityStatus,
    'minimumOrderQuantity': minimumOrderQuantity,
  };

  Product toEntity() => Product(
    id: id,
    title: title,
    description: description,
    category: category,
    brand: brand,
    price: price,
    discountPercentage: discountPercentage,
    rating: rating,
    stock: stock,
    thumbnail: thumbnail,
    images: images,
    tags: tags,
    reviews: [for (final review in reviews) review.toEntity()],
    sku: sku,
    weight: weight,
    warrantyInformation: warrantyInformation,
    shippingInformation: shippingInformation,
    returnPolicy: returnPolicy,
    availabilityStatus: availabilityStatus,
    minimumOrderQuantity: minimumOrderQuantity,
  );
}

class ReviewModel {
  const ReviewModel({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    rating: json.integerOr('rating', 0),
    comment: json.stringOrNull('comment') ?? '',
    reviewerName: json.stringOrNull('reviewerName') ?? '',
    date: DateTime.tryParse(json.stringOrNull('date') ?? ''),
  );

  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'comment': comment,
    'reviewerName': reviewerName,
    'date': date?.toIso8601String(),
  };

  Review toEntity() => Review(
    rating: rating,
    comment: comment,
    reviewerName: reviewerName,
    date: date,
  );
}

class CategoryModel {
  const CategoryModel({required this.slug, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    slug: json.string('slug'),
    name: json.stringOrNull('name') ?? json.string('slug'),
  );

  final String slug;
  final String name;

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name};

  ProductCategory toEntity() => ProductCategory(slug: slug, name: name);
}

/// A page of products with the paging figures the API reports alongside it.
class ProductPageModel {
  const ProductPageModel({
    required this.products,
    required this.total,
    required this.skip,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    return ProductPageModel(
      products: json.objects('products', ProductModel.fromJson),
      total: json.integer('total'),
      skip: json.integerOr('skip', 0),
    );
  }

  final List<ProductModel> products;
  final int total;
  final int skip;

  Map<String, dynamic> toJson() => {
    'products': [for (final product in products) product.toJson()],
    'total': total,
    'skip': skip,
  };

  ProductPage toEntity({bool fromCache = false}) => ProductPage(
    items: [for (final product in products) product.toEntity()],
    total: total,
    skip: skip,
    fromCache: fromCache,
  );
}
