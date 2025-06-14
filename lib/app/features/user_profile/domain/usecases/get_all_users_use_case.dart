import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetAllUsersUseCase {
  final UserProfileRepository repository;
  GetAllUsersUseCase(this.repository);

  Future<List<UserProfileEntity>> call() {
    return repository.getAllUsers();
  }
}