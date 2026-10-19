import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';

/// The backdrop product photos sit on: a soft, lit studio sweep instead of a saturated shape.
///
/// It is drawn the way a photographer would light a product: paper that is barely tinted by the
/// category, a pool of light behind the object, a gentle vignette at the edges, and a contact
/// shadow on the floor so the product looks like it is standing there. Everything is gradients,
/// so it costs no assets and scales to any size.
class StudioPainter extends CustomPainter {
  const StudioPainter({
    required this.tint,
    required this.dark,
    this.cornerRatio = 0.18,
    this.floorY = 0.86,
    this.floorWidth = 0.5,
    this.paintBackground = true,
  });

  /// The category's colour. Only a trace of it reaches the paper.
  final OrbTint tint;
  final bool dark;

  /// Corner radius as a share of the shorter side. Zero for a full-bleed backdrop.
  final double cornerRatio;

  /// Where the product's contact shadow sits, as a share of the height.
  final double floorY;

  /// How wide the contact shadow is, as a share of the width.
  final double floorWidth;

  /// False draws only the floor shadow, for use over some other background.
  final bool paintBackground;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.save();
    if (cornerRatio > 0) {
      canvas.clipRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular(size.shortestSide * cornerRatio),
        ),
      );
    }

    if (paintBackground) {
      final top = dark
          ? Color.lerp(const Color(0xFF2E3037), tint.deep, 0.14)!
          : Color.lerp(const Color(0xFFFBF9F6), tint.light, 0.26)!;
      final bottom = dark
          ? Color.lerp(const Color(0xFF1C1D22), tint.deep, 0.08)!
          : Color.lerp(const Color(0xFFF1EEE9), tint.light, 0.6)!;
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [top, bottom],
          ).createShader(rect),
      );

      // The pool of light behind the product.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -0.28),
            radius: 0.78,
            colors: [
              Colors.white.withValues(alpha: dark ? 0.10 : 0.78),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );

      // A faint vignette keeps the eye on the middle.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            radius: 0.95,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: dark ? 0.28 : 0.06),
            ],
            stops: const [0.62, 1.0],
          ).createShader(rect),
      );
    }

    _paintFloorShadow(canvas, size);
    canvas.restore();
  }

  void _paintFloorShadow(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * floorY);
    final width = size.width * floorWidth;
    final base = dark ? 0.55 : 0.2;

    // A wide, soft pool of shade, and a tight dark line where the product touches the floor.
    canvas.drawOval(
      Rect.fromCenter(
        center: centre,
        width: width * 1.35,
        height: size.height * 0.075,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: base * 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.03),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: centre,
        width: width * 0.78,
        height: size.height * 0.026,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: base * 1.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.011),
    );
  }

  @override
  bool shouldRepaint(StudioPainter old) =>
      old.tint != tint ||
      old.dark != dark ||
      old.cornerRatio != cornerRatio ||
      old.floorY != floorY ||
      old.floorWidth != floorWidth ||
      old.paintBackground != paintBackground;
}

/// A [StudioPainter] that follows the theme.
class StudioBackdrop extends StatelessWidget {
  const StudioBackdrop({
    required this.tint,
    this.cornerRatio = 0.18,
    this.floorY = 0.86,
    this.floorWidth = 0.5,
    this.paintBackground = true,
    this.child,
    super.key,
  });

  final OrbTint tint;
  final double cornerRatio;
  final double floorY;
  final double floorWidth;
  final bool paintBackground;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StudioPainter(
        tint: tint,
        dark: context.theme.brightness == Brightness.dark,
        cornerRatio: cornerRatio,
        floorY: floorY,
        floorWidth: floorWidth,
        paintBackground: paintBackground,
      ),
      child: child,
    );
  }
}
