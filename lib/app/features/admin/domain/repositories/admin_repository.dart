// lib/features/admin/domain/repositories/admin_repository.dart
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_roles.dart';

abstract class AdminRepository {
  Future<List<UserEntity>> getUsers();
  Future<void> updateUserRole(String userId, UserRole newRole);
}