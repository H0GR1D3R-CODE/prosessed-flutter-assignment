import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

/// Signs a shopper in with a username and password.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username.trim(), password: password);
  }
}

/// Signs out and forgets everything stored for the session.
class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

/// The server's view of who is signed in.
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call() => _repository.fetchCurrentUser();
}

/// What launching the app should do about a stored session.
sealed class SessionRestore {
  const SessionRestore();
}

/// Nothing is stored: show the login screen.
final class NoSession extends SessionRestore {
  const NoSession();
}

/// Tokens exist and the server accepted them (or could not be reached and a cached user exists).
final class ActiveSession extends SessionRestore {
  const ActiveSession(this.user);

  /// May be null when the device is offline and nothing was cached.
  final User? user;
}

/// Tokens exist but the server no longer accepts them.
final class ExpiredSession extends SessionRestore {
  const ExpiredSession();
}

/// Decides, at launch, whether to go to the shop or to the login screen.
///
/// A stored token is trusted when the network is down, so an offline launch still reaches the
/// cached catalogue. A token the server rejects ends the session.
class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<SessionRestore> call() async {
    if (!await _repository.hasSession()) return const NoSession();

    final result = await _repository.fetchCurrentUser();
    return switch (result) {
      Success(:final value) => ActiveSession(value),
      Fail(:final failure) when failure is SessionExpiredFailure =>
        const ExpiredSession(),
      Fail() => ActiveSession(await _repository.cachedUser()),
    };
  }
}
