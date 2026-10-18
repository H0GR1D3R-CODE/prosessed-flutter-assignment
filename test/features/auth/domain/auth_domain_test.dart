import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/domain/validation/credential_validator.dart';

import '../../../helpers/builders.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('CredentialValidator', () {
    test('rejects empty and too-short usernames', () {
      expect(CredentialValidator.username(null), CredentialError.empty);
      expect(CredentialValidator.username('   '), CredentialError.empty);
      expect(CredentialValidator.username('ab'), CredentialError.tooShort);
      expect(CredentialValidator.username('emilys'), isNull);
    });

    test('rejects empty and too-short passwords, but never trims them', () {
      expect(CredentialValidator.password(''), CredentialError.empty);
      expect(CredentialValidator.password('12345'), CredentialError.tooShort);
      expect(CredentialValidator.password('emilyspass'), isNull);
      expect(CredentialValidator.password('      '), isNull);
    });
  });

  group('LoginUseCase', () {
    test('trims the username and passes the password untouched', () async {
      final repository = MockAuthRepository();
      when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Result.success(testUser));

      final result = await LoginUseCase(repository)(
        username: '  emilys ',
        password: ' pass ',
      );

      expect(result.valueOrNull, testUser);
      verify(() => repository.login(username: 'emilys', password: ' pass '))
          .called(1);
    });
  });

  group('RestoreSessionUseCase', () {
    late MockAuthRepository repository;
    late RestoreSessionUseCase restore;

    setUp(() {
      repository = MockAuthRepository();
      restore = RestoreSessionUseCase(repository);
    });

    test('no stored session means NoSession and no network call', () async {
      when(() => repository.hasSession()).thenAnswer((_) async => false);

      expect(await restore(), isA<NoSession>());
      verifyNever(() => repository.fetchCurrentUser());
    });

    test(
      'a token the server accepts is an active session with that user',
      () async {
        when(() => repository.hasSession()).thenAnswer((_) async => true);
        when(() => repository.fetchCurrentUser())
            .thenAnswer((_) async => const Result.success(testUser));

        final outcome = await restore();

        expect(outcome, isA<ActiveSession>());
        expect((outcome as ActiveSession).user, testUser);
      },
    );

    test('a token the server rejects is an expired session', () async {
      when(() => repository.hasSession()).thenAnswer((_) async => true);
      when(
        () => repository.fetchCurrentUser(),
      ).thenAnswer((_) async => const Result.failure(SessionExpiredFailure()));

      expect(await restore(), isA<ExpiredSession>());
    });

    test(
      'offline at launch trusts the token and uses the cached user',
      () async {
        when(() => repository.hasSession()).thenAnswer((_) async => true);
        when(() => repository.fetchCurrentUser())
            .thenAnswer((_) async => const Result.failure(NetworkFailure()));
        when(() => repository.cachedUser()).thenAnswer((_) async => testUser);

        final outcome = await restore();

        expect(outcome, isA<ActiveSession>());
        expect((outcome as ActiveSession).user, testUser);
      },
    );
  });
}
