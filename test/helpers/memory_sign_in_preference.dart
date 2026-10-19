import 'package:shopsphere/features/auth/domain/sign_in_preference.dart';

/// The remember-me choice held in memory, for tests that do not need real storage.
class MemorySignInPreference implements SignInPreferenceRepository {
  MemorySignInPreference([this.saved = SignInPreference.initial]);

  SignInPreference saved;

  @override
  Future<SignInPreference> load() async => saved;

  @override
  Future<void> save(SignInPreference preference) async {
    saved = preference;
  }
}
