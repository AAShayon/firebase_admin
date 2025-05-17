import 'auth_state.dart';

extension AuthStateX on AuthState {
  bool get isLoading => maybeMap(
    loading: (_) => true,
    orElse: () => false,
  );

  bool get isAuthenticated => maybeMap(
    authenticated: (_) => true,
    orElse: () => false,
  );

  String? get errorMessage => maybeMap(
    error: (e) => e.message,
    orElse: () => null,
  );
}
