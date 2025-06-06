// lib/app/features/auth/domain/repositories/auth_repository.dart
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity> signInWithGoogle();
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> updatePassword(String newPassword, [String? currentPassword]);
  Future<bool> isAdmin();
  Future<bool> isSubAdmin();
  Future<UserEntity> getCurrentUser();
  Future<void> assignAdminRole(String userId, {bool isAdmin});
  Future<void> assignSubAdminRole(String userId, {bool isSubAdmin});
}