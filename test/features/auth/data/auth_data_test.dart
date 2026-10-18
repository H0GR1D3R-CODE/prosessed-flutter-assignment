import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';

import '../../../helpers/fixtures.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockLocal extends Mock implements AuthLocalDataSource {}

void main() {
  group('UserModel', () {
    test('parses the sign-in response: tokens plus the user at the top level', () {
      final login = LoginResponseModel.fromJson(fixtureMap('login_ok'));

      expect(login.accessToken, 'fake-access-token');
      expect(login.refreshToken, 'fake-refresh-token');
      expect(login.user.username, 'emilys');
      expect(login.user.firstName, 'Emily');
      expect(login.user.address, isNull, reason: 'sign-in does not return one');
    });

    test('parses /auth/me including the address, and survives a round trip', () {
      final user = UserModel.fromJson(fixtureMap('me'));
      final again = UserModel.fromJson(user.toJson());

      expect(user.address?.city, 'Phoenix');
      expect(user.toEntity().address?.oneLine, contains('626 Main Street'));
      expect(again.toEntity(), user.toEntity());
    });

    test('never stores more than the profile fields it shows', () {
      final stored = UserModel.fromJson(fixtureMap('me')).toJson();
      expect(
        stored.keys,
        containsAll(['id', 'username', 'email']),
      );
      expect(
        stored.keys.toSet().intersection({'password', 'ssn', 'bank', 'ein'}),
        isEmpty,
      );
    });

    test('a response without the required fields is a ParseException', () {
      expect(
        () => UserModel.fromJson({'id': 1}),
        throwsA(isA<ParseException>()),
      );
    });
  });

  group('AuthRepositoryImpl', () {
    late MockRemote remote;
    late MockLocal local;
    late AuthRepositoryImpl repository;

    setUp(() {
      remote = MockRemote();
      local = MockLocal();
      repository = AuthRepositoryImpl(remote: remote, local: local);
      when(
        () => local.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).thenAnswer((_) async {});
      when(() => local.saveUser(any())).thenAnswer((_) async {});
      when(() => local.clear()).thenAnswer((_) async {});
    });

    setUpAll(() {
      registerFallbackValue(UserModel.fromJson(fixtureMap('me')));
    });

    test('login stores both tokens and the user, and returns the user', () async {
      when(
        () => remote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => LoginResponseModel.fromJson(fixtureMap('login_ok')),
      );

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result.valueOrNull?.fullName, 'Emily Johnson');
      verify(
        () => local.saveTokens(
          accessToken: 'fake-access-token',
          refreshToken: 'fake-refresh-token',
        ),
      ).called(1);
      verify(() => local.saveUser(any())).called(1);
    });

    test('a 400 from sign-in is InvalidCredentialsFailure, and nothing is stored', () async {
      when(
        () => remote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const BadRequestException('Invalid credentials'));

      final result = await repository.login(username: 'emilys', password: 'x');

      expect(result.failureOrNull, isA<InvalidCredentialsFailure>());
      verifyNever(
        () => local.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('no connection is a NetworkFailure', () async {
      when(
        () => remote.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkException('offline'));

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result.failureOrNull, isA<NetworkFailure>());
    });

    test('fetchCurrentUser caches what the server returns', () async {
      when(
        () => remote.me(),
      ).thenAnswer((_) async => UserModel.fromJson(fixtureMap('me')));

      final result = await repository.fetchCurrentUser();

      expect(result.valueOrNull?.address?.city, 'Phoenix');
      verify(() => local.saveUser(any())).called(1);
    });

    test('an expired token on /auth/me is a SessionExpiredFailure', () async {
      when(
        () => remote.me(),
      ).thenThrow(const UnauthorizedException(statusCode: 401));

      expect((await repository.fetchCurrentUser()).failureOrNull, isA<SessionExpiredFailure>());
    });

    test('hasSession is false when storage cannot be read', () async {
      when(
        () => local.readRefreshToken(),
      ).thenThrow(const CacheException('keystore locked'));

      expect(await repository.hasSession(), isFalse);
    });

    test('logout clears everything stored', () async {
      await repository.logout();
      verify(() => local.clear()).called(1);
    });
  });
}
