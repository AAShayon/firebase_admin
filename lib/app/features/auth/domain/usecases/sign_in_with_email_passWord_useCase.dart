import '../repositories/auth_repository.dart';

class SignInWithEmailAndPassword {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  Future<void> call(String email, String password) {
    return repository.signInWithEmailAndPassword(email, password);
  }
}
