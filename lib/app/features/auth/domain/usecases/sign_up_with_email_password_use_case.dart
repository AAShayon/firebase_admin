import '../repositories/auth_repository.dart';

class SignUpWithEmailPasswordUseCase {
  final AuthRepository repository;

  SignUpWithEmailPasswordUseCase(this.repository);

  Future<void> call(String email, String password) {
    return repository.signUpWithEmailAndPassword(email, password);
  }
}
