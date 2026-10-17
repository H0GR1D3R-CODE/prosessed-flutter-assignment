import 'package:dio/dio.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/network/error_mapper.dart';
import 'package:shopsphere/core/utils/json_reader.dart';

/// The only door to the network. Data sources talk to this class, never to Dio directly.
///
/// It decodes JSON, flags protected requests so the auth interceptor can attach a token, and
/// converts every transport error into an `AppException`.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, Object?>? query,
    bool authenticated = false,
    Duration? receiveTimeout,
  }) async {
    final data = await _send(
      'GET',
      path,
      query: query,
      authenticated: authenticated,
      receiveTimeout: receiveTimeout,
    );
    return asJsonMap(data, context: path);
  }

  Future<List<Object?>> getList(
    String path, {
    Map<String, Object?>? query,
  }) async {
    final data = await _send('GET', path, query: query);
    return asJsonList(data, context: path);
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? body,
    bool authenticated = false,
  }) async {
    final data = await _send(
      'POST',
      path,
      body: body,
      authenticated: authenticated,
    );
    return asJsonMap(data, context: path);
  }

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    bool authenticated = false,
    Duration? receiveTimeout,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          receiveTimeout: receiveTimeout,
          extra: {AuthInterceptor.requiresAuthKey: authenticated},
        ),
      );
      return response.data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
