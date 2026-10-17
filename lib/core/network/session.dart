import 'dart:async';

/// Where the access and refresh tokens live. Implemented with secure storage in the auth
/// data layer; the network layer only knows this interface.
abstract interface class TokenStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clear();
}

/// A matching pair of tokens, as returned by sign-in and by token refresh.
final class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

/// Exchanges a refresh token for a new pair. Throws an `AppException` when the server
/// rejects it (403) or the network fails.
typedef TokenRefresher = Future<TokenPair> Function(String refreshToken);

/// Announces that the session can no longer be used (a 401 that could not be refreshed, or a
/// refresh token the server rejected). The auth cubit listens and signs the user out.
final class SessionEvents {
  final StreamController<void> _expired = StreamController<void>.broadcast();

  Stream<void> get onExpired => _expired.stream;

  void expire() {
    if (!_expired.isClosed) _expired.add(null);
  }

  Future<void> dispose() => _expired.close();
}
