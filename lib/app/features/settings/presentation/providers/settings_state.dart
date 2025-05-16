

import '../../domain/entities/settings_entity.dart';

class SettingsState {
  final AppThemeMode themeMode;

  const SettingsState({
    required this.themeMode,

  });

  factory SettingsState.fromEntity(SettingsEntity entity) {
    return SettingsState(
      themeMode: entity.themeMode,
    );
  }

  SettingsState copyWith({
    AppThemeMode? themeMode,
    String? locale,
    double? fontScale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
