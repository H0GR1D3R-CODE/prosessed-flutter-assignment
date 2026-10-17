import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';
import 'package:shopsphere/features/auth/domain/validation/credential_validator.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Waiting for the user to fill in the form.
final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// One or both fields failed validation. The form shows the messages beside the fields.
final class LoginInvalid extends LoginState {
  const LoginInvalid({this.usernameError, this.passwordError});

  final CredentialError? usernameError;
  final CredentialError? passwordError;

  @override
  List<Object?> get props => [usernameError, passwordError];
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class LoginFailure extends LoginState {
  const LoginFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// The sign-in form's brain: validates, submits, reports.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._login) : super(const LoginInitial());

  final LoginUseCase _login;

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (state is LoginSubmitting) return;

    final usernameError = CredentialValidator.username(username);
    final passwordError = CredentialValidator.password(password);
    if (usernameError != null || passwordError != null) {
      emit(
        LoginInvalid(
          usernameError: usernameError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(const LoginSubmitting());
    final result = await _login(username: username, password: password);
    result.fold(
      onFailure: (failure) => emit(LoginFailure(failure)),
      onSuccess: (user) => emit(LoginSuccess(user)),
    );
  }

  /// Clears an error as soon as the user starts correcting it.
  void editing() {
    if (state is LoginFailure || state is LoginInvalid) {
      emit(const LoginInitial());
    }
  }
}
