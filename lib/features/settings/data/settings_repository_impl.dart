import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeKey = 'settings.theme';
  static const String _languageKey = 'settings.language';

  @override
  ThemeChoice get themeChoice {
    final stored = _prefs.getString(_themeKey);
    return ThemeChoice.values.firstWhere(
      (choice) => choice.name == stored,
      orElse: () => ThemeChoice.system,
    );
  }

  @override
  String? get languageCode => _prefs.getString(_languageKey);

  @override
  Future<void> saveThemeChoice(ThemeChoice choice) async {
    await _prefs.setString(_themeKey, choice.name);
  }

  @override
  Future<void> saveLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_languageKey);
    } else {
      await _prefs.setString(_languageKey, code);
    }
  }
}
