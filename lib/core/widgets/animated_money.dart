import 'package:flutter/widgets.dart';
import 'package:shopsphere/core/utils/formatters.dart';

/// A price that rolls to its new value instead of jumping, so a changed quantity or a removed
/// item is easy to follow with the eye. It starts at its first value without animating.
class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney({
    required this.value,
    this.style,
    this.prefix = '',
    this.duration = const Duration(milliseconds: 520),
    super.key,
  });

  final double value;
  final TextStyle? style;

  /// Shown before the amount, such as a minus sign for a discount.
  final String prefix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: animate ? duration : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, shown, _) => Text(
        '$prefix${Formatters.money(shown)}',
        // Digits keep the same width, so the number does not wobble while it rolls.
        style: (style ?? const TextStyle()).copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
