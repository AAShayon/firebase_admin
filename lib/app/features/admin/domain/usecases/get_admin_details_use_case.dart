import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminDetailsUseCase {
  final AdminRepository repository;

  GetAdminDetailsUseCase(this.repository);

  Future<AdminEntity> call(String userId) async {
    return await repository.getAdminDetails(userId);
  }
}
