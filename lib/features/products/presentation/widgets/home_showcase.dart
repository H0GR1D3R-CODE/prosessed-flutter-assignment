import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/theme/shop_colors.dart';
import 'package:shopsphere/core/theme/spacing.dart';
import 'package:shopsphere/core/utils/formatters.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/orb.dart';
import 'package:shopsphere/core/widgets/reveal.dart';
import 'package:shopsphere/features/cart/domain/entities/checkout_extras.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The top of the home page: a few offers that slide by on their own, and can be swiped.
///
/// The first is today's best deal from the products on screen, the others point at the promo code
/// and the donation at checkout. Nothing here needs its own request.
class HomeHero extends StatefulWidget {
  const HomeHero({required this.deal, required this.onOpen, super.key});

  /// The product with the biggest discount, if there is one worth a banner.
  final Product? deal;
  final ValueChanged<Product> onOpen;

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  static const Duration _interval = Duration(seconds: 5);

  final PageController _pages = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;

  int get _count => widget.deal == null ? 2 : 3;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_pages.hasClients) return;
      // Stay still while another tab is on top, or when the shopper asked for less motion.
      if (!TickerMode.valuesOf(context).enabled ||
          MediaQuery.disableAnimationsOf(context)) {
        return;
      }
      final next = (_page + 1) % _count;
      _pages.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scaler = MediaQuery.textScalerOf(context);
    final height = 226 + (scaler.scale(16) - 16) * 7;
    final deal = widget.deal;
    final slides = <Widget>[
      if (deal != null) _DealSlide(product: deal, onOpen: widget.onOpen),
      const _CouponSlide(),
      const _GivingSlide(),
    ];

    return Column(
      children: [
        SizedBox(
          height: height,
          child: NotificationListener<UserScrollNotification>(
            // A swipe means the shopper is in charge: give them a full interval before moving on.
            onNotification: (_) {
              _restartTimer();
              return false;
            },
            child: PageView.builder(
              controller: _pages,
              itemCount: slides.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.xs),
                child: Semantics(
                  label: l10n.homeSlideLabel(index + 1, slides.length),
                  container: true,
                  child: slides[index],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? context.colors.onSurface
                        : context.colors.onSurface.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The rounded card every slide sits on: a gradient, a pair of soft orbs, and the content.
class _SlideFrame extends StatelessWidget {
  const _SlideFrame({
    required this.colors,
    required this.orbTint,
    required this.child,
    this.onTap,
  });

  final List<Color> colors;
  final OrbTint orbTint;

  /// Builds the content; [compact] is true when the slide is too narrow for its artwork.
  final Widget Function(bool compact) child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      borderRadius: Radii.brXl,
      child: ClipRRect(
        borderRadius: Radii.brXl,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -46,
                bottom: -64,
                width: 190,
                height: 190,
                child: Opacity(opacity: 0.5, child: Orb(tint: orbTint)),
              ),
              Positioned(
                right: 70,
                top: -34,
                width: 70,
                height: 70,
                child: Opacity(opacity: 0.35, child: Orb(tint: orbTint)),
              ),
              Padding(
                padding: const EdgeInsets.all(Gap.l),
                child: LayoutBuilder(
                  builder: (context, box) => child(box.maxWidth < 300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label.toUpperCase(),
          style: context.text.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = DecoratedBox(
      decoration: BoxDecoration(
        color: Palette.ink,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(
                  color: Palette.volt,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, size: 16, color: Palette.volt),
          ],
        ),
      ),
    );
    if (onTap == null) return pill;
    // The slide is already tappable; a button that copies needs a target of its own.
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(widthFactor: 1, child: pill),
        ),
      ),
    );
  }
}

class _DealSlide extends StatelessWidget {
  const _DealSlide({required this.product, required this.onOpen});

  final Product product;
  final ValueChanged<Product> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shown = product.hasDiscount ? product.discountedPrice : product.price;
    return _SlideFrame(
      colors: const [Palette.volt, Color(0xFFEAFFA6)],
      orbTint: OrbTints.butter,
      onTap: () => onOpen(product),
      child: (compact) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(
                  l10n.homeDealTag,
                  background: Palette.ink,
                  foreground: Palette.volt,
                ),
                const SizedBox(height: Gap.s),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(color: Palette.ink),
                ),
                const SizedBox(height: Gap.xs),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Gap.s,
                  children: [
                    Text(
                      Formatters.money(shown),
                      style: AppTypography.price(Palette.ink, size: 22),
                    ),
                    Text(
                      Formatters.money(product.price),
                      style: context.text.labelLarge?.copyWith(
                        color: Palette.ink.withValues(alpha: 0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    DiscountPill(percent: product.discountPercentage),
                  ],
                ),
                const Spacer(),
                _Pill(
                  label: l10n.homeDealCta,
                  icon: Icons.arrow_forward_rounded,
                  onTap: null,
                ),
              ],
            ),
          ),
          if (!compact) Gap.wm,
          if (!compact)
            SizedBox.square(
              dimension: 124,
              child: ProductOrb(
                imageUrl: product.thumbnail,
                tint: OrbTints.forCategory(product.category),
                fallbackIcon: CategoryIcons.of(product.category),
                imageScale: 0.92,
              ),
            ),
        ],
      ),
    );
  }
}

