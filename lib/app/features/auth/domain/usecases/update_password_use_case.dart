import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call(String newPassword, String? currentPassword) {
    return repository.updatePassword(newPassword, currentPassword);
  }
}
