import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/utils/json_reader.dart';

void main() {
  group('JsonReader', () {
    final json = <String, dynamic>{
      'name': 'Orb',
      'count': 3,
      'price': 9.5,
      'tags': ['a', 'b', 7],
      'items': [
        {'id': 1},
        {'id': 2},
      ],
    };

    test('reads typed values', () {
      expect(json.string('name'), 'Orb');
      expect(json.integer('count'), 3);
      expect(json.decimal('price'), 9.5);
      expect(
        json.decimal('count'),
        3.0,
        reason: 'ints are accepted as numbers',
      );
    });

    test('a missing or wrong-typed required value names the key', () {
      expect(
        () => json.string('count'),
        throwsA(
          isA<ParseException>().having(
            (e) => e.message,
            'message',
            contains('"count"'),
          ),
        ),
      );
      expect(() => json.integer('missing'), throwsA(isA<ParseException>()));
    });

    test('optional readers fall back instead of throwing', () {
      expect(json.stringOrNull('count'), isNull);
      expect(json.integerOr('missing', 5), 5);
      expect(json.decimalOr('name', 1.5), 1.5);
      expect(json.decimalOrNull('missing'), isNull);
    });

    test('lists: a missing key is empty and non-strings are skipped', () {
      expect(json.strings('missing'), isEmpty);
      expect(json.strings('tags'), ['a', 'b']);
      expect(json.objects('items', (m) => m.integer('id')), [1, 2]);
      expect(json.objects('missing', (m) => m), isEmpty);
    });

    test('asJsonMap rejects anything that is not an object', () {
      expect(() => asJsonMap([1, 2]), throwsA(isA<ParseException>()));
      expect(asJsonMap(<String, dynamic>{'a': 1}), {'a': 1});
    });
  });
}
