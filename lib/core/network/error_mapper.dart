import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';

/// Turns a [DioException] into the app's own [AppException] hierarchy.
AppException mapDioException(DioException error) {
  final wrapped = error.error;
  if (wrapped is AppException) return wrapped;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return RequestTimeoutException(
        _timeoutDetail('connect', error.requestOptions.connectTimeout),
      );
    case DioExceptionType.sendTimeout:
      return RequestTimeoutException(
        _timeoutDetail('send', error.requestOptions.sendTimeout),
      );
    case DioExceptionType.receiveTimeout:
      return RequestTimeoutException(
        _timeoutDetail('receive', error.requestOptions.receiveTimeout),
      );
    case DioExceptionType.transformTimeout:
      return const RequestTimeoutException(
        'Reading the response took too long',
      );
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return NetworkException(error.message);
    case DioExceptionType.cancel:
      return const NetworkException('The request was cancelled.');
    case DioExceptionType.badResponse:
      return _fromStatus(error.response);
    case DioExceptionType.unknown:
      if (wrapped is FormatException) return ParseException(wrapped.message);
      // On the web, a failed XHR (offline, blocked) surfaces as an unknown error.
      return NetworkException(error.message ?? wrapped?.toString());
  }
}

/// A short technical note such as "No response within 2 s (receive timeout)", in place of Dio's
/// long advice about raising the limit.
String _timeoutDetail(String phase, Duration? limit) {
  final seconds = limit == null
      ? null
      : (limit.inMilliseconds / 1000).toStringAsFixed(
          limit.inMilliseconds % 1000 == 0 ? 0 : 1,
        );
  return seconds == null
      ? 'Timed out ($phase timeout)'
      : 'No response within $seconds s ($phase timeout)';
}

AppException _fromStatus(Response<Object?>? response) {
  final status = response?.statusCode;
  final message = _messageFrom(response?.data);
  return switch (status) {
    400 => BadRequestException(message),
    401 || 403 => UnauthorizedException(statusCode: status, message: message),
    404 => NotFoundException(message),
    final int code when code >= 500 => ServerException(
      statusCode: code,
      message: message,
    ),
    _ => ServerException(statusCode: status, message: message),
  };
}

/// DummyJSON reports problems as `{"message": "..."}`.
String? _messageFrom(Object? body) {
  if (body is Map<String, dynamic>) {
    final message = body['message'];
    if (message is String) return message;
  }
  return null;
}
