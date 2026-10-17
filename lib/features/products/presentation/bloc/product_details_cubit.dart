import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsLoaded extends ProductDetailsState {
  const ProductDetailsLoaded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

/// Includes a product that does not exist (`NotFoundFailure`).
final class ProductDetailsFailure extends ProductDetailsState {
  const ProductDetailsFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads one product with its photos and reviews.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({required this.productId, required this._getProduct})
    : super(const ProductDetailsLoading());

  final int productId;
  final GetProductDetailsUseCase _getProduct;

  Future<void> load() async {
    emit(const ProductDetailsLoading());
    final result = await _getProduct(productId);
    result.fold(
      onFailure: (failure) => emit(ProductDetailsFailure(failure)),
      onSuccess: (product) => emit(ProductDetailsLoaded(product)),
    );
  }
}
