/// Low-level errors thrown by the data layer.
///
/// Data sources throw these; repositories catch them and return a typed `Failure` instead
/// (see `guard.dart`), so exceptions never travel past the data layer.
sealed class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  @override
  String toString() => '$runtimeType${message == null ? '' : ': $message'}';
}

/// No connection to the server.
final class NetworkException extends AppException {
  const NetworkException([super.message]);
}

/// Connect, send or receive timeout.
final class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message]);
}

/// HTTP 5xx.
final class ServerException extends AppException {
  const ServerException({this.statusCode, String? message}) : super(message);

  final int? statusCode;
}

/// HTTP 404.
final class NotFoundException extends AppException {
  const NotFoundException([super.message]);
}

/// HTTP 400.
final class BadRequestException extends AppException {
  const BadRequestException([super.message]);
}

/// HTTP 401 or 403 on a protected request.
final class UnauthorizedException extends AppException {
  const UnauthorizedException({this.statusCode, String? message})
    : super(message);

  final int? statusCode;
}

/// The response body was not what the model expected.
final class ParseException extends AppException {
  const ParseException([super.message]);
}

/// Local storage failure.
final class CacheException extends AppException {
  const CacheException([super.message]);
}
