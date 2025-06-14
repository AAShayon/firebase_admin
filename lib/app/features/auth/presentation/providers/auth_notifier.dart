// // lib/app/features/auth/presentation/providers/auth_notifier.dart
// import 'package:firebase_admin/app/features/auth/domain/entities/user_entity.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../core/errors/failures.dart';
// import 'auth_state.dart';
// import '../providers/auth_providers.dart';
//
// class AuthNotifier extends StateNotifier<AuthState> {
//   final Ref ref;
//
//   AuthNotifier(this.ref) : super(AuthState.initial());
//
//
//   Future<void> _onLoginSuccess(UserEntity user) async {
//     // If the user is an admin, ensure their device token is saved.
//     if (user.isAdmin) {
//       // We now call our clean use case.
//       await ref.read(saveAdminTokenProvider).call(user.id);
//     }
//     // Set the final authenticated state.
//     state = AuthState.authenticated(user);
//   }
//   Future<void> signInWithEmail(String email, String password) async {
//     state = AuthState.loading();
//     try {
//       await ref.read(signInWithEmailProvider).call(email, password);
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       await _onLoginSuccess(currentUser);
//       state = AuthState.authenticated(currentUser);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<void> signInWithGoogle() async {
//     state = AuthState.loading();
//     try {
//       final user = await ref.read(signInWithGoogleProvider).call();
//       state = AuthState.authenticated(user);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<void> signUpWithEmail(String email, String password) async {
//     state = AuthState.loading();
//     try {
//       await ref.read(signUpWithEmailPasswordProvider).call(email, password);
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       state = AuthState.authenticated(currentUser);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<void> updatePassword(String newPassword, String? currentPassword) async {
//     state = AuthState.loading();
//     try {
//       await ref.read(updatePasswordProvider).call(newPassword, currentPassword);
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       state = AuthState.authenticated(currentUser);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<void> signOut() async {
//     state = AuthState.loading();
//     try {
//       await ref.read(signOutProvider).call();
//       state = AuthState.unauthenticated();
//     } catch (e) {
//       state = AuthState.error(e.toString());
//       rethrow;
//     }
//   }
//
// // In your AuthNotifier class
//   Future<void> checkCurrentUser() async {
//     state = AuthState.loading();
//     try {
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       final adminStatus = await ref.read(isAdminProvider).call();
//       final subAdminStatus = await ref.read(isSubAdminProvider).call();
//
//       final updatedUser = currentUser.copyWith(
//         isAdmin: adminStatus,
//         isSubAdmin: subAdminStatus,
//       );
//
//       state = AuthState.authenticated(updatedUser);
//     } on AuthFailure catch (_) {
//       state = AuthState.unauthenticated();
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<bool> isCurrentUserAdmin() async {
//     try {
//       return await ref.read(isAdminProvider).call();
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<bool> isCurrentUserSubAdmin() async {
//     try {
//       return await ref.read(isSubAdminProvider).call();
//     } catch (e) {
//       return false;
//     }
//   }
//
//   Future<void> assignAdminRole(String userId, {bool isAdmin = true}) async {
//     state = AuthState.loading();
//     try {
//       await ref.read(assignAdminRoleProvider).call(userId, isAdmin: isAdmin);
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       state = AuthState.authenticated(currentUser);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
//
//   Future<void> assignSubAdminRole(String userId, {bool isSubAdmin = true}) async {
//     state = AuthState.loading();
//     try {
//       await ref.read(assignSubAdminRoleProvider).call(userId, isSubAdmin: isSubAdmin);
//       final currentUser = await ref.read(getCurrentUserProvider).call();
//       state = AuthState.authenticated(currentUser);
//     } catch (e) {
//       state = AuthState.error(e.toString());
//     }
//   }
// }
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthState.initial());

  /// A helper function to run after any successful login or app start.
  Future<void> _onLoginSuccess(UserEntity user) async {
    // If the user is an admin, ensure their device token is saved for notifications.
    if (user.isAdmin) {
      await ref.read(saveAdminTokenProvider).call(user.id);
    }
    // Set the final authenticated state.
    state = AuthState.authenticated(user);
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      // The use case returns the complete UserEntity, which we then pass to the helper.
      final user = await ref.read(signInWithEmailProvider).call(email, password);
      await _onLoginSuccess(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await ref.read(signInWithGoogleProvider).call();
      await _onLoginSuccess(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      // First, create the user account.
      await ref.read(signUpWithEmailPasswordProvider).call(email, password);

      // Then, sign them in to get the full user object and run post-login logic.
      final user = await ref.read(signInWithEmailProvider).call(email, password);
      await _onLoginSuccess(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// This is called from the splash screen to check for an existing session.
  Future<void> checkCurrentUser() async {
    state = AuthState.loading();
    try {
      // This single call gets the user and all their roles efficiently.
      final currentUser = await ref.read(getCurrentUserProvider).call();
      await _onLoginSuccess(currentUser);
    } on AuthFailure catch (_) {
      state = AuthState.unauthenticated();
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

  // --- The methods below are for other features and remain unchanged ---

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