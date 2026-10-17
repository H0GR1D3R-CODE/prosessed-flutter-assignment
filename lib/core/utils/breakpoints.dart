import 'package:flutter/widgets.dart';

/// The three layout classes the brief asks for.
enum WindowSize {
  /// Phones: under 600 dp. Bottom navigation, two-column grid.
  compact,

  /// Small tablets and large phones in landscape: 600 to 1024 dp. Navigation rail.
  medium,

  /// Tablets in landscape and desktop windows: over 1024 dp. List and detail side by side.
  expanded;

  bool get isCompact => this == WindowSize.compact;
  bool get isExpanded => this == WindowSize.expanded;
}

abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 1024;

  static WindowSize of(double width) {
    if (width < medium) return WindowSize.compact;
    if (width <= expanded) return WindowSize.medium;
    return WindowSize.expanded;
  }

  /// How many product columns fit in [width]: two on a phone, then one more for every ~190 dp.
  static int gridColumns(double width) => (width / 190).floor().clamp(2, 6);
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize => Breakpoints.of(MediaQuery.sizeOf(this).width);
}
