enum AppThemeMode { system, light, dark }

class SettingsEntity {
  final AppThemeMode themeMode;

  SettingsEntity({
    required this.themeMode,
  });
}
