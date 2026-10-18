import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/injection.dart';

import 'fake_adapter.dart';
import 'fixtures.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// A secure storage that lives in memory, so tokens "stored" by the app can be inspected.
FlutterSecureStorage memorySecureStorage(Map<String, String> values) {
  final storage = _MockSecureStorage();
  when(() => storage.read(key: any(named: 'key'))).thenAnswer(
    (invocation) async => values[invocation.namedArguments[#key] as String],
  );
  when(
    () => storage.write(
      key: any(named: 'key'),
      value: any(named: 'value'),
    ),
  ).thenAnswer((invocation) async {
    values[invocation.namedArguments[#key] as String] =
        invocation.namedArguments[#value] as String;
  });
  when(() => storage.delete(key: any(named: 'key')))
      .thenAnswer((invocation) async {
        values.remove(invocation.namedArguments[#key] as String);
      });
  return storage;
}

/// A scripted DummyJSON: answers from the saved fixtures, and can be told to misbehave.
class FakeShopApi {
  /// Everything asked of the server, in order.
  final List<RequestOptions> requests = [];

  /// When true every request fails as if the phone had no connection.
  bool offline = false;

  /// Status for the product list; anything but 200 returns an error body.
  int productListStatus = 200;

  /// Status for `/auth/me`.
  int meStatus = 200;

  /// Status for `/auth/refresh`.
  int refreshStatus = 200;

  /// Edits the product shown on the details page (for example to sell it out).
  Map<String, dynamic> Function(Map<String, dynamic> product)? editProduct;

  Iterable<RequestOptions> to(String path) =>
      requests.where((request) => request.path == path);

  Future<ResponseBody> handle(RequestOptions options) async {
    requests.add(options);
    if (offline) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }
    final path = options.path;
    final query = options.queryParameters;
    final delay = query['delay'];
    if (delay != null) {
      final wait = Duration(milliseconds: int.parse('$delay'));
      final limit = options.receiveTimeout;
      // A real connection enforces the receive timeout; a scripted one has to do it here.
      if (limit != null && wait > limit) {
        await Future<void>.delayed(limit);
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        );
      }
      await Future<void>.delayed(wait);
    }

    if (path == '/auth/login') {
      final body = options.data as Map<String, dynamic>;
      return body['username'] == 'emilys' && body['password'] == 'emilyspass'
          ? FakeAdapter.json(200, fixtureJson('login_ok'))
          : FakeAdapter.json(400, fixtureJson('invalid_credentials'));
    }
    if (path == '/auth/me') {
      final bearer = '${options.headers['Authorization']}';
      final valid = {'Bearer fake-access-token', 'Bearer new-access-token'};
      if (meStatus == 200 && valid.contains(bearer)) {
        return FakeAdapter.json(200, fixtureJson('me'));
      }
      // Like the real server: a token shaped like a JWT but not valid is a 500, not a 401.
      if (meStatus == 200 && bearer.substring('Bearer '.length).contains('.')) {
        return FakeAdapter.json(500, {'message': 'invalid token'});
      }
      return FakeAdapter.json(meStatus == 200 ? 401 : meStatus, {
        'message': 'Invalid/Expired Token!',
      });
    }
    if (path == '/auth/refresh') {
      final body = options.data as Map<String, dynamic>;
      final accepted =
          refreshStatus == 200 && body['refreshToken'] == 'fake-refresh-token';
      return accepted
          ? FakeAdapter.json(200, fixtureJson('refresh_ok'))
          : FakeAdapter.json(refreshStatus == 200 ? 403 : refreshStatus, {
              'message': 'Invalid refresh token',
            });
    }
    if (path == '/products/categories') {
      return FakeAdapter.json(200, fixtureJson('categories'));
    }
    if (path == '/products/search') {
      return FakeAdapter.json(200, fixtureJson('search_phone'));
    }
    if (path == '/products' || path.startsWith('/products/category/')) {
      if (productListStatus != 200) {
        return FakeAdapter.json(productListStatus, {'message': 'Boom'});
      }
      final page = Map<String, dynamic>.from(fixtureMap('products_list_page'));
      final skip = int.tryParse('${query['skip'] ?? 0}') ?? 0;
      return FakeAdapter.json(
        200,
        skip == 0 ? page : {...page, 'products': <Object?>[], 'skip': skip},
      );
    }
    if (path == '/products/1') {
      final product = fixtureMap('product_details');
      return FakeAdapter.json(200, editProduct?.call(product) ?? product);
    }
    if (path.startsWith('/products/')) {
      return FakeAdapter.json(404, fixtureJson('product_not_found'));
    }
    if (path == '/carts/add') {
      return FakeAdapter.json(200, fixtureJson('carts_add'));
    }
    if (path == '/http/500') {
      return FakeAdapter.json(500, {'message': 'Server error'});
    }
    return FakeAdapter.json(404, {'message': 'Not found: $path'});
  }
}

/// Tokens as the app stores them after a sign-in.
const Map<String, String> signedInStorage = {
  'access_token': 'fake-access-token',
  'refresh_token': 'fake-refresh-token',
};

/// Mounts the real app (real router, real DI) against [api].
///
/// Pass [secure] to start with a stored session. Returns the live secure storage, so a test
/// can check what the app kept or wiped. The app is torn down after the test.
Future<Map<String, String>> pumpShopApp(
  WidgetTester tester,
  FakeShopApi api, {
  Map<String, String>? secure,
  Map<String, Object> preferences = const {},
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await sl.reset();
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  final storage = {...?secure};
  SharedPreferences.setMockInitialValues(preferences);
  await configureDependencies(
    preferences: await SharedPreferences.getInstance(),
    secureStorage: memorySecureStorage(storage),
    httpAdapter: FakeAdapter(api.handle),
    logRequests: false,
  );
  await tester.pumpWidget(const ShopSphereApp());
  await settle(tester, const Duration(milliseconds: 2500));
  return storage;
}

/// Lets timers, requests and transitions run. `pumpAndSettle` cannot be used because the
/// app's decorative orbit animations never stop.
Future<void> settle(
  WidgetTester tester, [
  Duration total = const Duration(milliseconds: 800),
]) async {
  const step = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < total; elapsed += step) {
    await tester.pump(step);
  }
}
