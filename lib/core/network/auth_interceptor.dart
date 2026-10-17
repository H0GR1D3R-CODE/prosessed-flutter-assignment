import 'package:dio/dio.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/error_mapper.dart';
import 'package:shopsphere/core/network/session.dart';

/// Attaches the Bearer token to protected requests and heals an expired one.
///
/// When a protected request comes back 401 the interceptor exchanges the refresh token for a
/// new pair and replays the request once. If the server refuses the refresh (403) the
/// session is over: [SessionEvents.expire] is fired and the original error is passed on.
///
/// It extends [QueuedInterceptor], so while one request is refreshing, other failing
/// requests wait their turn and reuse the fresh token instead of refreshing again.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this._store,
    required this._refresh,
    required this._events,
    required this._replay,
  });

  /// Set to `true` in `RequestOptions.extra` for requests that need a token.
  static const String requiresAuthKey = 'requiresAuth';
  static const String _sentTokenKey = 'sentToken';
  static const String _replayedKey = 'replayed';

  final TokenStore _store;
  final TokenRefresher _refresh;
  final SessionEvents _events;

  /// A plain client without interceptors, used to replay a request after a refresh.
  /// Replaying through the main client would wait on this very (queued) interceptor.
  final Dio _replay;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[requiresAuthKey] == true) {
      final token = await _store.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra[_sentTokenKey] = token;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isExpiredToken =
        err.response?.statusCode == 401 &&
        request.extra[requiresAuthKey] == true &&
        request.extra[_replayedKey] != true;
    if (!isExpiredToken) return handler.next(err);

    final String? token;
    try {
      token = await _freshToken(
        sentWith: request.extra[_sentTokenKey] as String?,
      );
    } on UnauthorizedException {
      _events.expire();
      return handler.next(err);
    } on AppException catch (error) {
      // The refresh could not even be attempted (offline, timeout): report that, and keep the session.
      return handler.reject(
        DioException(requestOptions: request, error: error),
      );
    }

    if (token == null) {
      _events.expire();
      return handler.next(err);
    }

    request.headers['Authorization'] = 'Bearer $token';
    request.extra[_replayedKey] = true;
    try {
      handler.resolve(await _replay.fetch<Object?>(request));
    } on DioException catch (error) {
      handler.reject(
        DioException(requestOptions: request, error: mapDioException(error)),
      );
    }
  }

  /// A usable access token, refreshing only if nobody else already has.
  Future<String?> _freshToken({required String? sentWith}) async {
    final current = await _store.readAccessToken();
    if (current != null && current != sentWith) return current;

    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) return null;

    final pair = await _refresh(refreshToken);
    await _store.saveTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );
    return pair.accessToken;
  }
}
