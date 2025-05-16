import 'package:firebase_admin/app/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter/material.dart';

ThemeMode convertTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
