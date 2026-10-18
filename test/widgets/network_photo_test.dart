import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/widgets/network_photo.dart';

import '../helpers/pump_app.dart';

Future<void> _letItFail(WidgetTester tester) async {
  // The failed request arrives on the real event loop; the retry waits run on the test clock.
  for (var round = 0; round < 8; round++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump(const Duration(seconds: 2));
  }
}

void main() {
  setUp(() {
    // A photo that is not a photo: decoding it fails, just like a request that never worked.
    NetworkPhoto.imageProviderForTesting = (_) => MemoryImage(Uint8List(0));
  });
  tearDown(() => NetworkPhoto.imageProviderForTesting = null);

  testWidgets(
    'a photo that cannot load ends on a reload tile, not a broken image',
    (tester) async {
      await pumpApp(
        tester,
        const SizedBox.square(
          dimension: 200,
          child: NetworkPhoto(
            url: 'https://cdn.example.test/missing.webp',
            fallbackIcon: Icons.face_retouching_natural_rounded,
          ),
        ),
      );

      await _letItFail(tester);

      expect(find.text(en.photoReload), findsOneWidget);
      expect(
        find.byIcon(Icons.face_retouching_natural_rounded),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
    },
  );

  testWidgets('tapping the tile tries again', (tester) async {
    await pumpApp(
      tester,
      const SizedBox.square(
        dimension: 200,
        child: NetworkPhoto(url: 'https://cdn.example.test/missing.webp'),
      ),
    );
    await _letItFail(tester);
    expect(find.text(en.photoReload), findsOneWidget);

    await tester.tap(find.text(en.photoReload));
    await tester.pump();

    expect(find.text(en.photoReload), findsNothing, reason: 'loading again');
    await _letItFail(tester);
    expect(find.text(en.photoReload), findsOneWidget);
  });

  testWidgets('a small photo shows only the icon, which is still tappable', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const Center(
        child: SizedBox.square(
          dimension: 64,
          child: NetworkPhoto(url: 'https://cdn.example.test/missing.webp'),
        ),
      ),
    );
    await _letItFail(tester);

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.text(en.photoReload), findsNothing);
    expect(find.bySemanticsLabel(en.photoReload), findsOneWidget);
  });

  testWidgets('an avatar falls back to what it is given, such as initials', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const SizedBox.square(
        dimension: 84,
        child: NetworkPhoto(
          url: 'https://cdn.example.test/missing.png',
          placeholder: Center(child: Text('EJ')),
          fallback: Center(child: Text('EJ')),
        ),
      ),
    );

    await _letItFail(tester);

    expect(find.text('EJ'), findsOneWidget);
    expect(find.text(en.photoReload), findsNothing);
  });
}
