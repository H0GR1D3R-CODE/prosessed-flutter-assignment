import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/domain/validation/credential_validator.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/bloc/login_cubit.dart';

import '../../../helpers/builders.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SessionEvents events;

  setUp(() {
    repository = MockAuthRepository();
    events = SessionEvents();
    when(() => repository.logout()).thenAnswer((_) async {});
  });

  AuthCubit buildAuth() => AuthCubit(
    restoreSession: RestoreSessionUseCase(repository),
    getCurrentUser: GetCurrentUserUseCase(repository),
    logout: LogoutUseCase(repository),
    events: events,
  );

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'starts unauthenticated when nothing is stored',
      setUp: () => when(() => repository.hasSession()).thenAnswer((_) async => false),
      build: buildAuth,
      act: (cubit) => cubit.start(),
      expect: () => [const Unauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'starts authenticated with the user when the stored session is valid',
      setUp: () {
        when(() => repository.hasSession()).thenAnswer((_) async => true);
        when(
          () => repository.fetchCurrentUser(),
        ).thenAnswer((_) async => const Result.success(testUser));
      },
      build: buildAuth,
      act: (cubit) => cubit.start(),
      expect: () => [const Authenticated(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'a stored session the server rejects is cleared, with an explanatory notice',
      setUp: () {
        when(() => repository.hasSession()).thenAnswer((_) async => true);
        when(() => repository.fetchCurrentUser()).thenAnswer(
          (_) async => const Result.failure(SessionExpiredFailure()),
        );
      },
      build: buildAuth,
      act: (cubit) => cubit.start(),
      expect: () => [const Unauthenticated(notice: AuthNotice.sessionExpired)],
      verify: (_) => verify(() => repository.logout()).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      'an expiry announced by the network layer signs the user out with the notice',
      build: buildAuth,
      seed: () => const Authenticated(testUser),
      act: (cubit) async {
        events.expire();
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [const Unauthenticated(notice: AuthNotice.sessionExpired)],
    );

    blocTest<AuthCubit, AuthState>(
      'signing out clears the session without a notice',
      build: buildAuth,
      seed: () => const Authenticated(testUser),
      act: (cubit) => cubit.signOut(),
      expect: () => [const Unauthenticated()],
      verify: (_) => verify(() => repository.logout()).called(1),
    );

    blocTest<AuthCubit, AuthState>(
      'an expiry while already signed out changes nothing',
      build: buildAuth,
      seed: () => const Unauthenticated(),
      act: (cubit) async {
        events.expire();
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => <AuthState>[],
    );
  });

  group('LoginCubit', () {
    LoginCubit buildLogin() => LoginCubit(LoginUseCase(repository));

    blocTest<LoginCubit, LoginState>(
      'invalid fields never reach the network',
      build: buildLogin,
      act: (cubit) => cubit.submit(username: '', password: '123'),
      expect: () => [
        const LoginInvalid(
          usernameError: CredentialError.empty,
          passwordError: CredentialError.tooShort,
        ),
      ],
      verify: (_) => verifyNever(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ),
    );

    blocTest<LoginCubit, LoginState>(
      'valid credentials go submitting, then success',
      setUp: () => when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Result.success(testUser)),
      build: buildLogin,
      act: (cubit) => cubit.submit(username: 'emilys', password: 'emilyspass'),
      expect: () => [const LoginSubmitting(), const LoginSuccess(testUser)],
    );

    blocTest<LoginCubit, LoginState>(
      'wrong credentials end in a failure the form can show inline',
      setUp: () => when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(InvalidCredentialsFailure()),
      ),
      build: buildLogin,
      act: (cubit) => cubit.submit(username: 'emilys', password: 'wrongpass'),
      expect: () => [
        const LoginSubmitting(),
        const LoginFailure(InvalidCredentialsFailure()),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'editing a field clears the error',
      build: buildLogin,
      seed: () => const LoginFailure(InvalidCredentialsFailure()),
      act: (cubit) => cubit.editing(),
      expect: () => [const LoginInitial()],
    );
  });
}
