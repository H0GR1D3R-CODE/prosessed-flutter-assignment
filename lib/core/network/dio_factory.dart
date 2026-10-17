import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shopsphere/core/network/api_config.dart';

/// Builds the configured HTTP clients.
abstract final class DioFactory {
  /// A client with the app's base URL and timeouts. Interceptors are added by the caller.
  static Dio create({String baseUrl = ApiConfig.baseUrl}) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: const {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );
  }
}

/// One line per request in debug builds. Headers and bodies are never printed, because they
/// carry tokens and passwords.
class DebugLogInterceptor extends Interceptor {
  static const String _startedKey = 'startedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      err.requestOptions,
      err.response?.statusCode?.toString() ?? err.type.name,
    );
    handler.next(err);
  }

  void _log(RequestOptions options, String outcome) {
    final started = options.extra[_startedKey] as int?;
    final took = started == null
        ? ''
        : ' ${DateTime.now().millisecondsSinceEpoch - started} ms';
    debugPrint('[http] ${options.method} ${options.uri.path} -> $outcome$took');
  }
}
