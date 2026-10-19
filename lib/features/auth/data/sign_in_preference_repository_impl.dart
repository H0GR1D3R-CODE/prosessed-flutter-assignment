import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/auth/domain/sign_in_preference.dart';

/// The remember-me choice and the last username, in plain preferences: neither is a secret.
/// A failed write is ignored, since the sign-in itself has already worked.
class PrefsSignInPreferenceRepository implements SignInPreferenceRepository {
  const PrefsSignInPreferenceRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _rememberKey = 'signin.remember';
  static const String _usernameKey = 'signin.username';

  @override
  Future<SignInPreference> load() async {
    return SignInPreference(
      remember: _prefs.getBool(_rememberKey) ?? true,
      username: _prefs.getString(_usernameKey),
    );
  }

  @override
  Future<void> save(SignInPreference preference) async {
    try {
      await _prefs.setBool(_rememberKey, preference.remember);
      final username = preference.username;
      if (username == null || username.isEmpty) {
        await _prefs.remove(_usernameKey);
      } else {
        await _prefs.setString(_usernameKey, username);
      }
    } on Object {
      // Not worth failing a sign-in over.
    }
  }
}
