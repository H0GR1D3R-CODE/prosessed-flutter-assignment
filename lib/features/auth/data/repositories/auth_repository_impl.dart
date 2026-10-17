import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/guard.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this._remote, required this._local});

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<User>> login({
    required String username,
    required String password,
  }) async {
    final result = await guard(() async {
      final response = await _remote.login(
        username: username,
        password: password,
      );
      await _local.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _local.saveUser(response.user);
      return response.user.toEntity();
    });

    // The sign-in endpoint answers 400 "Invalid credentials" for a wrong username or password.
    return switch (result) {
      Fail(failure: BadRequestFailure(:final detail)) => Result.failure(
        InvalidCredentialsFailure(detail),
      ),
      _ => result,
    };
  }

  @override
  Future<Result<User>> fetchCurrentUser() {
    return guard(() async {
      final model = await _remote.me();
      await _local.saveUser(model);
      return model.toEntity();
    });
  }

  @override
  Future<User?> cachedUser() async {
    try {
      return (await _local.readUser())?.toEntity();
    } on AppException {
      return null;
    }
  }

  @override
  Future<bool> hasSession() async {
    try {
      return await _local.readRefreshToken() != null;
    } on AppException {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _local.clear();
    } on AppException {
      // Nothing more can be done: the next launch will find no usable session or fail safely.
    }
  }
}
