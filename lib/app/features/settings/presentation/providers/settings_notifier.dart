
import 'package:firebase_admin/app/features/settings/presentation/providers/settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_theme_mode.dart';


class SettingsNotifier extends StateNotifier<AsyncValue<SettingsState>> {
  final GetSettings getSettings;
  final UpdateThemeMode updateThemeMode;


  SettingsNotifier({
    required this.getSettings,
    required this.updateThemeMode,
  }) : super(const AsyncLoading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncLoading();
    try {
      final settings = await getSettings();
      state = AsyncData(SettingsState.fromEntity(settings));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    await updateThemeMode(mode);
    loadSettings();
  }

}
