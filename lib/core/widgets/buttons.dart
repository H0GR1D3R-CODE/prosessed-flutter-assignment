import 'package:flutter/material.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/core/widgets/orbit_logo.dart';

enum AppButtonKind {
  /// Ink on light, volt on dark: the default action.
  primary,

  /// Volt with ink text: the one action a screen is built around (add to cart, place order).
  accent,

  /// Outlined: a secondary choice.
  outline,
}

/// The app's button. Shows the orbit spinner while [isLoading] and ignores taps until it ends.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = AppButtonKind.primary,
    this.isLoading = false,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonKind kind;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shop = context.shop;
    final enabled = onPressed != null && !isLoading;

    final Color foreground = switch (kind) {
      AppButtonKind.primary => colors.onPrimary,
      AppButtonKind.accent => shop.onVolt,
      AppButtonKind.outline => colors.onSurface,
    };

    final content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? OrbitSpinner(
              key: const ValueKey('loading'),
              size: 26,
              color: foreground,
              background: switch (kind) {
                AppButtonKind.primary => colors.primary,
                AppButtonKind.accent => shop.volt,
                AppButtonKind.outline => colors.surface,
              },
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    final button = switch (kind) {
      AppButtonKind.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        child: content,
      ),
      AppButtonKind.accent => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: shop.volt,
          foregroundColor: shop.onVolt,
        ),
        child: content,
      ),
      AppButtonKind.outline => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        child: content,
      ),
    };

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

/// Shrinks its child slightly while pressed, so cards feel like they are being pushed in.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: _pressed && !reduceMotion ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: widget.child,
        ),
      ),
    );
  }
}
