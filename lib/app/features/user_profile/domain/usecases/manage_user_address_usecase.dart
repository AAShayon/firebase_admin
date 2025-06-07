// lib/features/user_profile/domain/usecases/manage_user_address_usecase.dart
import '../repositories/user_profile_repository.dart';
import '../entities/user_profile_entity.dart';

class ManageUserAddressUseCase {
  final UserProfileRepository repository;

  ManageUserAddressUseCase(this.repository);

  Future<void> addAddress(String userId, UserAddress address) =>
      repository.addUserAddress(userId, address);

  Future<void> updateAddress(String userId, UserAddress address) =>
      repository.updateUserAddress(userId, address);

  Future<void> removeAddress(String userId, String addressId) =>
      repository.removeUserAddress(userId, addressId);

  Future<void> setDefaultAddress(String userId, String addressId) =>
      repository.setDefaultAddress(userId, addressId);
}

