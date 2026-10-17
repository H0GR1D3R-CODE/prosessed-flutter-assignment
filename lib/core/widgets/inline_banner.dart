import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/theme/spacing.dart';

enum BannerTone { info, warning, error }

/// A short message inside a screen: a notice, a warning or a recoverable error.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    required this.message,
    this.icon,
    this.tone = BannerTone.info,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData? icon;
  final BannerTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shop = context.shop;
    final (
      Color background,
      Color border,
      Color foreground,
      Color accent,
    ) = switch (tone) {
      BannerTone.error => (
        colors.errorContainer,
        colors.error,
        colors.onErrorContainer,
        colors.error,
      ),
      BannerTone.warning => (
        colors.surfaceContainerLowest,
        shop.star,
        colors.onSurface,
        shop.warning,
      ),
      BannerTone.info => (
        colors.surfaceContainerLowest,
        colors.outlineVariant,
        colors.onSurface,
        colors.onSurfaceVariant,
      ),
    };
    final resolvedIcon =
        icon ??
        switch (tone) {
          BannerTone.error => Icons.error_outline_rounded,
          BannerTone.warning => Icons.wifi_off_rounded,
          BannerTone.info => Icons.info_outline_rounded,
        };

    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: Radii.brM,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.m,
            vertical: Gap.s,
          ),
          child: Row(
            children: [
              Icon(resolvedIcon, color: accent),
              Gap.wm,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xs),
                  child: Text(
                    message,
                    style: context.text.bodyMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
        ),
      ),
    );
  }
}
