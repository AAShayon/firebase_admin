import '../repositories/auth_repository.dart';

class AssignSubAdminRole {
  final AuthRepository repository;

  AssignSubAdminRole(this.repository);

  Future<void> call(String userId, {bool isSubAdmin = true}) {
    return repository.assignSubAdminRole(userId, isSubAdmin: isSubAdmin);
  }
}