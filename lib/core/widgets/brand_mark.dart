import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';

/// The logo as a button: it takes you home, and its moon takes a lap when you point at it or tap
/// it. Sits on [background] so the moon's halo blends into whatever it is placed on.
class BrandMark extends StatefulWidget {
  const BrandMark({
    required this.onTap,
    required this.tooltip,
    required this.background,
    this.size = 52,
    super.key,
  });

  final VoidCallback onTap;
  final String tooltip;
  final Color background;
  final double size;

  @override
  State<BrandMark> createState() => _BrandMarkState();
}

class _BrandMarkState extends State<BrandMark>
    with SingleTickerProviderStateMixin {
  static const double _restingAngle = 62 * math.pi / 180;

  late final AnimationController _lap = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void dispose() {
    _lap.dispose();
    super.dispose();
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context) || _lap.isAnimating) return;
    _lap.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _play(),
          child: InkResponse(
            onTap: () {
              HapticFeedback.selectionClick();
              _play();
              widget.onTap();
            },
            radius: widget.size * 0.62,
            child: SizedBox.square(
              // A full 48 dp target at the least.
              dimension: math.max(48, widget.size),
              child: Center(
                child: AnimatedBuilder(
                  animation: _lap,
                  builder: (context, _) {
                    final t = Curves.easeInOutCubic.transform(_lap.value);
                    final ink = context.colors.onSurface;
                    return Transform.scale(
                      // A small swell in the middle of the lap.
                      scale: 1 + 0.08 * math.sin(t * math.pi),
                      child: SizedBox.square(
                        dimension: widget.size,
                        child: CustomPaint(
                          painter: OrbitLogoPainter(
                            sphere: ink,
                            ring: ink,
                            halo: widget.background,
                            moon: context.shop.coral,
                            moonAngle: _restingAngle + t * 2 * math.pi,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
