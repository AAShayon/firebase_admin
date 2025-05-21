import 'package:firebase_admin/app/features/admin/domain/entities/admin_entity.dart';

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

  @override
  Future<AdminEntity> getAdminDetails(String userId) async{
   final model = await remoteDataSource.getAdminDetails(userId);
   return AdminEntity(userId: model.userId, assignedAt: model.assignedAt, isSuperAdmin: model.isSuperAdmin);
  }

  @override
  Future<List<AdminEntity>> getAllAdminDetails() async{
 final models= await remoteDataSource.getAllAdminDetails();
 return models.map((model) => AdminEntity(userId: model.userId, assignedAt: model.assignedAt, isSuperAdmin: model.isSuperAdmin)).toList();
  }
}