import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/network/session.dart';

import '../../helpers/fake_adapter.dart';

class _MemoryTokens implements TokenStore {
  _MemoryTokens({this.access, this.refresh});

  String? access;
  String? refresh;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _Rig {
  _Rig({
    required this.tokens,
    required this.network,
    required Future<TokenPair> Function(String) refresh,
  }) {
    final replay = FakeAdapter(
      (o) => FakeAdapter.json(200, {
        'replayed': true,
        'auth': o.headers['Authorization'],
      }),
    );
    final Dio dio = dioWith(network)
      ..interceptors.add(
        AuthInterceptor(
          store: tokens,
          refresh: (token) {
            refreshes++;
            return refresh(token);
          },
          events: events,
          replay: dioWith(replay),
        ),
      );
    client = ApiClient(dio);
    events.onExpired.listen((_) => expired++);
  }

  final _MemoryTokens tokens;
  final FakeAdapter network;
  final SessionEvents events = SessionEvents();
  late final ApiClient client;
  int refreshes = 0;
  int expired = 0;
}

Future<TokenPair> _neverRefresh(String _) async =>
    throw StateError('no refresh expected');

void main() {
  test('protected requests carry the Bearer token; others do not', () async {
    final rig = _Rig(
      tokens: _MemoryTokens(access: 'abc', refresh: 'r'),
      network: FakeAdapter((_) => FakeAdapter.json(200, {'ok': true})),
      refresh: _neverRefresh,
    );

    await rig.client.getMap('/auth/me', authenticated: true);
    await rig.client.getMap('/products');

    expect(rig.network.requests[0].headers['Authorization'], 'Bearer abc');
    expect(
      rig.network.requests[1].headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test(
    'a 401 refreshes the token once and replays the request with the new one',
    () async {
      final tokens = _MemoryTokens(access: 'old', refresh: 'r1');
      final rig = _Rig(
        tokens: tokens,
        network: FakeAdapter(
          (_) => FakeAdapter.json(401, {'message': 'Invalid/Expired Token!'}),
        ),
        refresh: (token) async {
          expect(token, 'r1');
          return const TokenPair(accessToken: 'new', refreshToken: 'r2');
        },
      );

      final json = await rig.client.getMap('/auth/me', authenticated: true);

      expect(json['replayed'], isTrue);
      expect(json['auth'], 'Bearer new');
      expect(rig.refreshes, 1);
      expect(tokens.access, 'new');
      expect(tokens.refresh, 'r2');
    },
  );

  test(
    'a refresh the server refuses ends the session and surfaces the 401',
    () async {
      final rig = _Rig(
        tokens: _MemoryTokens(access: 'old', refresh: 'bad'),
        network: FakeAdapter(
          (_) => FakeAdapter.json(401, {'message': 'Invalid/Expired Token!'}),
        ),
        refresh: (_) async =>
            throw const UnauthorizedException(statusCode: 403),
      );

      await expectLater(
        rig.client.getMap('/auth/me', authenticated: true),
        throwsA(isA<UnauthorizedException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(rig.expired, 1);
    },
  );

  test(
    'no refresh token means the session ends without trying to refresh',
    () async {
      final rig = _Rig(
        tokens: _MemoryTokens(access: 'old'),
        network: FakeAdapter((_) => FakeAdapter.json(401, {})),
        refresh: _neverRefresh,
      );

      await expectLater(
        rig.client.getMap('/auth/me', authenticated: true),
        throwsA(isA<UnauthorizedException>()),
      );
      await Future<void>.delayed(Duration.zero);

      expect(rig.expired, 1);
      expect(rig.refreshes, 0);
    },
  );

  test('a refresh that fails for lack of network keeps the session', () async {
    final rig = _Rig(
      tokens: _MemoryTokens(access: 'old', refresh: 'r'),
      network: FakeAdapter((_) => FakeAdapter.json(401, {})),
      refresh: (_) async => throw const NetworkException('offline'),
    );

    await expectLater(
      rig.client.getMap('/auth/me', authenticated: true),
      throwsA(isA<NetworkException>()),
    );
    await Future<void>.delayed(Duration.zero);

    expect(rig.expired, 0, reason: 'being offline must not sign the user out');
  });

  test('unprotected 401s are left alone', () async {
    final rig = _Rig(
      tokens: _MemoryTokens(access: 'a', refresh: 'r'),
      network: FakeAdapter((_) => FakeAdapter.json(401, {})),
      refresh: _neverRefresh,
    );

    await expectLater(
      rig.client.getMap('/anything'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(rig.refreshes, 0);
  });

  test('simultaneous 401s share one refresh', () async {
    final rig = _Rig(
      tokens: _MemoryTokens(access: 'old', refresh: 'r1'),
      network: FakeAdapter((o) {
        // Only the stale token is rejected.
        return o.headers['Authorization'] == 'Bearer old'
            ? FakeAdapter.json(401, {})
            : FakeAdapter.json(200, {'ok': true});
      }),
      refresh: (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const TokenPair(accessToken: 'new', refreshToken: 'r2');
      },
    );

    await Future.wait([
      rig.client.getMap('/auth/me', authenticated: true),
      rig.client.getMap('/carts/add', authenticated: true),
      rig.client.getMap('/auth/me', authenticated: true),
    ]);

    expect(rig.refreshes, 1);
  });
}
