import '../../../../core/network/firebase_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    return await remoteDataSource.signInWithEmailAndPassword(email, password);
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
  Future<void> registerWithEmail(String email, String password)async {
    return await remoteDataSource.registerWithEmail(email, password);
  }

  @override
  Future<void> updatePassword(String newPassword, [String? currentPassword]) async {
    return await remoteDataSource.updatePassword(newPassword, currentPassword);
  }
}
