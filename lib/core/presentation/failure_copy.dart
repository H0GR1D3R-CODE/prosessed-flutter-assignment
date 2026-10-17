import 'package:flutter/material.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// What a [Failure] looks like to a person: a headline, a way forward, an icon and an orb colour.
///
/// The domain layer carries no text, so this is the one place where failure types meet
/// translations.
class FailureCopy {
  const FailureCopy({
    required this.title,
    required this.message,
    required this.icon,
    required this.tint,
  });

  factory FailureCopy.of(BuildContext context, Failure failure) {
    final l10n = context.l10n;
    return switch (failure) {
      NetworkFailure() => FailureCopy(
        title: l10n.errorNetworkTitle,
        message: l10n.errorNetworkMessage,
        icon: Icons.wifi_off_rounded,
        tint: OrbTints.sky,
      ),
      TimeoutFailure() => FailureCopy(
        title: l10n.errorTimeoutTitle,
        message: l10n.errorTimeoutMessage,
        icon: Icons.hourglass_bottom_rounded,
        tint: OrbTints.butter,
      ),
      ServerFailure() => FailureCopy(
        title: l10n.errorServerTitle,
        message: l10n.errorServerMessage,
        icon: Icons.cloud_off_rounded,
        tint: OrbTints.rose,
      ),
      NotFoundFailure() => FailureCopy(
        title: l10n.errorNotFoundTitle,
        message: l10n.errorNotFoundMessage,
        icon: Icons.search_off_rounded,
        tint: OrbTints.lilac,
      ),
      BadRequestFailure() => FailureCopy(
        title: l10n.errorBadRequestTitle,
        message: l10n.errorBadRequestMessage,
        icon: Icons.block_rounded,
        tint: OrbTints.peach,
      ),
      InvalidCredentialsFailure() => FailureCopy(
        title: l10n.invalidCredentials,
        message: l10n.invalidCredentials,
        icon: Icons.lock_outline_rounded,
        tint: OrbTints.peach,
      ),
      SessionExpiredFailure() => FailureCopy(
        title: l10n.errorSessionTitle,
        message: l10n.errorSessionMessage,
        icon: Icons.lock_clock_rounded,
        tint: OrbTints.peach,
      ),
      ParseFailure() => FailureCopy(
        title: l10n.errorParseTitle,
        message: l10n.errorParseMessage,
        icon: Icons.data_object_rounded,
        tint: OrbTints.clay,
      ),
      CacheFailure() => FailureCopy(
        title: l10n.errorCacheTitle,
        message: l10n.errorCacheMessage,
        icon: Icons.sd_storage_rounded,
        tint: OrbTints.clay,
      ),
      UnknownFailure() => FailureCopy(
        title: l10n.errorUnknownTitle,
        message: l10n.errorUnknownMessage,
        icon: Icons.error_outline_rounded,
        tint: OrbTints.clay,
      ),
    };
  }

  final String title;
  final String message;
  final IconData icon;
  final OrbTint tint;
}
