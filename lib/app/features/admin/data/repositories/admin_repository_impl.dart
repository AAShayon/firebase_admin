import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_roles.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserEntity>> getUsers() async {
    return await remoteDataSource.getUsers();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    return await remoteDataSource.updateUserRole(userId, newRole);
  }
}