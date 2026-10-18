import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';

void main() {
  group('guard', () {
    test('wraps a value in a success', () async {
      final result = await guard(() async => 42);
      expect(result.valueOrNull, 42);
      expect(result.isSuccess, isTrue);
    });

    test('turns each AppException into its failure', () async {
      final cases = <AppException, Matcher>{
        const NetworkException('offline'): isA<NetworkFailure>(),
        const RequestTimeoutException(): isA<TimeoutFailure>(),
        const ServerException(statusCode: 503): isA<ServerFailure>().having(
          (f) => f.statusCode,
          'statusCode',
          503,
        ),
        const NotFoundException(): isA<NotFoundFailure>(),
        const BadRequestException(): isA<BadRequestFailure>(),
        const UnauthorizedException(statusCode: 401):
            isA<SessionExpiredFailure>(),
        const ParseException('bad'): isA<ParseFailure>(),
        const CacheException(): isA<CacheFailure>(),
      };
      for (final entry in cases.entries) {
        final result = await guard<void>(() async => throw entry.key);
        expect(result.failureOrNull, entry.value, reason: '${entry.key}');
      }
    });

    test('a stray FormatException or TypeError becomes a ParseFailure', () async {
      final format = await guard<void>(
        () async => throw const FormatException('x'),
      );
      final type = await guard<void>(() async {
        final Object value = 'text';
        (value as int).toString();
      });
      expect(format.failureOrNull, isA<ParseFailure>());
      expect(type.failureOrNull, isA<ParseFailure>());
    });

    test('anything else is an UnknownFailure carrying its description', () async {
      final result = await guard<void>(() async => throw Exception('boom'));
      expect(result.failureOrNull, isA<UnknownFailure>());
      expect(result.failureOrNull!.detail, contains('boom'));
    });
  });

  group('Result', () {
    test('fold picks the matching branch', () {
      const ok = Result<int>.success(2);
      const bad = Result<int>.failure(NetworkFailure());
      expect(ok.fold(onFailure: (_) => -1, onSuccess: (v) => v * 2), 4);
      expect(bad.fold(onFailure: (_) => -1, onSuccess: (v) => v * 2), -1);
    });

    test('map transforms successes and leaves failures alone', () {
      expect(const Result<int>.success(2).map((v) => '$v').valueOrNull, '2');
      expect(
        const Result<int>.failure(
          NotFoundFailure(),
        ).map((v) => '$v').failureOrNull,
        isA<NotFoundFailure>(),
      );
    });
  });
}
