import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/widgets/badges.dart';
import 'package:shopsphere/core/widgets/buttons.dart';
import 'package:shopsphere/core/widgets/quantity_stepper.dart';

import '../helpers/pump_app.dart';

void main() {
  group('QuantityStepper', () {
    Future<void> pumpStepper(
      WidgetTester tester, {
      required int value,
      required ValueChanged<int> onChanged,
      int min = 1,
      int max = 5,
    }) {
      return pumpApp(
        tester,
        Center(
          child: QuantityStepper(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      );
    }

    testWidgets('plus and minus move by one', (tester) async {
      final changes = <int>[];
      await pumpStepper(tester, value: 3, onChanged: changes.add);

      await tester.tap(find.byTooltip(en.increaseQuantity));
      await tester.tap(find.byTooltip(en.decreaseQuantity));

      expect(changes, [4, 2]);
    });

    testWidgets('minus is disabled at the minimum', (tester) async {
      final changes = <int>[];
      await pumpStepper(tester, value: 1, onChanged: changes.add);

      await tester.tap(
        find.byTooltip(en.decreaseQuantity),
        warnIfMissed: false,
      );

      expect(changes, isEmpty);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.remove_rounded),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('plus is disabled at the maximum (the stock)', (tester) async {
      final changes = <int>[];
      await pumpStepper(tester, value: 5, onChanged: changes.add);

      await tester.tap(
        find.byTooltip(en.increaseQuantity),
        warnIfMissed: false,
      );

      expect(changes, isEmpty);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.add_rounded),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('both buttons are at least 48 dp, so they are easy to hit', (
      tester,
    ) async {
      await pumpStepper(tester, value: 2, onChanged: (_) {});

      for (final tooltip in [en.increaseQuantity, en.decreaseQuantity]) {
        final size = tester.getSize(find.byTooltip(tooltip));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('screen readers get a value and increase/decrease actions', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpStepper(tester, value: 2, onChanged: (_) {});

      final data = tester
          .getSemantics(find.bySemanticsLabel(en.quantity))
          .getSemanticsData();

      expect(data.value, '2');
      expect(data.increasedValue, '3');
      expect(data.decreasedValue, '1');
      handle.dispose();
    });
  });

  group('AppButton', () {
    testWidgets('runs its action when tapped', (tester) async {
      var taps = 0;
      await pumpApp(
        tester,
        AppButton(label: 'Add to cart', onPressed: () => taps++),
      );

      await tester.tap(find.text('Add to cart'));

      expect(taps, 1);
    });

    testWidgets('while loading it shows a spinner and ignores taps', (
      tester,
    ) async {
      var taps = 0;
      await pumpApp(
        tester,
        AppButton(
          label: 'Place order',
          isLoading: true,
          onPressed: () => taps++,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);

      expect(taps, 0);
      expect(
        find.text('Place order'),
        findsNothing,
        reason: 'the label gives way to the spinner',
      );
    });

    testWidgets('without an action it is disabled', (tester) async {
      await pumpApp(tester, const AppButton(label: 'Sign in', onPressed: null));

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('a long label shrinks instead of overflowing', (tester) async {
      await pumpApp(
        tester,
        const SizedBox(
          width: 150,
          child: AppButton(label: 'Add to cart · \$1,299.99', onPressed: _noop),
        ),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('is at least 48 dp tall', (tester) async {
      await pumpApp(
        tester,
        const AppButton(label: 'Retry', onPressed: _noop, expanded: false),
      );

      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('badges', () {
    testWidgets('a discount rounds to a whole percent', (tester) async {
      await pumpApp(tester, const Center(child: DiscountPill(percent: 10.48)));

      expect(find.text('−10%'), findsOneWidget);
    });

    testWidgets('stock wording: plenty, low, none', (tester) async {
      Future<void> showStock(int stock, {bool available = true}) => pumpApp(
        tester,
        Center(
          child: StockBadge(stock: stock, isAvailable: available),
        ),
      );

      await showStock(40);
      expect(find.text(en.inStock), findsOneWidget);

      await showStock(3);
      expect(find.text(en.lowStock(3)), findsOneWidget);

      await showStock(0, available: false);
      expect(find.text(en.outOfStock), findsOneWidget);
    });

    testWidgets('the rating shows one decimal', (tester) async {
      await pumpApp(tester, const Center(child: RatingPill(rating: 4.56)));

      expect(find.text('4.6'), findsOneWidget);
    });
  });
}

void _noop() {}
