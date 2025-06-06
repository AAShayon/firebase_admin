// lib/app/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../core/network/firebase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    final model = await remoteDataSource.signInWithEmailAndPassword(email, password);
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
  Future<bool> isAdmin() async {
    final user = FirebaseProvider.auth.currentUser;
    if (user == null) return false;
    return await remoteDataSource.isAdmin(user.uid);
  }

  @override
  Future<bool> isSubAdmin() async {
    final user = FirebaseProvider.auth.currentUser;
    if (user == null) return false;
    return await remoteDataSource.isSubAdmin(user.uid);
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
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
  Future<void> assignAdminRole(String userId, {bool isAdmin = true}) async {
    return await remoteDataSource.assignAdminRole(userId, isAdmin: isAdmin);
  }

  @override
  Future<void> assignSubAdminRole(String userId, {bool isSubAdmin = true}) async {
    return await remoteDataSource.assignSubAdminRole(userId, isSubAdmin: isSubAdmin);
  }
}