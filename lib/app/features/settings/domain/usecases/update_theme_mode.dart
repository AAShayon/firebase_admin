import '../repositories/settings_repository.dart';
import '../entities/settings_entity.dart';

class UpdateThemeMode {
  final SettingsRepository repo;
  UpdateThemeMode(this.repo);

  Future<void> call(AppThemeMode mode) => repo.updateThemeMode(mode);
}
