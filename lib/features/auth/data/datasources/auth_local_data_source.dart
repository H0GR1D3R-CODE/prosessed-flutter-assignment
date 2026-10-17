import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

/// Tokens and the cached user, in the platform's secure storage (Keystore on Android).
///
/// It is also the [TokenStore] the network layer reads tokens from.
abstract interface class AuthLocalDataSource implements TokenStore {
  Future<UserModel?> readUser();
  Future<void> saveUser(UserModel user);
}

class SecureAuthLocalDataSource implements AuthLocalDataSource {
  const SecureAuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  @override
  Future<String?> readAccessToken() => _read(_accessKey);

  @override
  Future<String?> readRefreshToken() => _read(_refreshKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _write(_accessKey, accessToken);
    await _write(_refreshKey, refreshToken);
  }

  @override
  Future<UserModel?> readUser() async {
    final raw = await _read(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(asJsonMap(jsonDecode(raw)));
    } on Object {
      // A damaged cache is not worth failing over: treat it as empty.
      await _storage.delete(key: _userKey);
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) =>
      _write(_userKey, jsonEncode(user.toJson()));

  @override
  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
      await _storage.delete(key: _userKey);
    } on Exception catch (error) {
      throw CacheException(error.toString());
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on Exception catch (error) {
      throw CacheException(error.toString());
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on Exception catch (error) {
      throw CacheException(error.toString());
    }
  }
}
