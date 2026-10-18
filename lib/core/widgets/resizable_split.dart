import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopsphere/core/theme/app_theme.dart';

/// Two panes side by side with a divider you can drag, and a button that tucks the second pane
/// away and brings it back.
///
/// The second pane keeps its width while it slides, so its content never reflows mid-animation.
class ResizableSplit extends StatefulWidget {
  const ResizableSplit({
    required this.primary,
    required this.secondary,
    required this.collapseTooltip,
    required this.expandTooltip,
    required this.resizeLabel,
    this.initialSecondaryWidth = 460,
    this.minSecondaryWidth = 320,
    this.minPrimaryWidth = 360,
    this.collapsed = false,
    this.onCollapsedChanged,
    this.collapsedOverlay,
    super.key,
  });

  final Widget primary;
  final Widget secondary;

  /// Width the second pane starts at (and returns to on a double tap of the divider).
  final double initialSecondaryWidth;
  final double minSecondaryWidth;
  final double minPrimaryWidth;

  final bool collapsed;
  final ValueChanged<bool>? onCollapsedChanged;

  /// Floats at the bottom of the first pane while the second is tucked away, for something that
  /// must stay reachable (the cart's total and checkout button).
  final Widget? collapsedOverlay;

  final String collapseTooltip;
  final String expandTooltip;
  final String resizeLabel;

  @override
  State<ResizableSplit> createState() => _ResizableSplitState();
}

class _ResizableSplitState extends State<ResizableSplit> {
  static const double _handleWidth = 48;

  late double _secondaryWidth = widget.initialSecondaryWidth;
  bool _dragging = false;

  double _maxSecondary(double total) => math.max(
    widget.minSecondaryWidth,
    total - widget.minPrimaryWidth - _handleWidth,
  );

  double _clamped(double total) =>
      _secondaryWidth.clamp(widget.minSecondaryWidth, _maxSecondary(total));

  void _toggle() {
    HapticFeedback.selectionClick();
    widget.onCollapsedChanged?.call(!widget.collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        final width = _clamped(total);
        final target = widget.collapsed ? 0.0 : width;
        final animate = !_dragging && !reduceMotion;

        return Stack(
          children: [
            Row(
              // Stretch, so the divider runs the full height rather than just the button's.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: widget.primary),
                _Handle(
                  collapsed: widget.collapsed,
                  tooltip: widget.collapsed
                      ? widget.expandTooltip
                      : widget.collapseTooltip,
                  resizeLabel: widget.resizeLabel,
                  onToggle: _toggle,
                  onDragStart: () => setState(() => _dragging = true),
                  onDrag: (dx) {
                    if (widget.collapsed) return;
                    setState(() {
                      _secondaryWidth = (width - dx).clamp(
                        widget.minSecondaryWidth,
                        _maxSecondary(total),
                      );
                    });
                  },
                  onDragEnd: () => setState(() => _dragging = false),
                  onReset: () => setState(() {
                    _secondaryWidth = widget.initialSecondaryWidth;
                  }),
                ),
                AnimatedContainer(
                  duration: animate
                      ? const Duration(milliseconds: 320)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  width: target,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: width,
                      maxWidth: width,
                      child: ExcludeFocus(
                        excluding: widget.collapsed,
                        child: widget.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.collapsedOverlay != null)
              Positioned(
                left: 0,
                right: _handleWidth,
                bottom: 16,
                child: IgnorePointer(
                  ignoring: !widget.collapsed,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: widget.collapsed
                        ? Center(
                            key: const ValueKey('overlay'),
                            child: widget.collapsedOverlay,
                          )
                        : const SizedBox.shrink(key: ValueKey('none')),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({
    required this.collapsed,
    required this.tooltip,
    required this.resizeLabel,
    required this.onToggle,
    required this.onDragStart,
    required this.onDrag,
    required this.onDragEnd,
    required this.onReset,
  });

  final bool collapsed;
  final String tooltip;
  final String resizeLabel;
  final VoidCallback onToggle;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: _ResizableSplitState._handleWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The draggable strip, full height, with a thin line down the middle.
          Positioned.fill(
            child: Semantics(
              label: resizeLabel,
              child: MouseRegion(
                cursor: collapsed
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  key: const ValueKey('resize-handle'),
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (_) => onDragStart(),
                  onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
                  onHorizontalDragEnd: (_) => onDragEnd(),
                  onHorizontalDragCancel: onDragEnd,
                  onDoubleTap: collapsed ? null : onReset,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: colors.outlineVariant),
                      child: const SizedBox(width: 1, height: double.infinity),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The button that tucks the second pane away. A full 48 dp target around a smaller disc.
          Tooltip(
            message: tooltip,
            child: Semantics(
              button: true,
              label: tooltip,
              excludeSemantics: true,
              child: InkResponse(
                key: const ValueKey('collapse-toggle'),
                onTap: onToggle,
                radius: 26,
                child: SizedBox.square(
                  dimension: 48,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(alpha: 0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SizedBox.square(
                        dimension: 34,
                        child: AnimatedRotation(
                          turns: collapsed ? 0.5 : 0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
