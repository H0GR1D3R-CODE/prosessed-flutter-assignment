import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

/// Products the shopper has saved for later, newest first.
abstract interface class WishlistRepository {
  Future<Result<List<Product>>> load(int userId);
  Future<Result<void>> save(int userId, List<Product> items);
}

class LoadWishlistUseCase {
  const LoadWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<Result<List<Product>>> call(int userId) => _repository.load(userId);
}

/// The wishlist after a change, and whether it could be saved.
class WishlistChange {
  const WishlistChange(this.items, {this.saveFailure});

  final List<Product> items;
  final Failure? saveFailure;
}

/// Saves a product if it is not on the list yet, removes it if it is.
class ToggleWishlistUseCase {
  const ToggleWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  Future<WishlistChange> call({
    required int userId,
    required List<Product> items,
    required Product product,
  }) async {
    final exists = items.any((item) => item.id == product.id);
    final updated = exists
        ? [
            for (final item in items)
              if (item.id != product.id) item,
          ]
        : [product, ...items];
    final saved = await _repository.save(userId, updated);
    return WishlistChange(updated, saveFailure: saved.failureOrNull);
  }
}
