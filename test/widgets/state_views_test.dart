import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/widgets/state_views.dart';
import 'package:shopsphere/l10n/generated/app_localizations_hi.dart';

import '../helpers/pump_app.dart';

void main() {
  group('ErrorView', () {
    testWidgets('says what went wrong and offers a retry', (tester) async {
      var retries = 0;
      await pumpApp(
        tester,
        ErrorView(failure: const NetworkFailure(), onRetry: () => retries++),
      );

      expect(find.text(en.errorNetworkTitle), findsOneWidget);
      expect(find.text(en.errorNetworkMessage), findsOneWidget);

      await tester.tap(find.text(en.retry));
      expect(retries, 1);
    });

    testWidgets('each kind of failure has its own wording', (tester) async {
      const failures = <Failure>[
        NetworkFailure(),
        TimeoutFailure(),
        ServerFailure(),
        NotFoundFailure(),
      ];
      final titles = <String>{};

      for (final failure in failures) {
        await pumpApp(tester, ErrorView(failure: failure));
        final text = tester.widgetList<Text>(find.byType(Text)).first.data;
        titles.add(text!);
      }

      expect(
        titles,
        hasLength(failures.length),
        reason: 'no two failures share a title',
      );
    });

    testWidgets('shows no retry button when there is nothing to retry', (
      tester,
    ) async {
      await pumpApp(tester, const ErrorView(failure: ServerFailure()));

      expect(find.text(en.retry), findsNothing);
    });

    testWidgets('a second action sits beside retry', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        ErrorView(
          failure: const NotFoundFailure(),
          onRetry: () {},
          secondaryLabel: 'Back to shop',
          onSecondary: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Back to shop'));

      expect(tapped, isTrue);
      expect(find.text(en.retry), findsOneWidget);
    });

    testWidgets('never overflows at 1.3x text on a small phone', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ErrorView(failure: const NetworkFailure(), onRetry: () {}),
        size: const Size(320, 568),
        textScale: 1.3,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('speaks Hindi when the app is in Hindi', (tester) async {
      await pumpApp(
        tester,
        ErrorView(failure: const NetworkFailure(), onRetry: () {}),
        locale: const Locale('hi'),
      );
      final hindi = AppLocalizationsHi();

      expect(find.text(hindi.errorNetworkTitle), findsOneWidget);
      expect(find.text(hindi.retry), findsOneWidget);
    });
  });

  group('EmptyView', () {
    testWidgets('invites the shopper to act', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        EmptyView(
          icon: Icons.search_off_rounded,
          title: 'Nothing here',
          message: 'Try another word.',
          actionLabel: 'Clear search',
          onAction: () => tapped = true,
        ),
      );

      expect(find.text('Nothing here'), findsOneWidget);
      await tester.tap(find.text('Clear search'));
      expect(tapped, isTrue);
    });

    testWidgets('an action needs both a label and a callback to appear', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const EmptyView(
          icon: Icons.inbox_rounded,
          title: 'Empty',
          message: 'Nothing yet.',
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