class _CouponSlide extends StatelessWidget {
  const _CouponSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = Coupons.welcome.code;
    const ink = Color(0xFF1B1E24);
    return _SlideFrame(
      colors: const [Color(0xFF23262E), Palette.ink],
      orbTint: OrbTints.lilac,
      child: (compact) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(
                  l10n.homeCouponTag,
                  background: Palette.volt,
                  foreground: Palette.ink,
                ),
                const SizedBox(height: Gap.s),
                Text(
                  l10n.homeCouponTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  l10n.homeCouponBody(code),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const Spacer(),
                _CopyButton(code: code, background: ink),
              ],
            ),
          ),
          if (!compact) Gap.wm,
          if (!compact) const _PercentBadge(),
        ],
      ),
    );
  }
}

/// "Copy code": puts the code on the clipboard and says so.
class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.code, required this.background});

  final String code;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.homeCouponCopy,
      excludeSemantics: true,
      child: InkResponse(
        radius: 36,
        onTap: () {
          HapticFeedback.selectionClick();
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(l10n.homeCouponCopied(code))),
            );
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Palette.volt,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Gap.l,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.content_copy_rounded,
                      size: 16,
                      color: Palette.ink,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge?.copyWith(
                          color: Palette.ink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  const _PercentBadge();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: SizedBox.square(
        dimension: 104,
        child: Orb(
          tint: const OrbTint(light: Color(0xFFF1FFB8), deep: Palette.volt),
          child: Text('10%', style: AppTypography.price(Palette.ink, size: 30)),
        ),
      ),
    );
  }
}

class _GivingSlide extends StatelessWidget {
  const _GivingSlide();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _SlideFrame(
      colors: const [Color(0xFFBDF1D6), Color(0xFFE6FBF0)],
      orbTint: OrbTints.mint,
      child: (compact) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(
                  l10n.homeGiveTag,
                  background: Palette.ink,
                  foreground: Palette.volt,
                ),
                const SizedBox(height: Gap.s),
                Text(
                  l10n.homeGiveTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge?.copyWith(color: Palette.ink),
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  l10n.homeGiveBody,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(
                    color: Palette.ink.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          if (!compact) Gap.wm,
          if (!compact)
            const SizedBox.square(
              dimension: 104,
              child: Orb(
                tint: OrbTints.mint,
                child: Icon(
                  Icons.volunteer_activism_rounded,
                  size: 46,
                  color: Palette.ink,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A titled row of products that scrolls sideways.
class ProductShelf extends StatelessWidget {
  const ProductShelf({
    required this.title,
    required this.note,
    required this.products,
    required this.onOpen,
    required this.keyPrefix,
    this.showDiscount = false,
    super.key,
  });

  final String title;
  final String note;
  final List<Product> products;
  final ValueChanged<Product> onOpen;

  /// Keeps the tiles of two shelves apart: the same product can be on both.
  final String keyPrefix;

  /// Puts the discount on each photo (for the deals shelf) instead of the rating.
  final bool showDiscount;

  static const double _photo = 148;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final textBlock =
        Gap.s +
        scaler.scale(14) * 1.5 +
        Gap.xs +
        scaler.scale(16) * 1.5 +
        scaler.scale(11) * 1.5 +
        Gap.s;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.s, bottom: Gap.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleLarge,
                ),
                Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          SizedBox(
            height: _photo + textBlock,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.l),
              itemCount: products.length,
              separatorBuilder: (_, _) => Gap.wm,
              itemBuilder: (context, index) => Reveal(
                key: ValueKey('$keyPrefix-${products[index].id}'),
                index: index,
                child: _ShelfTile(
                  product: products[index],
                  showDiscount: showDiscount,
                  onTap: () => onOpen(products[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({
    required this.product,
    required this.showDiscount,
    required this.onTap,
  });

  final Product product;
  final bool showDiscount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final price = Formatters.money(
      product.hasDiscount ? product.discountedPrice : product.price,
    );
    return SizedBox(
      width: ProductShelf._photo,
      child: PressableScale(
        onTap: onTap,
        semanticLabel: '${product.title}, $price',
        borderRadius: Radii.brL,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox.square(
                    dimension: ProductShelf._photo,
                    child: ProductOrb(
                      imageUrl: product.thumbnail,
                      tint: OrbTints.forCategory(product.category),
                      fallbackIcon: CategoryIcons.of(product.category),
                    ),
                  ),
                  Positioned(
                    left: Gap.s,
                    top: Gap.s,
                    child: showDiscount && product.hasDiscount
                        ? DiscountPill(percent: product.discountPercentage)
                        : _RatingChip(rating: product.rating),
                  ),
                  if (product.isAvailable)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: QuickAddButton(product: product),
                    ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                product.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge,
              ),
              const SizedBox(height: Gap.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        price,
                        style: AppTypography.price(colors.onSurface, size: 16),
                      ),
                    ),
                  ),
                  if (product.hasDiscount) ...[
                    Gap.ws,
                    Flexible(
                      child: Text(
                        Formatters.money(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small star-and-number chip that sits on a photo.
class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 15, color: context.shop.star),
            const SizedBox(width: 2),
            Text(
              Formatters.rating(math.max(0, rating)),
              style: context.text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
