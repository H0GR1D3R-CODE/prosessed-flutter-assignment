import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';
import 'package:shopsphere/features/auth/domain/usecases/auth_usecases.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Fetches the signed-in user from `GET /auth/me`.
///
/// A user already known from sign-in is shown straight away while the fresh copy loads, so the
/// screen is never blank. An expired token is handled by the network layer, which signs the
/// user out; this cubit only reports what it got.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._getCurrentUser, User? knownUser})
    : super(
        knownUser == null ? const ProfileLoading() : ProfileLoaded(knownUser),
      );

  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> load() async {
    final current = state;
    if (current is! ProfileLoaded) emit(const ProfileLoading());
    final result = await _getCurrentUser();
    result.fold(
      onFailure: (failure) {
        // Keep showing a user we already have; only a blank screen needs an error.
        if (current is! ProfileLoaded) emit(ProfileFailure(failure));
      },
      onSuccess: (user) => emit(ProfileLoaded(user)),
    );
  }
}
