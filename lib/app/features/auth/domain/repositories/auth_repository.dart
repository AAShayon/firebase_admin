import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity> signInWithGoogle();
  Future<void> registerWithEmail(String email, String password);
  Future<void> updatePassword(String newPassword, [String? currentPassword]);
  Future<bool> isAdmin();
}
