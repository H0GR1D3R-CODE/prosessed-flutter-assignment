import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/widgets/network_photo.dart';
import 'package:shopsphere/core/widgets/shimmer.dart';
import 'package:shopsphere/core/widgets/studio_backdrop.dart';

/// Paints a softly lit sphere with a contact shadow underneath: the visual signature of the app.
///
/// Light falls from the upper left: a pale highlight, a deeper body towards the lower right, and
/// a small specular glint. Everything is drawn with gradients, so the orb costs no image assets
/// and scales to any size.
class OrbPainter extends CustomPainter {
  const OrbPainter({
    required this.tint,
    required this.shadowColor,
    this.showShadow = true,
  });

  final OrbTint tint;
  final Color shadowColor;
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter =
        math.min(size.width, size.height) * (showShadow ? 0.9 : 1.0);
    final radius = diameter / 2;
    final center = Offset(
      size.width / 2,
      showShadow ? size.height / 2 - size.height * 0.035 : size.height / 2,
    );
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (showShadow) {
      final shadow = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 1.02),
        width: radius * 1.35,
        height: radius * 0.2,
      );
      canvas.drawOval(
        shadow,
        Paint()
          ..color = shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.07),
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.38, -0.42),
          radius: 1.02,
          colors: [
            tint.light,
            Color.lerp(tint.light, tint.deep, 0.5)!,
            tint.deep,
          ],
          stops: const [0.0, 0.52, 1.0],
        ).createShader(rect),
    );

    // A thin rim of reflected light along the lower right edge sells the volume.
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.025)
        ..shader = SweepGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.28),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: const GradientRotation(-math.pi * 0.05),
        ).createShader(rect),
    );

    // The specular glint.
    final glint = Rect.fromCenter(
      center: Offset(center.dx - radius * 0.38, center.dy - radius * 0.46),
      width: radius * 0.42,
      height: radius * 0.24,
    );
    canvas.save();
    canvas.translate(glint.center.dx, glint.center.dy);
    canvas.rotate(-0.62);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: glint.width,
        height: glint.height,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.045),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(OrbPainter old) =>
      old.tint != tint ||
      old.shadowColor != shadowColor ||
      old.showShadow != showShadow;
}

/// An orb with an optional child centred on it.
class Orb extends StatelessWidget {
  const Orb({
    required this.tint,
    this.child,
    this.showShadow = true,
    super.key,
  });

  final OrbTint tint;
  final Widget? child;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final resolved = tint.forBrightness(context.theme.brightness);
    return CustomPaint(
      painter: OrbPainter(
        tint: resolved,
        shadowColor: context.shop.orbShadow,
        showShadow: showShadow,
      ),
      child: child == null ? null : Center(child: child),
    );
  }
}

/// A product photo standing on a soft studio backdrop, with a contact shadow on the floor.
///
/// The backdrop is tinted by the product's category, but only a trace, so a screen of mixed
/// products reads as one calm catalogue instead of a wall of colour.
class ProductOrb extends StatelessWidget {
  const ProductOrb({
    required this.imageUrl,
    required this.tint,
    this.heroTag,
    this.imageScale = 0.88,
    this.semanticLabel,
    this.fallbackIcon = Icons.image_outlined,
    super.key,
  });

  final String imageUrl;
  final OrbTint tint;
  final Object? heroTag;

  /// How much of the box the photo fills. Details pages use a larger value than list cards.
  final double imageScale;
  final String? semanticLabel;

  /// What the photo would have been (the category's icon), shown if it cannot be loaded.
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    Widget image = NetworkPhoto(
      url: imageUrl,
      memCacheWidth: 700,
      fallbackIcon: fallbackIcon,
    );
    if (heroTag != null) image = Hero(tag: heroTag!, child: image);

    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StudioBackdrop(tint: tint),
            Align(
              alignment: const Alignment(0, -0.1),
              child: FractionallySizedBox(
                widthFactor: imageScale,
                heightFactor: imageScale,
                child: image,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The skeleton of a [ProductOrb]: a bare rounded tile, to be wrapped in a [Shimmer].
class OrbSkeleton extends StatelessWidget {
  const OrbSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: SkeletonBox(radius: 28),
      ),
    );
  }
}
