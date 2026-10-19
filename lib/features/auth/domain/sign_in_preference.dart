import 'package:equatable/equatable.dart';

/// What the shopper chose on the sign-in form about being remembered.
///
/// When [remember] is true the session survives closing the app and the username is filled in
/// next time. When it is false the session ends when the app is closed, which is what you want
/// on a shared device. Before anything has been chosen the default is to remember.
class SignInPreference extends Equatable {
  const SignInPreference({this.remember = true, this.username});

  /// A successful sign-in with the box ticked or not. The username is only kept when asked.
  factory SignInPreference.afterSignIn({
    required bool remember,
    required String username,
  }) {
    return SignInPreference(
      remember: remember,
      username: remember ? username.trim() : null,
    );
  }

  static const SignInPreference initial = SignInPreference();

  final bool remember;
  final String? username;

  @override
  List<Object?> get props => [remember, username];
}

abstract interface class SignInPreferenceRepository {
  Future<SignInPreference> load();
  Future<void> save(SignInPreference preference);
}

class LoadSignInPreferenceUseCase {
  const LoadSignInPreferenceUseCase(this._repository);

  final SignInPreferenceRepository _repository;

  Future<SignInPreference> call() => _repository.load();
}

class SaveSignInPreferenceUseCase {
  const SaveSignInPreferenceUseCase(this._repository);

  final SignInPreferenceRepository _repository;

  Future<void> call(SignInPreference preference) =>
      _repository.save(preference);
}
