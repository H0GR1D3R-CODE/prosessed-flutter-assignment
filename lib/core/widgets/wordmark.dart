import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/app_typography.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';

/// The logo and the name, side by side.
class Wordmark extends StatelessWidget {
  const Wordmark({this.size = 22, this.color, this.background, super.key});

  /// Font size of the name; the logo scales with it.
  final double size;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? context.colors.onSurface;
    return Semantics(
      label: 'ShopSphere',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OrbitLogo(size: size * 2.1, background: background),
          SizedBox(width: size * 0.15),
          Text(
            'ShopSphere',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: -size * 0.04,
              color: ink,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
