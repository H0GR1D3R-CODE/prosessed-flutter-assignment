import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/domain/showcase.dart';

import '../../../helpers/builders.dart';

void main() {
  group('Showcase.deals', () {
    test('puts the biggest discounts first', () {
      final deals = Showcase.deals([
        buildProduct(id: 1, discount: 5),
        buildProduct(id: 2, discount: 30),
        buildProduct(id: 3, discount: 12),
      ]);

      expect(deals.map((p) => p.id), [2, 3, 1]);
    });

    test('leaves out products with no real discount or none in stock', () {
      final deals = Showcase.deals([
        buildProduct(id: 1),
        buildProduct(id: 2, discount: 0.4),
        buildProduct(id: 3, discount: 20, stock: 0),
        buildProduct(id: 4, discount: 20, availability: 'Out of Stock'),
        buildProduct(id: 5, discount: 8),
      ]);

      expect(deals.map((p) => p.id), [5]);
    });

    test('equal discounts keep the order of the list', () {
      final deals = Showcase.deals([
        for (var id = 1; id <= 5; id++) buildProduct(id: id, discount: 10),
      ]);

      expect(deals.map((p) => p.id), [1, 2, 3, 4, 5]);
    });

    test('a shelf holds at most eight products', () {
      final deals = Showcase.deals([
        for (var id = 1; id <= 20; id++) buildProduct(id: id, discount: id + 1),
      ]);

      expect(deals, hasLength(Showcase.shelfSize));
      expect(deals.first.id, 20);
    });
  });

  group('Showcase.topRated', () {
    test('lists the best rated first, and only from 4.0 up', () {
      final top = Showcase.topRated([
        buildProduct(id: 1, rating: 3.9),
        buildProduct(id: 2, rating: 4.4),
        buildProduct(id: 3, rating: 4.9),
        buildProduct(id: 4, rating: 4.0),
      ]);

      expect(top.map((p) => p.id), [3, 2, 4]);
    });

    test('skips what cannot be bought', () {
      final top = Showcase.topRated([
        buildProduct(id: 1, rating: 5, stock: 0),
        buildProduct(id: 2, rating: 4.1),
      ]);

      expect(top.map((p) => p.id), [2]);
    });
  });

  test('a shelf with fewer than three products is not worth showing', () {
    expect(
      Showcase.worthShowing([buildProduct(id: 1), buildProduct(id: 2)]),
      isFalse,
    );
    expect(
      Showcase.worthShowing([
        for (var id = 1; id <= 3; id++) buildProduct(id: id),
      ]),
      isTrue,
    );
  });
}
