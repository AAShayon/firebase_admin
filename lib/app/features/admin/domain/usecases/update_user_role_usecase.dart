
import '../../../auth/domain/entities/user_roles.dart';
import '../repositories/admin_repository.dart';


class UpdateUserRoleUseCase {
  final AdminRepository repository;

  UpdateUserRoleUseCase(this.repository);

  Future<void> call(String userId, UserRole newRole) async {
    return await repository.updateUserRole(userId, newRole);
  }
}