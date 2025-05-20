import '../../../../core/network/firebase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_roles.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    final model=await remoteDataSource.signInWithEmailAndPassword(email, password);
    return model.toEntity();
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final model = await remoteDataSource.signInWithGoogle();
    return model.toEntity();
  }
  
  @override
  Future<void> signUpWithEmailAndPassword(String email, String password)async {
    return await remoteDataSource.signUpWithEmailAndPassword(email, password);
  }

  @override
  Future<void> updatePassword(String newPassword, [String? currentPassword]) async {
    return await remoteDataSource.updatePassword(newPassword, currentPassword);
  }
  @override
  Future<UserEntity> getCurrentUser() async {
    final model = await remoteDataSource.getCurrentUser();
    return model.toEntity();

  }

  @override
  Future<UserRole> checkUserRole(String userId) {
    return remoteDataSource.checkUserRole(userId);
  }


}
