import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository repository;

  GetUsersUseCase(this.repository);

  Future<List<UserEntity>> call() async {
    return await repository.getUsers();
  }
}


