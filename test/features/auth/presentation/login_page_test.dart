import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/core/result/result.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/sign_in_preference.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/bloc/login_cubit.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';

import '../../../helpers/builders.dart';
import '../../../helpers/memory_sign_in_preference.dart';
import '../../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late AuthCubit auth;
  late MemorySignInPreference preference;

  setUp(() async {
    repository = MockAuthRepository();
    preference = MemorySignInPreference();
    when(() => repository.logout()).thenAnswer((_) async {});
    auth = AuthCubit(
      restoreSession: RestoreSessionUseCase(repository, preference),
      getCurrentUser: GetCurrentUserUseCase(repository),
      logout: LogoutUseCase(repository),
      events: SessionEvents(),
    );

    // The page asks the service locator for its cubit; give it one backed by the mock.
    await sl.reset();
    sl.registerFactory<LoginCubit>(
      () => LoginCubit(
        LoginUseCase(repository),
        LoadSignInPreferenceUseCase(preference),
        SaveSignInPreferenceUseCase(preference),
      ),
    );
  });

  tearDown(() async {
    await auth.close();
    await sl.reset();
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) {
    return pumpApp(
      tester,
      BlocProvider<AuthCubit>.value(value: auth, child: const LoginPage()),
      size: size,
    );
  }

  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets(
    'submitting an empty form explains what is missing, beside each field',
    (tester) async {
      await pumpLogin(tester);

      await tester.tap(find.text(en.signIn));
      await tester.pump();

      expect(find.text(en.usernameEmpty), findsOneWidget);
      expect(find.text(en.passwordEmpty), findsOneWidget);
      verifyNever(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  testWidgets('a field error disappears as soon as the user starts typing', (
    tester,
  ) async {
    await pumpLogin(tester);
    await tester.tap(find.text(en.signIn));
    await tester.pump();

    await tester.enterText(field(en.usernameLabel), 'e');
    await tester.pump();

    expect(find.text(en.usernameEmpty), findsNothing);
  });

  testWidgets('the password is hidden until the eye is tapped', (tester) async {
    await pumpLogin(tester);

    TextField password() => tester.widget<TextField>(field(en.passwordLabel));
    expect(password().obscureText, isTrue);

    await tester.tap(find.byTooltip(en.showPassword));
    await tester.pump();
    expect(password().obscureText, isFalse);

    await tester.tap(find.byTooltip(en.hidePassword));
    await tester.pump();
    expect(password().obscureText, isTrue);
  });

  testWidgets(
    'wrong credentials show the server-agnostic message and keep what was typed',
    (tester) async {
      when(
        () => repository.login(
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const Result.failure(InvalidCredentialsFailure()),
      );
      await pumpLogin(tester);

      await tester.enterText(field(en.usernameLabel), 'emilys');
      await tester.enterText(field(en.passwordLabel), 'wrongpass');
      await tester.tap(find.text(en.signIn));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(en.invalidCredentials), findsOneWidget);
      expect(find.text('emilys'), findsOneWidget);
    },
  );

  testWidgets('a network failure is described, not blamed on the password', (
    tester,
  ) async {
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure()));
    await pumpLogin(tester);

    await tester.enterText(field(en.usernameLabel), 'emilys');
    await tester.enterText(field(en.passwordLabel), 'emilyspass');
    await tester.tap(find.text(en.signIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(en.errorNetworkMessage), findsOneWidget);
    expect(find.text(en.invalidCredentials), findsNothing);
  });

  testWidgets('a good login signs the app in', (tester) async {
    when(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Result.success(testUser));
    await pumpLogin(tester);

    await tester.enterText(field(en.usernameLabel), 'emilys');
    await tester.enterText(field(en.passwordLabel), 'emilyspass');
    await tester.tap(find.text(en.signIn));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(auth.state, const Authenticated(testUser));
  });

  testWidgets('the demo button fills in the test account', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text(en.useDemoAccount));
    await tester.pump();

    expect(
      tester.widget<TextField>(field(en.usernameLabel)).controller?.text,
      'emilys',
    );
    expect(
      tester.widget<TextField>(field(en.passwordLabel)).controller?.text,
      'emilyspass',
    );
  });

  testWidgets('shows the session-ended notice after a forced logout', (
    tester,
  ) async {
    when(() => repository.hasSession()).thenAnswer((_) async => true);
    when(() => repository.fetchCurrentUser())
        .thenAnswer((_) async => const Result.failure(SessionExpiredFailure()));
    // start() waits on a real timer, which the test clock would never fire.
    await tester.runAsync(auth.start);
    await pumpLogin(tester);

    expect(find.text(en.sessionEndedNotice), findsOneWidget);
  });

  testWidgets(
    'fits a small phone at 1.3x text, and a wide tablet, without overflow',
    (tester) async {
      await pumpApp(
        tester,
        BlocProvider<AuthCubit>.value(value: auth, child: const LoginPage()),
        size: const Size(320, 568),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);

      await pumpApp(
        tester,
        BlocProvider<AuthCubit>.value(value: auth, child: const LoginPage()),
        size: const Size(1100, 700),
      );
      expect(tester.takeException(), isNull);
      expect(find.text(en.signIn), findsOneWidget);
    },
  );
}
