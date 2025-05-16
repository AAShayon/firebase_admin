import '../../domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  SettingsModel({
    required super.themeMode,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: AppThemeMode.values[json['themeMode']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
    };
  }
}
