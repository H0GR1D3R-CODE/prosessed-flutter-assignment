import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopsphere/features/settings/domain/settings.dart';

class SettingsState extends Equatable {
  const SettingsState({this.theme = ThemeChoice.system, this.languageCode});

  final ThemeChoice theme;

  /// `null` follows the device language.
  final String? languageCode;

  @override
  List<Object?> get props => [theme, languageCode];
}

/// Theme and language, remembered across launches.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository)
    : super(
        SettingsState(
          theme: _repository.themeChoice,
          languageCode: _repository.languageCode,
        ),
      );

  final SettingsRepository _repository;

  Future<void> setTheme(ThemeChoice choice) async {
    emit(SettingsState(theme: choice, languageCode: state.languageCode));
    await _repository.saveThemeChoice(choice);
  }

  /// Flips between light and dark from whatever is showing now, even when following the system.
  Future<void> toggleTheme({required bool currentlyDark}) {
    return setTheme(currentlyDark ? ThemeChoice.light : ThemeChoice.dark);
  }

  Future<void> setLanguage(String? code) async {
    emit(SettingsState(theme: state.theme, languageCode: code));
    await _repository.saveLanguageCode(code);
  }
}
