import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';

/// Sweeps a soft highlight across its child, which should be built from [SkeletonBox]es.
///
/// With "remove animations" switched on in the system settings it stays still.
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
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
    final base = context.colors.surfaceContainerHigh;
    final highlight = context.shop.isDark
        ? context.colors.surfaceContainerHighest
        : context.colors.surfaceContainerLowest;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlidingTransform(_controller.value * 2 - 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingTransform extends GradientTransform {
  const _SlidingTransform(this.slide);

  /// -1 puts the highlight fully off the left edge, +1 fully off the right.
  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}

/// A placeholder block. Opaque on purpose: [Shimmer] recolours it.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height,
    this.radius = 12,
    this.circle = false,
    super.key,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
