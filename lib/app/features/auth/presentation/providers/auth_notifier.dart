import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import 'auth_state.dart';
import '../providers/auth_providers.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState.initial());

  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      await ref.read(signInWithEmailProvider).call(email, password);
      final isAdmin = await ref.read(isAdminProvider).call();
      final user = UserEntity(id: 'current', isAdmin: isAdmin);
      state = AuthState.authenticated(user);
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
      final isAdmin = await ref.read(isAdminProvider).call();
      final user = UserEntity(id: 'current', isAdmin: isAdmin);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }


  Future<void> updatePassword(String newPassword, String? currentPassword) async {
    state = AuthState.loading();
    try {
      await ref.read(updatePasswordProvider).call(newPassword, currentPassword);
      final currentUser = (state as Authenticated).user;
      state = AuthState.authenticated(currentUser);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await ref.read(signOutProvider).call();
    state = AuthState.unauthenticated();
  }
}