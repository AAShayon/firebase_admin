
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repo;
  GetSettings(this.repo);

  Future<SettingsEntity> call() => repo.getSettings();
}
