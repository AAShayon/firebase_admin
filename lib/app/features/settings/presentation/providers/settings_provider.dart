import 'package:firebase_admin/app/features/settings/presentation/providers/settings_notifier.dart';
import 'package:firebase_admin/app/features/settings/presentation/providers/settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/datasources/settings_local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_theme_mode.dart';

// Provide GetStorage (already registered in injector, still fallback here)
final getStorageProvider = Provider<GetStorage>((ref) => GetStorage());

// DataSource
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl(ref.read(getStorageProvider));
});

// Repository
final settingsRepositoryProvider = Provider((ref) {
  return SettingsRepositoryImpl(ref.read(settingsLocalDataSourceProvider));
});

// Use cases
final getSettingsProvider = Provider((ref) => GetSettings(ref.read(settingsRepositoryProvider)));
final updateThemeModeProvider = Provider((ref) => UpdateThemeMode(ref.read(settingsRepositoryProvider)));

// NotifierProvider
final settingsNotifierProvider =
StateNotifierProvider<SettingsNotifier, AsyncValue<SettingsState>>((ref) {
  return SettingsNotifier(
    getSettings: ref.read(getSettingsProvider),
    updateThemeMode: ref.read(updateThemeModeProvider),
  );
});
