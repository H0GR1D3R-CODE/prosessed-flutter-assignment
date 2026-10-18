import 'package:shopsphere/features/products/domain/entities/product.dart';

/// The words a shopper searched for, newest first. Kept per signed-in user.
abstract interface class SearchHistoryRepository {
  Future<List<String>> load(int userId);
  Future<void> save(int userId, List<String> terms);
}

/// The products a shopper opened lately, newest first. Kept per signed-in user.
abstract interface class RecentlyViewedRepository {
  Future<List<Product>> load(int userId);
  Future<void> save(int userId, List<Product> products);
}

/// The rules for the search list: short words are ignored, a repeat moves to the front, and
/// only the latest few are kept.
abstract final class SearchHistory {
  static const int capacity = 8;
  static const int minLength = 2;

  static List<String> record(List<String> current, String term) {
    final cleaned = term.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length < minLength) return current;
    return [
      cleaned,
      for (final existing in current)
        if (existing.toLowerCase() != cleaned.toLowerCase()) existing,
    ].take(capacity).toList();
  }

  static List<String> forget(List<String> current, String term) => [
    for (final existing in current)
      if (existing.toLowerCase() != term.toLowerCase()) existing,
  ];

  /// What to offer for [typed]: everything when nothing is typed, otherwise the words that
  /// contain it. A word identical to what is typed is not worth suggesting.
  static List<String> matching(List<String> history, String typed) {
    final query = typed.trim().toLowerCase();
    if (query.isEmpty) return history;
    return [
      for (final term in history)
        if (term.toLowerCase().contains(query) && term.toLowerCase() != query)
          term,
    ];
  }
}

/// The rules for the recently viewed list: a repeat moves to the front, and only the latest
/// few are kept.
abstract final class RecentlyViewed {
  static const int capacity = 12;

  static List<Product> record(List<Product> current, Product product) => [
    product,
    for (final existing in current)
      if (existing.id != product.id) existing,
  ].take(capacity).toList();
}

class LoadSearchHistoryUseCase {
  const LoadSearchHistoryUseCase(this._repository);

  final SearchHistoryRepository _repository;

  Future<List<String>> call(int userId) => _repository.load(userId);
}

/// Adds a word to the history and saves it. Returns the list as it now stands.
class RecordSearchUseCase {
  const RecordSearchUseCase(this._repository);

  final SearchHistoryRepository _repository;

  Future<List<String>> call({
    required int userId,
    required List<String> current,
    required String term,
  }) async {
    final updated = SearchHistory.record(current, term);
    if (!identical(updated, current)) await _repository.save(userId, updated);
    return updated;
  }
}

/// Forgets one word, or every word when [term] is null.
class ForgetSearchUseCase {
  const ForgetSearchUseCase(this._repository);

  final SearchHistoryRepository _repository;

  Future<List<String>> call({
    required int userId,
    required List<String> current,
    String? term,
  }) async {
    final updated = term == null
        ? const <String>[]
        : SearchHistory.forget(current, term);
    await _repository.save(userId, updated);
    return updated;
  }
}

class LoadRecentlyViewedUseCase {
  const LoadRecentlyViewedUseCase(this._repository);

  final RecentlyViewedRepository _repository;

  Future<List<Product>> call(int userId) => _repository.load(userId);
}

class RecordViewedUseCase {
  const RecordViewedUseCase(this._repository);

  final RecentlyViewedRepository _repository;

  Future<List<Product>> call({
    required int userId,
    required List<Product> current,
    required Product product,
  }) async {
    final updated = RecentlyViewed.record(current, product);
    await _repository.save(userId, updated);
    return updated;
  }
}

class ClearRecentlyViewedUseCase {
  const ClearRecentlyViewedUseCase(this._repository);

  final RecentlyViewedRepository _repository;

  Future<void> call(int userId) => _repository.save(userId, const []);
}
