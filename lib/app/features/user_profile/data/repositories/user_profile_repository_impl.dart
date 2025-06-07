import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    return await remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<void> updateUserProfile(UserProfileEntity user) async {
    return await remoteDataSource.updateUserProfile(user);
  }

  @override
  Future<void> addUserAddress(String userId, UserAddress address) async {
    return await remoteDataSource.addUserAddress(userId, address);
  }

  @override
  Future<void> updateUserAddress(String userId, UserAddress address) async {
    return await remoteDataSource.updateUserAddress(userId, address);
  }

  @override
  Future<void> removeUserAddress(String userId, String addressId) async {
    return await remoteDataSource.removeUserAddress(userId, addressId);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    return await remoteDataSource.setDefaultAddress(userId, addressId);
  }

  @override
  Future<void> updateContactNo(String userId,String addressId, String contactNo)async {
   return await remoteDataSource.updateContactNo(userId, addressId, contactNo);
  }
}