import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/discover/domain/discover.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';

class SearchHistoryState extends Equatable {
  const SearchHistoryState({this.terms = const []});

  final List<String> terms;

  @override
  List<Object?> get props => [terms];
}

/// The recent searches of whoever is signed in. Loaded on sign-in, put away on sign-out.
class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  SearchHistoryCubit({
    required this._load,
    required this._record,
    required this._forget,
  }) : super(const SearchHistoryState());

  final LoadSearchHistoryUseCase _load;
  final RecordSearchUseCase _record;
  final ForgetSearchUseCase _forget;
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    final terms = await _load(userId);
    if (_userId != userId) return;
    emit(SearchHistoryState(terms: terms));
  }

  void unload() {
    _userId = null;
    emit(const SearchHistoryState());
  }

  Future<void> record(String term) async {
    final userId = _userId;
    if (userId == null) return;
    final terms = await _record(
      userId: userId,
      current: state.terms,
      term: term,
    );
    if (_userId == userId) emit(SearchHistoryState(terms: terms));
  }

  Future<void> forget(String term) async {
    final userId = _userId;
    if (userId == null) return;
    final terms = await _forget(
      userId: userId,
      current: state.terms,
      term: term,
    );
    if (_userId == userId) emit(SearchHistoryState(terms: terms));
  }

  Future<void> clear() async {
    final userId = _userId;
    if (userId == null) return;
    await _forget(userId: userId, current: state.terms);
    if (_userId == userId) emit(const SearchHistoryState());
  }
}

class RecentlyViewedState extends Equatable {
  const RecentlyViewedState({this.products = const []});

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

/// The products whoever is signed in opened lately. Loaded on sign-in, put away on sign-out.
class RecentlyViewedCubit extends Cubit<RecentlyViewedState> {
  RecentlyViewedCubit({
    required this._load,
    required this._record,
    required this._clear,
  }) : super(const RecentlyViewedState());

  final LoadRecentlyViewedUseCase _load;
  final RecordViewedUseCase _record;
  final ClearRecentlyViewedUseCase _clear;
  int? _userId;

  Future<void> load(int userId) async {
    _userId = userId;
    final products = await _load(userId);
    if (_userId != userId) return;
    emit(RecentlyViewedState(products: products));
  }

  void unload() {
    _userId = null;
    emit(const RecentlyViewedState());
  }

  Future<void> record(Product product) async {
    final userId = _userId;
    if (userId == null) return;
    final products = await _record(
      userId: userId,
      current: state.products,
      product: product,
    );
    if (_userId == userId) emit(RecentlyViewedState(products: products));
  }

  Future<void> clear() async {
    final userId = _userId;
    if (userId == null) return;
    await _clear(userId);
    if (_userId == userId) emit(const RecentlyViewedState());
  }
}
