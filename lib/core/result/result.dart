import 'package:shopsphere/core/error/failures.dart';

/// The outcome of an operation that can fail.
///
/// Domain and data code return a [Result] instead of throwing, so the compiler forces every
/// caller to deal with both outcomes.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = Fail<T>;

  /// Collapses both outcomes into one value.
  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Fail<T>(:final failure) => onFailure(failure),
    };
  }

  /// Transforms the value of a success and passes a failure through untouched.
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Result.success(transform(value)),
      Fail<T>(:final failure) => Result.failure(failure),
    };
  }

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Fail<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Fail<T>(:final failure) => failure,
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Fail<T> extends Result<T> {
  const Fail(this.failure);

  final Failure failure;
}
