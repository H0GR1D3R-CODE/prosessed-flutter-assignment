import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

final class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

final class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);

  final List<ProductCategory> categories;

  @override
  List<Object?> get props => [categories];
}

final class CategoriesFailure extends CategoriesState {
  const CategoriesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loads the category chips shown above the product grid.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._getCategories) : super(const CategoriesLoading());

  final GetCategoriesUseCase _getCategories;

  Future<void> load() async {
    emit(const CategoriesLoading());
    final result = await _getCategories();
    result.fold(
      onFailure: (failure) => emit(CategoriesFailure(failure)),
      onSuccess: (categories) => emit(CategoriesLoaded(categories)),
    );
  }
}
