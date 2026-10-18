import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/features/settings/data/settings_repository_impl.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';
import 'package:shopsphere/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/data/wishlist_repository_impl.dart';
import 'package:shopsphere/features/wishlist/domain/wishlist.dart';
import 'package:shopsphere/features/wishlist/presentation/bloc/wishlist_cubit.dart';

import '../../helpers/builders.dart';

void main() {
  group('Wishlist', () {
    late WishlistRepositoryImpl repository;
    late WishlistCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = WishlistRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      cubit = WishlistCubit(
        load: LoadWishlistUseCase(repository),
        toggle: ToggleWishlistUseCase(repository),
      );
    });

    tearDown(() => cubit.close());

    test(
      'toggling saves a product, newest first, and toggling again removes it',
      () async {
        await cubit.load(1);
        final lamp = buildProduct(id: 1, title: 'Lamp');
        final chair = buildProduct(id: 2, title: 'Chair');

        await cubit.toggle(lamp);
        await cubit.toggle(chair);
        expect(cubit.state.items.map((p) => p.id), [2, 1]);
        expect(cubit.state.contains(1), isTrue);

        await cubit.toggle(lamp);
        expect(cubit.state.items.map((p) => p.id), [2]);
        expect(cubit.state.contains(1), isFalse);
      },
    );

    test('the saved list survives a restart and belongs to one user', () async {
      await cubit.load(1);
      await cubit.toggle(
        buildProduct(id: 8, title: 'Kettle', price: 30, discount: 10),
      );

      final restarted = WishlistCubit(
        load: LoadWishlistUseCase(repository),
        toggle: ToggleWishlistUseCase(repository),
      );
      await restarted.load(1);
      expect(restarted.state.items.single.title, 'Kettle');
      expect(restarted.state.items.single.discountPercentage, 10);

      await restarted.load(2);
      expect(restarted.state.items, isEmpty);
      await restarted.close();
    });

    test('nothing is saved while signed out', () async {
      await cubit.toggle(buildProduct());

      expect(cubit.state.items, isEmpty);
    });

    test('unload puts the list away', () async {
      await cubit.load(1);
      await cubit.toggle(buildProduct());

      cubit.unload();

      expect(cubit.state.items, isEmpty);
      expect(cubit.state.loaded, isFalse);
    });
  });

  group('SettingsCubit', () {
    Future<SettingsCubit> build([
      Map<String, Object> initial = const {},
    ]) async {
      SharedPreferences.setMockInitialValues(initial);
      return SettingsCubit(
        SettingsRepositoryImpl(await SharedPreferences.getInstance()),
      );
    }

    test('defaults to following the system', () async {
      final cubit = await build();

      expect(cubit.state.theme, ThemeChoice.system);
      expect(cubit.state.languageCode, isNull);
      await cubit.close();
    });

    test('remembers the theme and language across launches', () async {
      var cubit = await build();
      await cubit.setTheme(ThemeChoice.dark);
      await cubit.setLanguage('hi');
      final prefs = await SharedPreferences.getInstance();
      await cubit.close();

      cubit = SettingsCubit(SettingsRepositoryImpl(prefs));

      expect(cubit.state.theme, ThemeChoice.dark);
      expect(cubit.state.languageCode, 'hi');
      await cubit.close();
    });

    test('choosing the device language forgets a saved one', () async {
      final cubit = await build({'settings.language': 'hi'});

      await cubit.setLanguage(null);

      expect(cubit.state.languageCode, isNull);
      expect(
        (await SharedPreferences.getInstance()).containsKey(
          'settings.language',
        ),
        isFalse,
      );
      await cubit.close();
    });

    test('toggleTheme flips from whatever is on screen, even when following the system', () async {
      final cubit = await build();
      final seen = <ThemeChoice>[];
      final subscription = cubit.stream.listen(
        (state) => seen.add(state.theme),
      );

      await cubit.toggleTheme(currentlyDark: true);
      await cubit.toggleTheme(currentlyDark: false);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [ThemeChoice.light, ThemeChoice.dark]);
      await subscription.cancel();
      await cubit.close();
    });

    test('an unknown stored theme falls back to system', () async {
      final cubit = await build({'settings.theme': 'neon'});

      expect(cubit.state.theme, ThemeChoice.system);
      await cubit.close();
    });
  });
}
