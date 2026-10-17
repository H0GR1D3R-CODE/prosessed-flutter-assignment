import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// A coral pill: `-12%`.
class DiscountPill extends StatelessWidget {
  const DiscountPill({required this.percent, super.key});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final shop = context.shop;
    final rounded = percent.round();
    return Semantics(
      label: context.l10n.discountOff(rounded),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: shop.coral,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: Text(
            '−$rounded%',
            style: context.text.labelMedium?.copyWith(
              color: shop.onCoral,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// A star and a number: `4.5`.
class RatingPill extends StatelessWidget {
  const RatingPill({required this.rating, this.dense = false, super.key});

  final double rating;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final label = Formatters.rating(rating);
    return Semantics(
      label: context.l10n.ratingOutOf(label),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: dense ? 16 : 18,
            color: context.shop.star,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: (dense ? context.text.labelMedium : context.text.labelLarge)
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

/// Availability as a dot and a few words. The colour is never the only signal.
class StockBadge extends StatelessWidget {
  const StockBadge({required this.stock, required this.isAvailable, super.key});

  final int stock;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shop = context.shop;
    final (
      Color color,
      Color textColor,
      String text,
    ) = !isAvailable || stock <= 0
        ? (context.colors.error, context.colors.error, l10n.outOfStock)
        : stock <= 10
        ? (shop.star, shop.warning, l10n.lowStock(stock))
        : (shop.success, shop.success, l10n.inStock);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelLarge?.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

/// Overlays a count on [child] and gives it a small bounce whenever the count goes up.
class BouncingBadge extends StatefulWidget {
  const BouncingBadge({required this.count, required this.child, super.key});

  final int count;
  final Widget child;

  @override
  State<BouncingBadge> createState() => _BouncingBadgeState();
}

class _BouncingBadgeState extends State<BouncingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.5,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.5,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 70,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(BouncingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count &&
        !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.shop;
    final label = widget.count > 99 ? '99+' : '${widget.count}';
    return Badge(
      isLabelVisible: widget.count > 0,
      backgroundColor: shop.coral,
      textColor: shop.onCoral,
      textStyle: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w800),
      label: ScaleTransition(scale: _scale, child: Text(label)),
      child: widget.child,
    );
  }
}
