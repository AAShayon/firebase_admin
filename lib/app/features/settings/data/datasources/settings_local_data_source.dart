import 'package:get_storage/get_storage.dart';
import '../../domain/entities/settings_entity.dart';
import '../models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel model);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final GetStorage storage;

  SettingsLocalDataSourceImpl(this.storage);

  static const _key = 'settings';

  @override
  Future<SettingsModel> getSettings() async {
    final json = storage.read(_key);
    if (json != null) {
      return SettingsModel.fromJson(Map<String, dynamic>.from(json));
    }
    return SettingsModel(
      themeMode: AppThemeMode.system,
    );
  }

  @override
  Future<void> saveSettings(SettingsModel model) async {
    await storage.write(_key, model.toJson());
  }
}
