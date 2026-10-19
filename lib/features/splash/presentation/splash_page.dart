import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The first screen: a volt field, the mark, one lap of the moon, and a bar that fills while the
/// stored session is checked.
///
/// The router leaves for Home or Login the moment the auth state is known, so this page never
/// has to navigate itself.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const Duration _minimum = Duration(milliseconds: 1700);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _minimum,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
      context.read<AuthCubit>().start(minimumDuration: _minimum);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Palette.ink;
    const volt = Palette.volt;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: volt,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final lap = Curves.easeInOutCubic.transform(
            (t / 0.9).clamp(0.0, 1.0),
          );
          final pop = Curves.easeOutBack.transform((t / 0.35).clamp(0.0, 1.0));
          final text = Curves.easeOut.transform(
            ((t - 0.45) / 0.35).clamp(0.0, 1.0),
          );
          final tagline = Curves.easeOut.transform(
            ((t - 0.62) / 0.3).clamp(0.0, 1.0),
          );
          final status = Curves.easeOut.transform(
            ((t - 0.3) / 0.3).clamp(0.0, 1.0),
          );
          return Stack(
            children: [
              // Rings that open out from behind the mark.
              Positioned.fill(
                child: CustomPaint(
                  painter: _RingsPainter(
                    progress: Curves.easeOutCubic.transform(
                      (t / 0.8).clamp(0.0, 1.0),
                    ),
                    color: ink,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.55 + 0.45 * pop,
                      child: Opacity(
                        opacity: pop.clamp(0.0, 1.0),
                        child: SizedBox.square(
                          dimension: 148,
                          child: CustomPaint(
                            painter: OrbitLogoPainter(
                              sphere: ink,
                              ring: ink,
                              halo: volt,
                              moon: Palette.coral,
                              moonAngle: 62 * math.pi / 180 + lap * 2 * math.pi,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Opacity(
                      opacity: text,
                      child: Transform.translate(
                        offset: Offset(0, (1 - text) * 12),
                        child: const Text(
                          'ShopSphere',
                          style: TextStyle(
                            fontFamily: AppTypography.display,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                            color: ink,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: tagline,
                      child: Transform.translate(
                        offset: Offset(0, (1 - tagline) * 8),
                        child: Text(
                          l10n.splashTagline,
                          style: TextStyle(
                            fontFamily: AppTypography.body,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ink.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 44),
                    child: Opacity(
                      opacity: status,
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ProgressBar(progress: t, color: ink),
                            const SizedBox(height: 12),
                            Text(
                              l10n.splashStatus,
                              style: TextStyle(
                                fontFamily: AppTypography.body,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                                color: ink.withValues(alpha: 0.62),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A thin rounded bar that fills left to right.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: Curves.easeInOut.transform(progress.clamp(0.0, 1.0)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Two faint rings growing out from the centre, like a ripple that never quite arrives.
class _RingsPainter extends CustomPainter {
  const _RingsPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final centre = Offset(size.width / 2, size.height / 2 - 24);
    final reach = size.shortestSide;
    for (final (factor, alpha) in const [(0.62, 0.13), (0.92, 0.08)]) {
      canvas.drawCircle(
        centre,
        reach * factor * progress,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.progress != progress || old.color != color;
}
