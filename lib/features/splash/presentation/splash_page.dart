import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_cubit.dart';

/// The first screen: a volt field, the mark and one lap of the moon.
///
/// While it plays, the stored session is checked; the router leaves for Home or Login the moment
/// the auth state is known, so this page never has to navigate itself.
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
    return Scaffold(
      backgroundColor: volt,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final lap = Curves.easeInOutCubic.transform(
              (t / 0.9).clamp(0.0, 1.0),
            );
            final pop = Curves.easeOutBack.transform(
              (t / 0.35).clamp(0.0, 1.0),
            );
            final text = Curves.easeOut.transform(
              ((t - 0.45) / 0.35).clamp(0.0, 1.0),
            );
            return Column(
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
              ],
            );
          },
        ),
      ),
    );
  }
}
