import '../repositories/auth_repository.dart';

class AssignAdminRole {
  final AuthRepository repository;

  AssignAdminRole(this.repository);

  Future<void> call(String userId, {bool isAdmin = true}) {
    return repository.assignAdminRole(userId, isAdmin: isAdmin);
  }
}