import 'package:flutter_bloc/flutter_bloc.dart';

/// Which product is open in the details pane on wide screens, if any.
class SelectedProductCubit extends Cubit<int?> {
  SelectedProductCubit() : super(null);

  void select(int productId) => emit(productId);

  void clear() => emit(null);
}
