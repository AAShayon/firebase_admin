import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  late SettingsModel _cachedSettings;

  @override
  Future<SettingsEntity> getSettings() async {
    _cachedSettings = await localDataSource.getSettings();
    return _cachedSettings;
  }

  @override
  Future<void> updateThemeMode(AppThemeMode mode) async {
    _cachedSettings = SettingsModel(
      themeMode: mode,
    );
    await localDataSource.saveSettings(_cachedSettings);
  }
}
