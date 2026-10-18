import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A pill with minus, the current quantity and plus. Each button is a full 48 dp target.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.dense = false,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// A tighter variant for list rows: a narrower number and smaller icons, same 48 dp buttons.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canDecrease = value > min;
    final canIncrease = value < max;
    // Every button is a full 48 dp target; dense only tightens the number and the icons.
    const side = 48.0;

    return Semantics(
      container: true,
      label: l10n.quantity,
      value: '$value',
      increasedValue: canIncrease ? '${value + 1}' : null,
      decreasedValue: canDecrease ? '${value - 1}' : null,
      onIncrease: canIncrease ? () => onChanged(value + 1) : null,
      onDecrease: canDecrease ? () => onChanged(value - 1) : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: context.colors.outlineVariant, width: 1.5),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.decreaseQuantity,
                onPressed: canDecrease ? () => onChanged(value - 1) : null,
                icon: Icon(Icons.remove_rounded, size: dense ? 20 : 24),
                constraints: const BoxConstraints.tightFor(
                  width: side,
                  height: side,
                ),
              ),
              SizedBox(
                width: dense ? 28 : 36,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.8, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '$value',
                    key: ValueKey(value),
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.increaseQuantity,
                onPressed: canIncrease ? () => onChanged(value + 1) : null,
                icon: Icon(Icons.add_rounded, size: dense ? 20 : 24),
                constraints: const BoxConstraints.tightFor(
                  width: side,
                  height: side,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
