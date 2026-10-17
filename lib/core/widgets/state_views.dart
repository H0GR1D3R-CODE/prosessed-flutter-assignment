import 'package:flutter/material.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/presentation/failure_copy.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// Shown when something failed. Says what happened, offers the way forward, never a stack trace.
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.failure,
    this.onRetry,
    this.secondaryLabel,
    this.onSecondary,
    this.compact = false,
    super.key,
  });

  final Failure failure;
  final VoidCallback? onRetry;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// A smaller illustration, for placing inside an already busy screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final copy = FailureCopy.of(context, failure);
    return _StateLayout(
      icon: copy.icon,
      tint: copy.tint,
      title: copy.title,
      message: copy.message,
      compact: compact,
      liveRegion: true,
      actions: [
        if (onRetry != null)
          AppButton(
            label: context.l10n.retry,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            expanded: false,
          ),
        if (onSecondary != null && secondaryLabel != null)
          AppButton(
            label: secondaryLabel!,
            kind: AppButtonKind.outline,
            onPressed: onSecondary,
            expanded: false,
          ),
      ],
    );
  }
}

/// Shown when a request worked but there is nothing to show. An invitation to act.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.icon,
    required this.title,
    required this.message,
    this.tint = OrbTints.mint,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final OrbTint tint;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      icon: icon,
      tint: tint,
      title: title,
      message: message,
      compact: compact,
      actions: [
        if (actionLabel != null && onAction != null)
          AppButton(label: actionLabel!, onPressed: onAction, expanded: false),
      ],
    );
  }
}

/// A centred loading indicator for screens that have nothing to skeleton.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: OrbitSpinner(size: 44));
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.tint,
    required this.title,
    required this.message,
    required this.actions,
    required this.compact,
    this.liveRegion = false,
  });

  final IconData icon;
  final OrbTint tint;
  final String title;
  final String message;
  final List<Widget> actions;
  final bool compact;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Semantics(
            liveRegion: liveRegion,
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: OrbitScene(
                    icon: icon,
                    tint: tint,
                    size: compact ? 120 : 184,
                  ),
                ),
                SizedBox(height: compact ? Gap.m : Gap.xl),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.text.headlineMedium,
                ),
                Gap.hs,
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  SizedBox(height: compact ? Gap.l : Gap.xl),
                  Wrap(
                    spacing: Gap.m,
                    runSpacing: Gap.m,
                    alignment: WrapAlignment.center,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
