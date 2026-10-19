import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/auth/data/sign_in_preference_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/sign_in_preference.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test(
    'before anything is saved, the shopper is remembered and has no username',
    () async {
      final loaded = await PrefsSignInPreferenceRepository(prefs).load();

      expect(loaded, SignInPreference.initial);
    },
  );

  test('the choice and the username survive a restart', () async {
    await PrefsSignInPreferenceRepository(prefs)
        .save(const SignInPreference(username: 'emilys'));

    final restarted = await PrefsSignInPreferenceRepository(prefs).load();

    expect(restarted.remember, isTrue);
    expect(restarted.username, 'emilys');
  });

  test('choosing not to be remembered forgets the username', () async {
    final repository = PrefsSignInPreferenceRepository(prefs);
    await repository.save(const SignInPreference(username: 'emilys'));

    await repository.save(const SignInPreference(remember: false));

    final loaded = await repository.load();
    expect(loaded.remember, isFalse);
    expect(loaded.username, isNull);
    expect(prefs.containsKey('signin.username'), isFalse);
  });
}
