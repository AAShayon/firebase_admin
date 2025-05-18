import 'package:firebase_admin/app/features/settings/presentation/providers/settings_provider.dart';
import 'package:firebase_admin/app/features/settings/presentation/providers/settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_notifier.dart';

final settingsNotifierProvider =
StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    getSettings: ref.read(getSettingsProvider),
    updateThemeMode: ref.read(updateThemeModeProvider),
  );
});