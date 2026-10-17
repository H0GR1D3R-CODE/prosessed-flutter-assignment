/// Which colour scheme the shopper wants.
enum ThemeChoice { system, light, dark }

/// Preferences that outlive a session. Reads are synchronous because they are loaded before
/// the first frame; writes are not.
abstract interface class SettingsRepository {
  ThemeChoice get themeChoice;

  /// A language code such as `en` or `hi`, or null to follow the device.
  String? get languageCode;

  Future<void> saveThemeChoice(ThemeChoice choice);
  Future<void> saveLanguageCode(String? code);
}
