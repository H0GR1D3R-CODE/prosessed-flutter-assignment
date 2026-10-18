import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// How a full-screen page arrives. Each one says something about where the user is going.
enum ShopTransition {
  /// Rises into place: a product opening out of the list.
  rise,

  /// Slides in from the side while the page underneath eases away: the next step of a flow.
  slide,

  /// Grows from just under full size: a moment worth marking, like an order going through.
  zoom,

  /// A plain cross-fade: moving between signed-out screens.
  fade,
}

/// A page that uses one of the app's transitions. With reduced motion the page simply appears.
CustomTransitionPage<T> shopPage<T>({
  required GoRouterState state,
  required Widget child,
  ShopTransition transition = ShopTransition.fade,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return switch (transition) {
        ShopTransition.rise => _rise(animation, secondaryAnimation, child),
        ShopTransition.slide => _slide(animation, secondaryAnimation, child),
        ShopTransition.zoom => _zoom(animation, child),
        ShopTransition.fade => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      };
    },
  );
}

Widget _rise(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final enter = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    ),
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(enter),
      child: ScaleTransition(
        scale: Tween(begin: 0.985, end: 1.0).animate(enter),
        child: child,
      ),
    ),
  );
}

Widget _slide(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final enter = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final away = CurvedAnimation(
    parent: secondaryAnimation,
    curve: Curves.easeInOutCubic,
  );
  // When another page covers this one, it drifts left and dims a little.
  return SlideTransition(
    position: Tween(
      begin: Offset.zero,
      end: const Offset(-0.06, 0),
    ).animate(away),
    child: FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.7).animate(away),
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(enter),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.75, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    ),
  );
}

Widget _zoom(Animation<double> animation, Widget child) {
  final enter = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeIn,
  );
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
    child: ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.0).animate(enter),
      child: child,
    ),
  );
}

/// Keeps every tab alive like an indexed stack, but fades the old one out and the new one in
/// with a slight rise, instead of snapping between them.
class FadingBranches extends StatelessWidget {
  const FadingBranches({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          _FadingBranch(active: i == currentIndex, child: children[i]),
      ],
    );
  }
}

class _FadingBranch extends StatefulWidget {
  const _FadingBranch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_FadingBranch> createState() => _FadingBranchState();
}

class _FadingBranchState extends State<_FadingBranch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    value: widget.active ? 1 : 0,
  );

  @override
  void didUpdateWidget(_FadingBranch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.active ? 1 : 0;
    } else if (widget.active) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final eased = Curves.easeOutCubic.transform(_controller.value);
        return Offstage(
          offstage: _controller.isDismissed,
          // A tab that is out of sight should not keep animating or take taps.
          child: TickerMode(
            enabled: !_controller.isDismissed,
            child: IgnorePointer(
              ignoring: !widget.active,
              child: Opacity(
                opacity: _controller.value,
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - eased)),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
