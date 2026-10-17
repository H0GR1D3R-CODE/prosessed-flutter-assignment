import 'package:shopsphere/core/error/exceptions.dart';

/// Casts a decoded JSON value to an object, or throws a [ParseException].
Map<String, dynamic> asJsonMap(Object? raw, {String context = 'response'}) {
  if (raw is Map<String, dynamic>) return raw;
  throw ParseException('Expected a JSON object for $context, got ${raw.runtimeType}');
}

/// Casts a decoded JSON value to a list, or throws a [ParseException].
List<Object?> asJsonList(Object? raw, {String context = 'response'}) {
  if (raw is List<Object?>) return raw;
  throw ParseException('Expected a JSON array for $context, got ${raw.runtimeType}');
}

/// Typed, null-aware access to a decoded JSON object.
///
/// Required getters throw a [ParseException] that names the offending key, so a bad
/// response turns into a precise `ParseFailure` instead of a stray `TypeError`.
extension JsonReader on Map<String, dynamic> {
  String string(String key) {
    final value = this[key];
    if (value is String) return value;
    throw ParseException('"$key" should be a string, got ${value.runtimeType}');
  }

  String? stringOrNull(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  int integer(String key) {
    final value = this[key];
    if (value is num) return value.toInt();
    throw ParseException('"$key" should be a number, got ${value.runtimeType}');
  }

  int integerOr(String key, int fallback) {
    final value = this[key];
    return value is num ? value.toInt() : fallback;
  }

  double decimal(String key) {
    final value = this[key];
    if (value is num) return value.toDouble();
    throw ParseException('"$key" should be a number, got ${value.runtimeType}');
  }

  double decimalOr(String key, double fallback) {
    final value = this[key];
    return value is num ? value.toDouble() : fallback;
  }

  double? decimalOrNull(String key) {
    final value = this[key];
    return value is num ? value.toDouble() : null;
  }

  Map<String, dynamic>? mapOrNull(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }

  /// Parses a list of objects; a missing key is an empty list.
  List<T> objects<T>(String key, T Function(Map<String, dynamic> json) parse) {
    final value = this[key];
    if (value == null) return const [];
    if (value is! List<Object?>) {
      throw ParseException('"$key" should be a list, got ${value.runtimeType}');
    }
    return [for (final item in value) parse(asJsonMap(item, context: key))];
  }

  /// A list of strings; a missing key is an empty list.
  List<String> strings(String key) {
    final value = this[key];
    if (value == null) return const [];
    if (value is! List<Object?>) {
      throw ParseException('"$key" should be a list, got ${value.runtimeType}');
    }
    return [for (final item in value) if (item is String) item];
  }
}
