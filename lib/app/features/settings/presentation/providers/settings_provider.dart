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

