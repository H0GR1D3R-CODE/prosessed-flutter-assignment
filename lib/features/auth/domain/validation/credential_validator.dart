/// Why a sign-in field was rejected. The UI turns each case into a translated message.
enum CredentialError { empty, tooShort }

/// Client-side checks that save a round trip for obviously wrong input.
///
/// Pure Dart on purpose: it can be unit-tested without a widget, and the login form and the
/// login cubit share the same rules.
abstract final class CredentialValidator {
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 6;

  static CredentialError? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return CredentialError.empty;
    if (text.length < minUsernameLength) return CredentialError.tooShort;
    return null;
  }

  static CredentialError? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return CredentialError.empty;
    if (text.length < minPasswordLength) return CredentialError.tooShort;
    return null;
  }
}
