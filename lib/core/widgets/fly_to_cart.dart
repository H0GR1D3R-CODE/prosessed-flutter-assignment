import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';

/// Marks the cart tab's icon, so that something can fly to it. It sits on exactly one widget.
final GlobalKey cartIconKey = GlobalKey(debugLabel: 'cart-tab-icon');

/// A small orb that arcs from the thing you just added to the cart tab, then lands with a pop.
abstract final class FlyToCart {
  /// Plays the flight from the widget with [from] to the cart icon. Does nothing when the
  /// system asks for reduced motion, or when either end is not on screen.
  static void play(BuildContext context, {required GlobalKey from}) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    final source = from.currentContext?.findRenderObject();
    final target = cartIconKey.currentContext?.findRenderObject();
    if (overlay == null ||
        source is! RenderBox ||
        target is! RenderBox ||
        !source.attached ||
        !target.attached) {
      return;
    }
    final start = source.localToGlobal(source.size.center(Offset.zero));
    final end = target.localToGlobal(target.size.center(Offset.zero));

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) =>
          _FlyingOrb(start: start, end: end, onDone: entry.remove),
    );
    overlay.insert(entry);
  }
}

class _FlyingOrb extends StatefulWidget {
  const _FlyingOrb({
    required this.start,
    required this.end,
    required this.onDone,
  });

  final Offset start;
  final Offset end;
  final VoidCallback onDone;

  @override
  State<_FlyingOrb> createState() => _FlyingOrbState();
}

class _FlyingOrbState extends State<_FlyingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 780),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      });

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A quadratic curve that rises above both ends before dropping in.
  Offset _at(double t) {
    final control = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      math.min(widget.start.dy, widget.end.dy) - 120,
    );
    final u = 1 - t;
    return widget.start * (u * u) +
        control * (2 * u * t) +
        widget.end * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.shop;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final move = Curves.easeInOutCubic.transform(_controller.value);
          final position = _at(move);
          // Shrinks on the way in, and fades only in the last moments.
          final scale = 1 - 0.62 * move;
          final fade = _controller.value > 0.85
              ? 1 - (_controller.value - 0.85) / 0.15
              : 1.0;
          const radius = 22.0;
          return Stack(
            children: [
              Positioned(
                left: position.dx - radius,
                top: position.dy - radius,
                child: Opacity(
                  opacity: fade.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: shop.volt,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: shop.volt.withValues(alpha: 0.55),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: SizedBox.square(
                        dimension: radius * 2,
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          size: 22,
                          color: shop.onVolt,
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
