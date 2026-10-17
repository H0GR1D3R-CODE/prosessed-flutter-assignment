import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/network/session.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';

/// Why the user is looking at the login screen, when it is not simply a fresh launch.
enum AuthNotice { sessionExpired }

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The app has just launched and the stored session has not been checked yet.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);

  /// May be null when the app started offline with no cached profile.
  final User? user;

  @override
  List<Object?> get props => [user];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated({this.notice});

  final AuthNotice? notice;

  @override
  List<Object?> get props => [notice];
}

/// Owns "who is signed in" for the whole app. The router redirects off this state.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._restoreSession,
    required this._getCurrentUser,
    required this._logout,
    required SessionEvents events,
  }) : super(const AuthUnknown()) {
    _expiredSubscription = events.onExpired.listen(
      (_) => handleSessionExpired(),
    );
  }

  final RestoreSessionUseCase _restoreSession;
  final GetCurrentUserUseCase _getCurrentUser;
  final LogoutUseCase _logout;
  late final StreamSubscription<void> _expiredSubscription;

  /// Checks the stored session. [minimumDuration] keeps the splash on screen long enough to be seen.
  Future<void> start({Duration minimumDuration = Duration.zero}) async {
    final results = await Future.wait<Object>([
      _restoreSession(),
      Future<void>.delayed(minimumDuration).then((_) => 0),
    ]);
    switch (results.first as SessionRestore) {
      case NoSession():
        emit(const Unauthenticated());
      case ActiveSession(:final user):
        emit(Authenticated(user));
      case ExpiredSession():
        await _logout();
        emit(const Unauthenticated(notice: AuthNotice.sessionExpired));
    }
  }

  void signedIn(User user) => emit(Authenticated(user));

  Future<void> signOut() async {
    await _logout();
    emit(const Unauthenticated());
  }

  /// Called when the server has stopped accepting the tokens and a refresh could not fix it.
  Future<void> handleSessionExpired() async {
    if (state is! Authenticated) return;
    await _logout();
    emit(const Unauthenticated(notice: AuthNotice.sessionExpired));
  }

  /// Fetches the profile again, e.g. when the user was unknown after an offline launch.
  Future<void> refreshUser() async {
    final result = await _getCurrentUser();
    final user = result.valueOrNull;
    if (user != null && state is Authenticated) emit(Authenticated(user));
  }

  @override
  Future<void> close() async {
    await _expiredSubscription.cancel();
    return super.close();
  }
}
