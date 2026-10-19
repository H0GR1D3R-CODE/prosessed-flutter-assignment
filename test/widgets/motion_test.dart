import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/router/transitions.dart';
import 'package:shopsphere/core/widgets/animated_money.dart';
import 'package:shopsphere/core/widgets/fly_to_cart.dart';
import 'package:shopsphere/core/widgets/reveal.dart';

import '../helpers/pump_app.dart';

/// Reduced motion, as the system setting would give it.
Widget _reducedMotion(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

/// How visible each [Reveal] is right now, in the order they appear.
List<double> _opacities(WidgetTester tester) => tester
    .widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(Reveal),
        matching: find.byType(FadeTransition),
      ),
    )
    .map((fade) => fade.opacity.value)
    .toList();

void main() {
  group('FlyToCart', () {
    final from = GlobalKey();

    Widget scene({required bool withCartIcon}) => Stack(
      children: [
        Positioned(
          left: 40,
          top: 60,
          child: SizedBox.square(key: from, dimension: 48),
        ),
        if (withCartIcon)
          Positioned(
            left: 300,
            top: 600,
            child: SizedBox.square(key: cartIconKey, dimension: 24),
          ),
        Builder(
          builder: (context) => Positioned(
            left: 100,
            top: 300,
            child: ElevatedButton(
              onPressed: () => FlyToCart.play(context, from: from),
              child: const Text('add'),
            ),
          ),
        ),
      ],
    );

    testWidgets('an orb flies from the button to the cart tab, then goes', (
      tester,
    ) async {
      await pumpApp(tester, scene(withCartIcon: true));
      await tester.tap(find.text('add'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.shopping_bag_rounded), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
    });

    testWidgets('it does nothing when the cart tab is not on screen', (
      tester,
    ) async {
      await pumpApp(tester, scene(withCartIcon: false));
      await tester.tap(find.text('add'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
    });

    testWidgets('it stays still when the system asks for reduced motion', (
      tester,
    ) async {
      await pumpApp(tester, _reducedMotion(scene(withCartIcon: true)));
      await tester.tap(find.text('add'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
    });
  });

  group('AnimatedMoney', () {
    Widget money(double value) => Center(
      child: AnimatedMoney(value: value, prefix: '−'),
    );

    testWidgets('starts on its value and rolls to a new one', (tester) async {
      await pumpApp(tester, money(10));
      expect(find.text('−\$10.00'), findsOneWidget);

      await pumpApp(tester, money(30));
      await tester.pump(const Duration(milliseconds: 150));
      final text = tester.widget<Text>(find.byType(Text)).data!;
      final shown = double.parse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
      expect(shown, inInclusiveRange(10.0, 30.0));
      expect(shown, isNot(10.0), reason: 'it has started to move');

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('−\$30.00'), findsOneWidget);
    });

    testWidgets('jumps straight there with reduced motion', (tester) async {
      await pumpApp(tester, _reducedMotion(money(10)));
      await pumpApp(tester, _reducedMotion(money(30)));
      await tester.pump();

      expect(find.text('−\$30.00'), findsOneWidget);
    });
  });

  group('Reveal', () {
    testWidgets('fades its child in', (tester) async {
      // Index 5 waits about 175 ms, so the start is still visible after the first frame.
      await pumpApp(tester, const Reveal(index: 5, child: Text('card')));
      expect(_opacities(tester), [0]);

      await tester.pump(const Duration(milliseconds: 600));

      expect(_opacities(tester), [1]);
      expect(find.text('card'), findsOneWidget);
    });

    testWidgets('later siblings wait a little longer', (tester) async {
      await pumpApp(
        tester,
        const Column(
          children: [
            Reveal(index: 0, child: Text('first')),
            Reveal(index: 6, child: Text('seventh')),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final started = _opacities(tester);
      expect(started.first, greaterThan(0), reason: 'the first has begun');
      expect(started.last, 0, reason: 'the seventh is still waiting');

      await tester.pump(const Duration(milliseconds: 600));
      expect(_opacities(tester).every((opacity) => opacity == 1), isTrue);
    });

    testWidgets('shows at once with reduced motion', (tester) async {
      await pumpApp(
        tester,
        _reducedMotion(const Reveal(index: 5, child: Text('card'))),
      );

      expect(_opacities(tester), [1]);
    });
  });

  group('FadingBranches', () {
    Widget branches(int index) => FadingBranches(
      currentIndex: index,
      children: const [
        _Counter(label: 'one'),
        _Counter(label: 'two'),
      ],
    );

    testWidgets('shows only the current tab once the fade is over', (
      tester,
    ) async {
      await pumpApp(tester, branches(0));
      expect(find.text('one 0'), findsOneWidget);
      expect(find.text('two 0'), findsNothing, reason: 'out of sight');

      await pumpApp(tester, branches(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('two 0'), findsOneWidget);
      expect(find.text('one 0'), findsNothing);
    });

    testWidgets('a tab keeps its state while another is showing', (
      tester,
    ) async {
      await pumpApp(tester, branches(0));
      await tester.tap(find.text('one 0'));
      await tester.pump();
      expect(find.text('one 1'), findsOneWidget);

      await pumpApp(tester, branches(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await pumpApp(tester, branches(0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('one 1'), findsOneWidget, reason: 'the count survived');
    });

    testWidgets('a hidden tab cannot be tapped', (tester) async {
      await pumpApp(tester, branches(1));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('one 0', skipOffstage: false), findsOneWidget);
      expect(find.text('one 0'), findsNothing);
    });
  });
}

/// A tab with some state of its own: tapping it counts.
class _Counter extends StatefulWidget {
  const _Counter({required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => _taps++),
        child: Text('${widget.label} $_taps'),
      ),
    );
  }
}
