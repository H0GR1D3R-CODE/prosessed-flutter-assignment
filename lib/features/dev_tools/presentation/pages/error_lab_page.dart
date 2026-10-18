import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopsphere/core/di/injection.dart';
import 'package:shopsphere/core/presentation/failure_copy.dart';
import 'package:shopsphere/core/router/routes.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/inline_banner.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/features/dev_tools/domain/error_lab.dart';
import 'package:shopsphere/features/dev_tools/presentation/bloc/error_lab_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A page for provoking every failure the app is built to handle, with the real network stack.
/// It is how a reviewer can see the error states without breaking anything by hand.
class ErrorLabPage extends StatelessWidget {
  const ErrorLabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ErrorLabCubit>(),
      child: const _ErrorLabView(),
    );
  }
}

class _Scenario {
  const _Scenario(this.scenario, this.icon, this.tint);

  final LabScenario scenario;
  final IconData icon;
  final OrbTint tint;

  String title(AppLocalizations l10n) => switch (scenario) {
    LabScenario.serverError => l10n.labServerError,
    LabScenario.notFound => l10n.labNotFound,
    LabScenario.slowNetwork => l10n.labSlow,
    LabScenario.timeout => l10n.labTimeout,
    LabScenario.expiredToken => l10n.labExpired,
    LabScenario.rejectedRefresh => l10n.labRejectedRefresh,
  };

  String note(AppLocalizations l10n) => switch (scenario) {
    LabScenario.serverError => l10n.labServerErrorNote,
    LabScenario.notFound => l10n.labNotFoundNote,
    LabScenario.slowNetwork => l10n.labSlowNote,
    LabScenario.timeout => l10n.labTimeoutNote,
    LabScenario.expiredToken => l10n.labExpiredNote,
    LabScenario.rejectedRefresh => l10n.labRejectedRefreshNote,
  };
}

const _scenarios = [
  _Scenario(LabScenario.serverError, Icons.cloud_off_rounded, OrbTints.rose),
  _Scenario(LabScenario.notFound, Icons.search_off_rounded, OrbTints.lilac),
  _Scenario(
    LabScenario.slowNetwork,
    Icons.hourglass_bottom_rounded,
    OrbTints.butter,
  ),
  _Scenario(LabScenario.timeout, Icons.timer_off_outlined, OrbTints.peach),
  _Scenario(LabScenario.expiredToken, Icons.autorenew_rounded, OrbTints.mint),
  _Scenario(
    LabScenario.rejectedRefresh,
    Icons.lock_reset_rounded,
    OrbTints.sky,
  ),
];

class _ErrorLabView extends StatelessWidget {
  const _ErrorLabView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.labTitle),
        leading: IconButton(
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: BlocBuilder<ErrorLabCubit, ErrorLabState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  Gap.l,
                  Gap.s,
                  Gap.l,
                  Gap.xxl,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.l),
                    child: Text(
                      l10n.labIntro,
                      style: context.text.bodyLarge?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final scenario in _scenarios) ...[
                    _ScenarioCard(scenario: scenario, state: state),
                    Gap.hm,
                  ],
                  InlineBanner(
                    icon: Icons.airplanemode_active_rounded,
                    message: l10n.labOffline,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.scenario, required this.state});

  final _Scenario scenario;
  final ErrorLabState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final running = state is LabRunning;
    final thisRunning =
        state is LabRunning &&
        (state as LabRunning).scenario == scenario.scenario;
    final done =
        state is LabDone && (state as LabDone).scenario == scenario.scenario
        ? state as LabDone
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: Radii.brXl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gap.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 48,
                  child: Orb(
                    tint: scenario.tint,
                    showShadow: false,
                    child: Icon(scenario.icon, size: 22, color: Palette.ink),
                  ),
                ),
                Gap.wl,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title(l10n),
                        style: context.text.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scenario.note(l10n),
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.wm,
                SizedBox(
                  width: 92,
                  child: AppButton(
                    kind: AppButtonKind.outline,
                    label: l10n.labRun,
                    isLoading: thisRunning,
                    onPressed: running
                        ? null
                        : () => context.read<ErrorLabCubit>().run(
                            scenario.scenario,
                          ),
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: done == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: Gap.l),
                      child: _OutcomeView(outcome: done.outcome),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeView extends StatelessWidget {
  const _OutcomeView({required this.outcome});

  final LabOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (outcome) {
      LabRecovered() => InlineBanner(
        icon: Icons.check_circle_outline_rounded,
        message: l10n.labRecovered,
      ),
      LabArrived(:final elapsed) => InlineBanner(
        icon: Icons.check_circle_outline_rounded,
        message: l10n.labSlowDone(
          (elapsed.inMilliseconds / 1000).toStringAsFixed(1),
        ),
      ),
      LabFailed(:final failure) => _FailureOutcome(
        copy: FailureCopy.of(context, failure),
        detail: failure.detail,
        handledNote: l10n.labHandled,
      ),
    };
  }
}

class _FailureOutcome extends StatelessWidget {
  const _FailureOutcome({
    required this.copy,
    required this.detail,
    required this.handledNote,
  });

  final FailureCopy copy;
  final String? detail;
  final String handledNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: Radii.brL,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Gap.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 44,
                child: Orb(
                  tint: copy.tint,
                  showShadow: false,
                  child: Icon(copy.icon, size: 20, color: Palette.ink),
                ),
              ),
              Gap.wm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(copy.title, style: context.text.titleSmall),
                    const SizedBox(height: 2),
                    Text(copy.message, style: context.text.bodyMedium),
                    if (detail != null) ...[
                      const SizedBox(height: Gap.xs),
                      Text(
                        detail!,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    const SizedBox(height: Gap.s),
                    Row(
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: context.shop.success,
                        ),
                        Gap.wxs,
                        Expanded(
                          child: Text(
                            handledNote,
                            style: context.text.labelMedium?.copyWith(
                              color: context.shop.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
