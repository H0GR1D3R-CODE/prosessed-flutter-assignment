import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/wishlist/domain/wishlist.dart';

class WishlistState extends Equatable {
  const WishlistState({this.items = const [], this.loaded = false});

  final List<Product> items;

  /// The saved list has been read from the device.
  final bool loaded;

  bool contains(int productId) => items.any((item) => item.id == productId);

  @override
  List<Object?> get props => [items, loaded];
}

/// The products a user has saved, shared by every heart button and the Saved tab.
class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({required this._load, required this._toggle})
    : super(const WishlistState());

  final LoadWishlistUseCase _load;
  final ToggleWishlistUseCase _toggle;
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    final result = await _load(userId);
    if (_userId != userId) return;
    emit(WishlistState(items: result.valueOrNull ?? const [], loaded: true));
  }

  void unload() {
    _userId = null;
    emit(const WishlistState());
  }

  Future<void> toggle(Product product) async {
    final userId = _userId;
    if (userId == null) return;
    final change = await _toggle(
      userId: userId,
      items: state.items,
      product: product,
    );
    emit(WishlistState(items: change.items, loaded: true));
  }
}
