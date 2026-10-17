import 'package:equatable/equatable.dart';

/// Everything that can go wrong, as the domain and UI layers see it.
///
/// Failures carry no user-facing text: the presentation layer turns each type into a
/// localised message, so the domain stays free of Flutter and of any particular language.
sealed class Failure extends Equatable {
  const Failure([this.detail]);

  /// Technical detail (for logs and the developer tools), never shown to users as-is.
  final String? detail;

  @override
  List<Object?> get props => [detail];
}

/// The device could not reach the server (offline, DNS, refused connection).
final class NetworkFailure extends Failure {
  const NetworkFailure([super.detail]);
}

/// The server took longer than the configured timeout to answer.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.detail]);
}

/// The server answered with a 5xx status.
final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, String? detail}) : super(detail);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode, detail];
}

/// The thing asked for does not exist (HTTP 404).
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.detail]);
}

/// The server rejected the request itself (HTTP 400 outside of sign-in).
final class BadRequestFailure extends Failure {
  const BadRequestFailure([super.detail]);
}

/// The username or password was wrong (HTTP 400 from the sign-in endpoint).
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.detail]);
}

/// The access token is no longer valid and could not be refreshed.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.detail]);
}

/// A response arrived but did not have the shape the app expects.
final class ParseFailure extends Failure {
  const ParseFailure([super.detail]);
}

/// Local storage could not be read or written.
final class CacheFailure extends Failure {
  const CacheFailure([super.detail]);
}

/// Anything else. Should be rare; it is logged with its detail.
final class UnknownFailure extends Failure {
  const UnknownFailure([super.detail]);
}
