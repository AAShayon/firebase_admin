import '../entities/user_entity.dart';
import '../entities/user_roles.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity> signInWithGoogle();
  Future<void> signUpWithEmailAndPassword(String email, String password);
  Future<void> updatePassword(String newPassword, [String? currentPassword]);
  Future<UserEntity> getCurrentUser();
  Future<UserRole> checkUserRole(String userId);
}
