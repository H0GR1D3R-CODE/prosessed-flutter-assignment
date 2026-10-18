import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/error_mapper.dart';

DioException _bad(int status, [Object? body]) {
  final request = RequestOptions(path: '/x');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: request,
      statusCode: status,
      data: body,
    ),
  );
}

DioException _of(DioExceptionType type, {Object? error}) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: type,
  error: error,
);

void main() {
  group('mapDioException', () {
    test('timeouts of every kind become RequestTimeoutException', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapDioException(_of(type)), isA<RequestTimeoutException>());
      }
    });

    test('connection problems become NetworkException', () {
      expect(
        mapDioException(_of(DioExceptionType.connectionError)),
        isA<NetworkException>(),
      );
      expect(
        mapDioException(_of(DioExceptionType.unknown)),
        isA<NetworkException>(),
      );
    });

    test(
      'HTTP statuses map to their own exceptions and keep the server message',
      () {
        expect(
          mapDioException(_bad(400, {'message': 'Invalid credentials'})),
          isA<BadRequestException>().having(
            (e) => e.message,
            'message',
            'Invalid credentials',
          ),
        );
        expect(mapDioException(_bad(401)), isA<UnauthorizedException>());
        expect(mapDioException(_bad(403)), isA<UnauthorizedException>());
        expect(mapDioException(_bad(404)), isA<NotFoundException>());
        expect(
          mapDioException(_bad(500, {'message': 'Internal Server Error'})),
          isA<ServerException>().having((e) => e.statusCode, 'statusCode', 500),
        );
        expect(mapDioException(_bad(503)), isA<ServerException>());
      },
    );

    test('an AppException already attached is passed through', () {
      const original = ParseException('bad');
      expect(
        mapDioException(_of(DioExceptionType.unknown, error: original)),
        same(original),
      );
    });
  });
}
