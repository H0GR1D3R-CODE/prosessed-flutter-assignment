import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/widgets/resizable_split.dart';

import '../helpers/pump_app.dart';

/// Holds the collapsed flag the way a real page does.
class _Harness extends StatefulWidget {
  const _Harness({this.startCollapsed = false, this.overlay});

  final bool startCollapsed;
  final Widget? overlay;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late bool _collapsed = widget.startCollapsed;

  @override
  Widget build(BuildContext context) {
    return ResizableSplit(
      primary: const ColoredBox(color: Colors.white, child: Text('list')),
      secondary: const ColoredBox(
        color: Colors.black12,
        child: Text('details'),
      ),
      initialSecondaryWidth: 400,
      collapsed: _collapsed,
      onCollapsedChanged: (value) => setState(() => _collapsed = value),
      collapseTooltip: 'Hide panel',
      expandTooltip: 'Show panel',
      resizeLabel: 'Resize panel',
      collapsedOverlay: widget.overlay,
    );
  }
}

/// Drags the divider the way a finger does: grab a little below the middle (clear of the chevron
/// button), cross the touch slop, then keep moving. The first 20 px only start the drag, so the
/// width changes by `dx` minus 20 in either direction.
Future<void> _dragDivider(WidgetTester tester, double dx) async {
  final strip = find.byKey(const ValueKey('resize-handle'));
  final gesture = await tester.startGesture(
    tester.getTopLeft(strip) + const Offset(24, 160),
  );
  final step = 20 * dx.sign;
  await gesture.moveBy(Offset(step, 0));
  await tester.pump();
  await gesture.moveBy(Offset(dx - step, 0));
  await tester.pump();
  await gesture.up();
  // The divider also listens for a double tap, whose window must close before the test ends.
  await tester.pump(const Duration(milliseconds: 400));
}

double _secondaryWidth(WidgetTester tester) =>
    tester.getSize(find.byType(AnimatedContainer)).width;

/// An animation starts on the frame after the change, so pump once to start it, then let it run.
Future<void> _animate(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  const size = Size(1400, 800);

  testWidgets('shows both panes at the starting width', (tester) async {
    await pumpApp(tester, const _Harness(), size: size);

    expect(find.text('list'), findsOneWidget);
    expect(find.text('details'), findsOneWidget);
    expect(_secondaryWidth(tester), 400);
  });

  testWidgets('the chevron tucks the second pane away and brings it back', (
    tester,
  ) async {
    await pumpApp(tester, const _Harness(), size: size);

    await tester.tap(find.byTooltip('Hide panel'));
    await _animate(tester);
    expect(_secondaryWidth(tester), 0);
    expect(find.byTooltip('Show panel'), findsOneWidget);

    await tester.tap(find.byTooltip('Show panel'));
    await _animate(tester);
    expect(_secondaryWidth(tester), 400);
  });

  testWidgets('dragging the divider changes the width, within limits', (
    tester,
  ) async {
    await pumpApp(tester, const _Harness(), size: size);
    final handle = find.bySemanticsLabel('Resize panel');

    // Dragging left makes the second pane wider.
    await _dragDivider(tester, -120);
    expect(_secondaryWidth(tester), 500);

    // It never squeezes the list below its minimum, nor the panel below its own.
    await _dragDivider(tester, -2000);
    await tester.pump();
    expect(_secondaryWidth(tester), lessThanOrEqualTo(size.width - 360 - 48));
    await _dragDivider(tester, 3000);
    await tester.pump();
    expect(_secondaryWidth(tester), 320);
    expect(handle, findsOneWidget);
  });

  testWidgets('a double tap on the divider restores the starting width', (
    tester,
  ) async {
    await pumpApp(tester, const _Harness(), size: size);
    await _dragDivider(tester, -120);
    await tester.pump();
    expect(_secondaryWidth(tester), isNot(400));

    final strip = find.byKey(const ValueKey('resize-handle'));
    final spot = tester.getTopLeft(strip) + const Offset(24, 160);
    await tester.tapAt(spot);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(spot);
    await _animate(tester);

    expect(_secondaryWidth(tester), 400);
  });

  testWidgets('the overlay appears only while the panel is tucked away', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const _Harness(overlay: Text('Total and checkout')),
      size: size,
    );
    expect(find.text('Total and checkout'), findsNothing);

    await tester.tap(find.byTooltip('Hide panel'));
    await _animate(tester);
    expect(find.text('Total and checkout'), findsOneWidget);

    await tester.tap(find.byTooltip('Show panel'));
    await _animate(tester);
    expect(find.text('Total and checkout'), findsNothing);
  });

  testWidgets('starting collapsed shows the overlay straight away', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const _Harness(startCollapsed: true, overlay: Text('Total and checkout')),
      size: size,
    );
    await _animate(tester);

    expect(_secondaryWidth(tester), 0);
    expect(find.text('Total and checkout'), findsOneWidget);
  });

  testWidgets('the button is a full 48 dp target', (tester) async {
    await pumpApp(tester, const _Harness(), size: size);

    final box = tester.getSize(find.byKey(const ValueKey('collapse-toggle')));

    expect(box.width, greaterThanOrEqualTo(48));
    expect(box.height, greaterThanOrEqualTo(48));
  });
}
