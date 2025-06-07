// lib/features/user_profile/domain/repositories/user_profile_repository.dart
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<UserProfileEntity> getUserProfile(String userId);

  Future<void> updateUserProfile(UserProfileEntity user);

  Future<void> updateContactNo(String userId, String addressId, String contactNo);

  Future<void> addUserAddress(String userId, UserAddress address);

  Future<void> updateUserAddress(String userId, UserAddress address);

  Future<void> removeUserAddress(String userId, String addressId);

  Future<void> setDefaultAddress(String userId, String addressId);
}
