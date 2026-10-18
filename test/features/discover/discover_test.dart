import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/discover/data/discover_repositories.dart';
import 'package:shopsphere/features/discover/domain/discover.dart';
import 'package:shopsphere/features/discover/presentation/bloc/discover_cubits.dart';

import '../../helpers/builders.dart';

void main() {
  group('SearchHistory rules', () {
    test('the newest word goes first', () {
      expect(SearchHistory.record(['phone'], 'lamp'), ['lamp', 'phone']);
    });

    test('a repeat moves to the front instead of appearing twice', () {
      final updated = SearchHistory.record(['lamp', 'phone'], 'Phone');

      expect(updated, ['Phone', 'lamp']);
    });

    test('words are tidied up, and too-short ones are ignored', () {
      expect(SearchHistory.record([], '  red   lipstick '), ['red lipstick']);
      expect(SearchHistory.record(['phone'], ' a '), ['phone']);
      expect(SearchHistory.record(['phone'], '   '), ['phone']);
    });

    test('only the latest few are kept', () {
      var history = <String>[];
      for (var i = 0; i < 12; i++) {
        history = SearchHistory.record(history, 'word $i');
      }

      expect(history, hasLength(SearchHistory.capacity));
      expect(history.first, 'word 11');
      expect(history, isNot(contains('word 0')));
    });

    test('forgetting a word ignores case', () {
      expect(SearchHistory.forget(['Phone', 'lamp'], 'phone'), ['lamp']);
    });

    test(
      'suggestions: everything when nothing is typed, then what contains it',
      () {
        const history = ['red lipstick', 'phone case', 'Phone'];

        expect(SearchHistory.matching(history, ''), history);
        expect(SearchHistory.matching(history, 'phon'), [
          'phone case',
          'Phone',
        ]);
        expect(SearchHistory.matching(history, 'phone'), [
          'phone case',
        ], reason: 'a word equal to what is typed is not worth suggesting');
        expect(SearchHistory.matching(history, 'zzz'), isEmpty);
      },
    );
  });

  group('RecentlyViewed rules', () {
    test('the newest goes first and a repeat is not listed twice', () {
      final a = buildProduct(id: 1);
      final b = buildProduct(id: 2);

      final updated = RecentlyViewed.record(RecentlyViewed.record([], a), b);
      expect(updated.map((p) => p.id), [2, 1]);

      expect(RecentlyViewed.record(updated, a).map((p) => p.id), [1, 2]);
    });

    test('only the latest few are kept', () {
      var viewed = <dynamic>[];
      for (var i = 1; i <= 20; i++) {
        viewed = RecentlyViewed.record(
          List.of(viewed.cast()),
          buildProduct(id: i),
        );
      }

      expect(viewed, hasLength(RecentlyViewed.capacity));
    });
  });

  group('stored on the device', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('search words survive a restart and belong to one user', () async {
      await PrefsSearchHistoryRepository(prefs).save(1, ['phone', 'lamp']);

      final restarted = PrefsSearchHistoryRepository(prefs);
      expect(await restarted.load(1), ['phone', 'lamp']);
      expect(await restarted.load(2), isEmpty);
    });

    test(
      'a damaged search list is dropped instead of blocking search',
      () async {
        SharedPreferences.setMockInitialValues({'search.history.1': '{broken'});
        prefs = await SharedPreferences.getInstance();

        expect(await PrefsSearchHistoryRepository(prefs).load(1), isEmpty);
        expect(prefs.containsKey('search.history.1'), isFalse);
      },
    );

    test('viewed products keep their details, per user', () async {
      final repository = PrefsRecentlyViewedRepository(prefs);
      await repository.save(1, [
        buildProduct(id: 7, title: 'Kettle', price: 30, discount: 10),
      ]);

      final loaded = await PrefsRecentlyViewedRepository(prefs).load(1);
      expect(loaded.single.title, 'Kettle');
      expect(loaded.single.discountPercentage, 10);
      expect(await repository.load(2), isEmpty);
    });

    test(
      'a damaged viewed list is dropped instead of blocking browsing',
      () async {
        SharedPreferences.setMockInitialValues({'viewed.products.1': 'nope'});
        prefs = await SharedPreferences.getInstance();

        expect(await PrefsRecentlyViewedRepository(prefs).load(1), isEmpty);
        expect(prefs.containsKey('viewed.products.1'), isFalse);
      },
    );
  });

  group('SearchHistoryCubit', () {
    late PrefsSearchHistoryRepository repository;
    late SearchHistoryCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = PrefsSearchHistoryRepository(
        await SharedPreferences.getInstance(),
      );
      cubit = SearchHistoryCubit(
        load: LoadSearchHistoryUseCase(repository),
        record: RecordSearchUseCase(repository),
        forget: ForgetSearchUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('records, forgets and clears, saving each change', () async {
      await cubit.load(1);

      await cubit.record('phone');
      await cubit.record('lamp');
      expect(cubit.state.terms, ['lamp', 'phone']);
      expect(await repository.load(1), ['lamp', 'phone']);

      await cubit.forget('lamp');
      expect(cubit.state.terms, ['phone']);

      await cubit.clear();
      expect(cubit.state.terms, isEmpty);
      expect(await repository.load(1), isEmpty);
    });

    test(
      'nothing is remembered while signed out, and unload puts it away',
      () async {
        await cubit.record('phone');
        expect(cubit.state.terms, isEmpty);

        await cubit.load(1);
        await cubit.record('phone');
        cubit.unload();

        expect(cubit.state.terms, isEmpty);
        expect(await repository.load(1), [
          'phone',
        ], reason: 'still saved for next time');
      },
    );

    test('loading another user shows that user\'s words', () async {
      await repository.save(1, ['phone']);
      await repository.save(2, ['lamp']);

      await cubit.load(1);
      await cubit.load(2);

      expect(cubit.state.terms, ['lamp']);
    });
  });

  group('RecentlyViewedCubit', () {
    late PrefsRecentlyViewedRepository repository;
    late RecentlyViewedCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = PrefsRecentlyViewedRepository(
        await SharedPreferences.getInstance(),
      );
      cubit = RecentlyViewedCubit(
        load: LoadRecentlyViewedUseCase(repository),
        record: RecordViewedUseCase(repository),
        clear: ClearRecentlyViewedUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test('records products, newest first, and can be cleared', () async {
      await cubit.load(1);

      await cubit.record(buildProduct(id: 1));
      await cubit.record(buildProduct(id: 2));
      expect(cubit.state.products.map((p) => p.id), [2, 1]);
      expect((await repository.load(1)).map((p) => p.id), [2, 1]);

      await cubit.clear();
      expect(cubit.state.products, isEmpty);
      expect(await repository.load(1), isEmpty);
    });

    test('nothing is recorded while signed out', () async {
      await cubit.record(buildProduct());

      expect(cubit.state.products, isEmpty);
    });

    test('a restart brings the shelf back', () async {
      await cubit.load(1);
      await cubit.record(buildProduct(id: 5, title: 'Lamp'));

      final restarted = RecentlyViewedCubit(
        load: LoadRecentlyViewedUseCase(repository),
        record: RecordViewedUseCase(repository),
        clear: ClearRecentlyViewedUseCase(repository),
      );
      await restarted.load(1);

      expect(restarted.state.products.single.title, 'Lamp');
      await restarted.close();
    });
  });
}
