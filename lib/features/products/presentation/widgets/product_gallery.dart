import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/orb_tints.dart';
import 'package:shopsphere/core/widgets/network_photo.dart';
import 'package:shopsphere/core/widgets/studio_backdrop.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/l10n/l10n.dart';

/// The photo carousel at the top of the details page: swipeable photos floating over a large
/// orb, with a page indicator.
class ProductGallery extends StatefulWidget {
  const ProductGallery({
    required this.product,
    this.heroTag,
    this.leading,
    this.trailing,
    super.key,
  });

  final Product product;

  /// When set, the first photo flies in from the card it was tapped on.
  final Object? heroTag;

  /// Controls overlaid on the top corners (back button, heart).
  final Widget? leading;
  final Widget? trailing;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final photos = product.gallery;
    final tint = OrbTints.forCategory(product.category)
        .forBrightness(context.theme.brightness);
    final top = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(constraints.maxWidth * 0.94, 440.0);
        return SizedBox(
          height: height + top,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tint.light.withValues(alpha: 0.42),
                        context.colors.surface,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: top,
                height: height,
                child: Semantics(
                  image: true,
                  label: context.l10n.productGallery(_page + 1, photos.length),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: StudioBackdrop(
                          tint: OrbTints.forCategory(product.category),
                          paintBackground: false,
                          floorY: 0.84,
                          floorWidth: 0.46,
                        ),
                      ),
                      PageView.builder(
                        controller: _pages,
                        itemCount: photos.length,
                        onPageChanged: (index) => setState(() => _page = index),
                        itemBuilder: (context, index) {
                          Widget image = Padding(
                            padding: EdgeInsets.fromLTRB(
                              height * 0.07,
                              height * 0.05,
                              height * 0.07,
                              height * 0.14,
                            ),
                            child: NetworkPhoto(
                              url: photos[index],
                              memCacheWidth: 1000,
                              fallbackIcon: CategoryIcons.of(
                                widget.product.category,
                              ),
                            ),
                          );
                          if (index == 0 && widget.heroTag != null) {
                            image = Hero(tag: widget.heroTag!, child: image);
                          }
                          return image;
                        },
                      ),
                      if (photos.length > 1)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 12,
                          child: _Dots(count: photos.length, index: _page),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.leading != null)
                Positioned(left: 8, top: top + 8, child: widget.leading!),
              if (widget.trailing != null)
                Positioned(right: 8, top: top + 8, child: widget.trailing!),
            ],
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index
                    ? colors.onSurface
                    : colors.onSurface.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ],
      ),
    );
  }
}

/// A round button that sits on top of the gallery photo.
class RoundOverlayButton extends StatelessWidget {
  const RoundOverlayButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onPressed,
          radius: 28,
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surfaceContainerLowest.withValues(
                    alpha: 0.9,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(icon, size: 22, color: context.colors.onSurface),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
