import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/api_config.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/core/utils/json_reader.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> me();

  /// Exchanges a refresh token for a new pair. Uses a client without the auth interceptor.
  Future<TokenPair> refresh(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this._client,
    required this._plainClient,
  });

  final ApiClient _client;

  /// The refresh call must never pass through the auth interceptor, or a rejected refresh
  /// would try to refresh itself.
  final ApiClient _plainClient;

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final json = await _client.postMap(
      Endpoints.login,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': ApiConfig.tokenLifetimeMinutes,
      },
    );
    return LoginResponseModel.fromJson(json);
  }

  @override
  Future<UserModel> me() async {
    final json = await _client.getMap(Endpoints.me, authenticated: true);
    return UserModel.fromJson(json);
  }

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    final json = await _plainClient.postMap(
      Endpoints.refresh,
      body: {
        'refreshToken': refreshToken,
        'expiresInMins': ApiConfig.tokenLifetimeMinutes,
      },
    );
    return TokenPair(
      accessToken: json.string('accessToken'),
      refreshToken: json.string('refreshToken'),
    );
  }
}
