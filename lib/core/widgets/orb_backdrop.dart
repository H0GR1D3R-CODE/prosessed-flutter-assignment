import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/widgets/orb.dart';

/// One orb that drifts a few pixels up and down, out of phase with its neighbours.
class FloatingOrb extends StatefulWidget {
  const FloatingOrb({
    required this.tint,
    required this.size,
    this.phase = 0,
    this.amplitude = 6,
    this.period = const Duration(seconds: 7),
    super.key,
  });

  final OrbTint tint;
  final double size;
  final double phase;
  final double amplitude;
  final Duration period;

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final dy =
              math.sin((_controller.value + widget.phase) * 2 * math.pi) *
              widget.amplitude;
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: Orb(tint: widget.tint),
        ),
      ),
    );
  }
}

/// A loose cluster of orbs that fills a corner of a screen with colour and depth.
///
/// Used behind the login form; the orbs overflow the edges on purpose, so the screen reads
/// as a window onto something larger.
class OrbCluster extends StatelessWidget {
  const OrbCluster({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final unit = math.min(w, h);
        return ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -unit * 0.18,
                top: -unit * 0.16,
                child: FloatingOrb(
                  tint: OrbTints.peach,
                  size: unit * 0.92,
                  amplitude: 7,
                ),
              ),
              Positioned(
                right: unit * 0.46,
                top: unit * 0.52,
                child: FloatingOrb(
                  tint: OrbTints.lilac,
                  size: unit * 0.42,
                  phase: 0.35,
                  amplitude: 5,
                ),
              ),
              Positioned(
                right: unit * 0.1,
                top: unit * 0.66,
                child: FloatingOrb(
                  tint: OrbTints.mint,
                  size: unit * 0.28,
                  phase: 0.7,
                  amplitude: 4,
                ),
              ),
              Positioned(
                left: -unit * 0.1,
                top: unit * 0.18,
                child: FloatingOrb(
                  tint: OrbTints.sky,
                  size: unit * 0.3,
                  phase: 0.15,
                  amplitude: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
