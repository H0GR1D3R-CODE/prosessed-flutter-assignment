import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';

/// Runs [body] and converts anything it throws into a typed [Failure].
///
/// Every repository method is written as `guard(() async { ... })`, which is what keeps
/// exceptions from leaking into blocs and widgets.
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Result.success(await body());
  } on AppException catch (error) {
    return Result.failure(error.toFailure());
  } on FormatException catch (error) {
    return Result.failure(ParseFailure(error.message));
  } on TypeError catch (error) {
    return Result.failure(ParseFailure(error.toString()));
  } on Exception catch (error) {
    return Result.failure(UnknownFailure(error.toString()));
  }
}

extension AppExceptionToFailure on AppException {
  /// The one place where data-layer exceptions become domain failures.
  Failure toFailure() {
    return switch (this) {
      NetworkException() => NetworkFailure(message),
      RequestTimeoutException() => TimeoutFailure(message),
      final ServerException e => ServerFailure(statusCode: e.statusCode, detail: message),
      NotFoundException() => NotFoundFailure(message),
      BadRequestException() => BadRequestFailure(message),
      UnauthorizedException() => SessionExpiredFailure(message),
      ParseException() => ParseFailure(message),
      CacheException() => CacheFailure(message),
    };
  }
}
