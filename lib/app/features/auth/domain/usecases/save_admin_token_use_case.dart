import '../repositories/auth_repository.dart';

class SaveAdminTokenUseCase {
  final AuthRepository repository;

  SaveAdminTokenUseCase(this.repository);

  Future<void> call(String adminId) {
    return repository.saveAdminDeviceToken(adminId);
  }
}