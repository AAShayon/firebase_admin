import '../entities/admin_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllAdminDetailsUseCase {
  final AdminRepository repository;

  GetAllAdminDetailsUseCase(this.repository);

  Future<List<AdminEntity>> call() async {
    return await repository.getAllAdminDetails();
  }
}

