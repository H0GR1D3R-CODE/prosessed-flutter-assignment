import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The ShopSphere mark: a sphere, a tilted orbit and one moon.
///
/// The geometry mirrors `tool/generate_icon.py`, so the launcher icon and the logo in the app
/// are the same drawing. [moonAngle] moves the moon round the orbit: while it is on the far
/// side it passes behind the sphere, on the near side in front of it.
class OrbitLogoPainter extends CustomPainter {
  const OrbitLogoPainter({
    required this.sphere,
    required this.ring,
    required this.halo,
    required this.moon,
    this.moonAngle = 62 * math.pi / 180,
    this.sphereTint,
  });

  final Color sphere;
  final Color ring;

  /// The colour of whatever is behind the logo: it outlines the near half of the orbit where
  /// that crosses the sphere.
  final Color halo;
  final Color moon;
  final double moonAngle;

  /// When set, the sphere is a lit orb in this tint instead of a flat ink ball.
  final OrbTint? sphereTint;

  static const double _tilt = -24 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final a = 0.293 * s;
    final b = 0.1016 * s;
    final sphereRadius = 0.184 * s;
    final ringWidth = math.max(1.0, 0.0215 * s);
    final haloWidth = math.max(2.0, 0.0527 * s);
    final moonRadius = 0.039 * s;
    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: a * 2,
      height: b * 2,
    );

    void arc(bool front, Paint paint) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(_tilt);
      canvas.drawArc(orbit, front ? 0 : math.pi, math.pi, false, paint);
      canvas.restore();
    }

    Offset moonCentre() {
      final ex = a * math.cos(moonAngle);
      final ey = b * math.sin(moonAngle);
      final cosT = math.cos(_tilt);
      final sinT = math.sin(_tilt);
      return Offset(c.dx + ex * cosT - ey * sinT, c.dy + ex * sinT + ey * cosT);
    }

    void drawMoon({required bool withHalo}) {
      final m = moonCentre();
      if (withHalo) {
        canvas.drawCircle(m, moonRadius + 0.0137 * s, Paint()..color = halo);
      }
      canvas.drawCircle(m, moonRadius, Paint()..color = moon);
    }

    final moonInFront = math.sin(moonAngle) >= 0;
    Paint line(Color color, double width) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = width
      ..color = color;

    // Far half of the orbit, then the moon if it is behind the sphere.
    arc(false, line(ring, ringWidth));
    if (!moonInFront) drawMoon(withHalo: false);

    // The sphere, lit from the upper left.
    final sphereRect = Rect.fromCircle(center: c, radius: sphereRadius);
    if (sphereTint != null) {
      canvas.drawCircle(
        c,
        sphereRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.38, -0.42),
            radius: 1.02,
            colors: [
              sphereTint!.light,
              Color.lerp(sphereTint!.light, sphereTint!.deep, 0.5)!,
              sphereTint!.deep,
            ],
            stops: const [0, 0.52, 1],
          ).createShader(sphereRect),
      );
    } else {
      canvas.drawCircle(c, sphereRadius, Paint()..color = sphere);
      canvas.drawCircle(
        c,
        sphereRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.34, -0.38),
            radius: 0.75,
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(sphereRect),
      );
    }

    // Near half of the orbit: a halo first, so it stays legible where it crosses the sphere.
    arc(true, line(halo, haloWidth));
    arc(true, line(ring, ringWidth));
    if (moonInFront) drawMoon(withHalo: true);
  }

  @override
  bool shouldRepaint(OrbitLogoPainter old) =>
      old.sphere != sphere ||
      old.ring != ring ||
      old.halo != halo ||
      old.moon != moon ||
      old.moonAngle != moonAngle ||
      old.sphereTint != sphereTint;
}

/// The logo at a fixed [size], coloured for the current theme.
class OrbitLogo extends StatelessWidget {
  const OrbitLogo({
    this.size = 48,
    this.background,
    this.moonAngle = 62 * math.pi / 180,
    super.key,
  });

  final double size;

  /// What the logo sits on, if not the page background.
  final Color? background;
  final double moonAngle;

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.onSurface;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: OrbitLogoPainter(
          sphere: ink,
          ring: ink,
          halo: background ?? context.colors.surface,
          moon: context.shop.coral,
          moonAngle: moonAngle,
        ),
      ),
    );
  }
}

/// The logo with its moon circling: the app's loading indicator.
///
/// Pauses on the resting pose when the system asks for reduced motion.
class OrbitSpinner extends StatefulWidget {
  const OrbitSpinner({this.size = 28, this.color, this.background, super.key});

  final double size;
  final Color? color;
  final Color? background;

  @override
  State<OrbitSpinner> createState() => _OrbitSpinnerState();
}

class _OrbitSpinnerState extends State<OrbitSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
    final ink = widget.color ?? context.colors.onSurface;
    return Semantics(
      label: context.l10n.loading,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: OrbitLogoPainter(
              sphere: ink,
              ring: ink,
              halo: widget.background ?? context.colors.surface,
              moon: context.shop.coral,
              moonAngle: _controller.value * 2 * math.pi + 62 * math.pi / 180,
            ),
          ),
        ),
      ),
    );
  }
}

/// An illustration for empty and error screens: a lit orb on a tilted orbit with an icon on it.
class OrbitScene extends StatelessWidget {
  const OrbitScene({
    required this.icon,
    required this.tint,
    this.size = 184,
    super.key,
  });

  final IconData icon;
  final OrbTint tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = tint.forBrightness(context.theme.brightness);
    final ink = context.colors.onSurface;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: OrbitLogoPainter(
              sphere: ink,
              ring: ink.withValues(alpha: 0.85),
              halo: context.colors.surface,
              moon: context.shop.coral,
              moonAngle: 40 * math.pi / 180,
              sphereTint: resolved,
            ),
          ),
          Icon(
            icon,
            size: size * 0.2,
            color: context.shop.isDark ? Colors.white : Palette.ink,
          ),
        ],
      ),
    );
  }
}
