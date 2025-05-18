import '../../domain/entities/settings_entity.dart';
import 'settings_state.dart';

extension SettingsStateX on SettingsState {
  bool get isLoading => maybeMap(
    loading: (_) => true,
    orElse: () => false,
  );

  bool get isError => maybeMap(
    error: (_) => true,
    orElse: () => false,
  );

  String? get errorMessage => maybeMap(
    error: (e) => e.message,
    orElse: () => null,
  );

  AppThemeMode? get themeMode => maybeMap(
    loaded: (s) => s.themeMode,
    orElse: () => null,
  );
}