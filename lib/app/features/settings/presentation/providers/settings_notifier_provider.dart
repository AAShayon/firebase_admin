import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_notifier.dart';
import 'settings_state.dart';
import 'settings_provider.dart';

final settingsNotifierProvider =
StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  return SettingsNotifier(
    getSettings: ref.read(getSettingsProvider),
    updateThemeMode: ref.read(updateThemeModeProvider),
  );
});
