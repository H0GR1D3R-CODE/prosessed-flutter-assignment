import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Fades and lifts its child in as it first appears. Children that scroll into view later do the
/// same, and [index] staggers siblings, which gives a list a gentle cascade without a separate
/// animation system.
class Reveal extends StatefulWidget {
  const Reveal({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _shown = true;
      return;
    }
    Future<void>.delayed(
      Duration(milliseconds: 35 * math.min(widget.index, 8)),
      () {
        if (mounted) setState(() => _shown = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : const Offset(0, 0.04),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
