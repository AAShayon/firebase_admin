// lib/app/features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/admin_use_case.dart';
import '../../domain/usecases/assign_admin_role_use_case.dart';
import '../../domain/usecases/assign_sub_admin_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/save_admin_token_use_case.dart';
import '../../domain/usecases/sign_in_with_email_passWord_useCase.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email_password_use_case.dart';
import '../../domain/usecases/sub_admin_use_case.dart';
import '../../domain/usecases/update_password_use_case.dart';
import 'auth_notifier_provider.dart';

final signInWithEmailProvider = Provider<SignInWithEmailAndPassword>((ref) {
  return locator<SignInWithEmailAndPassword>();
});

final signUpWithEmailPasswordProvider = Provider<SignUpWithEmailPasswordUseCase>((ref) {
  return locator<SignUpWithEmailPasswordUseCase>();
});

final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return locator<SignInWithGoogle>();
});

final signOutProvider = Provider<SignOut>((ref) {
  return locator<SignOut>();
});

final isAdminProvider = Provider<IsAdmin>((ref) {
  return locator<IsAdmin>();
});

final updatePasswordProvider = Provider<UpdatePasswordUseCase>((ref) {
  return locator<UpdatePasswordUseCase>();
});

final isSubAdminProvider = Provider<IsSubAdminUseCase>((ref) {
  return locator<IsSubAdminUseCase>();
});

final assignAdminRoleProvider = Provider<AssignAdminRole>((ref) {
  return locator<AssignAdminRole>();
});

final assignSubAdminRoleProvider = Provider<AssignSubAdminRole>((ref) {
  return locator<AssignSubAdminRole>();
});

final getCurrentUserProvider = Provider<CurrentUserUseCase>((ref) {
  return locator<CurrentUserUseCase>();
});
final saveAdminTokenProvider = Provider<SaveAdminTokenUseCase>((ref) {
  return locator<SaveAdminTokenUseCase>();
});
// ... (your existing providers)

/// This provider derives the current user from the main AuthState.
/// The UI can watch this to get direct access to the UserEntity? object.
/// It will automatically be null if the user is unauthenticated.
final currentUserProvider = Provider<UserEntity?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.when(
    initial: () => null,
    loading: () => null,
    authenticated: (user) => user,
    unauthenticated: () => null,
    error: (_) => null,
  );
});