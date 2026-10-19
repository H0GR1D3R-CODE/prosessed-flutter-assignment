import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';

/// A product title inside the main grid. The home page can show the same product again on a
/// shelf above it, so a bare `find.text(title)` may match more than once.
Finder inGrid(String title) =>
    find.descendant(of: find.byType(ProductCard), matching: find.text(title));

/// The home page opens with offers and shelves. This scrolls the shop down until the first
/// product of the main grid is on screen.
Future<void> scrollToGrid(WidgetTester tester) async {
  final list = find.byType(Scrollable).first;
  for (var i = 0; i < 12 && find.byType(ProductCard).evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.ensureVisible(find.byType(ProductCard).first);
  await tester.pump(const Duration(milliseconds: 300));
}
