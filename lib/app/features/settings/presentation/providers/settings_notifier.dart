import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/settings/domain/entities/settings_entity.dart';
import 'package:firebase_admin/app/features/settings/domain/usecases/get_settings.dart';
import 'package:firebase_admin/app/features/settings/domain/usecases/update_theme_mode.dart';
import 'settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  final GetSettings getSettings;
  final UpdateThemeMode updateThemeMode;

  SettingsNotifier({
    required this.getSettings,
    required this.updateThemeMode,
  }) : super(const SettingsState.initial()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const SettingsState.loading();
    try {
      final settings = await getSettings();
      state = SettingsState.loaded(settings.themeMode);
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = const SettingsState.loading();
    try {
      await updateThemeMode(mode);
      final settings = await getSettings();
      state = SettingsState.loaded(settings.themeMode);
    } catch (e) {
      state = SettingsState.error(e.toString());
    }
  }
}