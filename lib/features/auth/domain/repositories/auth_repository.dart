import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

/// What the rest of the app may ask of authentication. Pure Dart: the data layer decides how.
abstract interface class AuthRepository {
  /// Signs in and stores the session tokens. Wrong credentials give `InvalidCredentialsFailure`.
  Future<Result<User>> login({
    required String username,
    required String password,
  });

  /// The signed-in user from the server. Falls back to nothing: callers decide what offline means.
  Future<Result<User>> fetchCurrentUser();

  /// The user saved on this device by the last successful sign-in or fetch, if any.
  Future<User?> cachedUser();

  /// Whether tokens are stored (says nothing about whether they are still valid).
  Future<bool> hasSession();

  /// Forgets the tokens and the cached user.
  Future<void> logout();
}
