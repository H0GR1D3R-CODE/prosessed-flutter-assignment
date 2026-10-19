import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Fades and lifts its child in as it first appears. Children that scroll into view later do the
/// same, and [index] staggers siblings, which gives a list a gentle cascade without a separate
/// animation system.
///
/// The stagger is a delay inside one animation rather than a timer, so nothing is left pending
/// when the widget goes away.
class Reveal extends StatefulWidget {
  const Reveal({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  static const int _stepMs = 35;
  static const int _riseMs = 320;

  late final int _delayMs = _stepMs * math.min(widget.index, 8);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delayMs + _riseMs),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Interval(_delayMs / (_delayMs + _riseMs), 1, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            _delayMs / (_delayMs + _riseMs),
            1,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
