import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<UserEntity> signInWithGoogle();
  Future<bool> isAdmin();
}
