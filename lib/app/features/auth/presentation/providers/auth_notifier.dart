import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state.dart';
import '../providers/auth_providers.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState.initial());

  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      await ref.read(signInWithEmailProvider).call(email, password);
      final currentUser = await ref.read(getCurrentUserProvider).call();
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await ref.read(signInWithGoogleProvider).call();
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      await ref.read(signUpWithEmailPasswordProvider).call(email, password);
      final currentUser = await ref.read(getCurrentUserProvider).call();
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updatePassword(String newPassword, String? currentPassword) async {
    state = AuthState.loading();
    try {
      await ref.read(updatePasswordProvider).call(newPassword, currentPassword);
      final currentUser = await ref.read(getCurrentUserProvider).call();
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    state = AuthState.loading();
    try {
      await ref.read(signOutProvider).call();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> assignAdminRole(String userId, {bool isAdmin = true}) async {
    state = AuthState.loading();
    try {
      await ref.read(assignAdminRoleProvider).call(userId, isAdmin: isAdmin);
      final currentUser = await ref.read(getCurrentUserProvider).call();
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> assignSubAdminRole(String userId, {bool isSubAdmin = true}) async {
    state = AuthState.loading();
    try {
      await ref.read(assignSubAdminRoleProvider).call(userId, isSubAdmin: isSubAdmin);
      final currentUser = await ref.read(getCurrentUserProvider).call();
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkCurrentUser() async {
    state = AuthState.loading();
    try {
      final currentUser = await ref.read(getCurrentUserProvider).call();
      if (currentUser.id.isNotEmpty) {
        state = AuthState.authenticated(currentUser);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    try {
      return await ref.read(isAdminProvider).call();
    } catch (e) {
      return false;
    }
  }

  Future<bool> isCurrentUserSubAdmin() async {
    try {
      return await ref.read(isSubAdminProvider).call();
    } catch (e) {
      return false;
    }
  }
}