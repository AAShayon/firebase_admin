import 'package:firebase_admin/app/features/user_profile/presentation/providers/user_profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../domain/entities/user_profile_entity.dart';

import 'user_profile_state.dart';

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final Ref ref;

  UserProfileNotifier(this.ref) : super(const UserProfileState.initial());

  Future<void> loadUserProfile(String userId) async {
    if (state is! Loading) {
      state = const UserProfileState.loading();
    }
    try {
      final useCase = ref.read(getUserProfileProvider);
      final user = await useCase(userId);
      state = UserProfileState.loaded(user);
    } catch (e) {
      state = UserProfileState.error(e.toString());
    }
  }

  Future<void> updateProfile(UserProfileEntity updatedUser) async {
    state = const UserProfileState.loading();
    try {
      final useCase = ref.read(updateUserProfileUseCaseProvider);
      await useCase(updatedUser);
      state = UserProfileState.loaded(updatedUser);
    } catch (e) {
      state = UserProfileState.error(e.toString());
    }
  }

  Future<void> updateContactNumber(String userId, String addressId, String contactNo) async {
    state = const UserProfileState.loading();
    try {
      await ref.read(updateUserContactUseCaseProvider).call(userId, addressId, contactNo);
      state = const UserProfileState.contactUpdated();
    } catch (e) {
      state = UserProfileState.error(e.toString());
    }
  }

  Future<void> addUserAddress(String userId, UserAddress address) async {
    state = const UserProfileState.loading();
    try {
      await ref.read(manageUserAddressProvider).addAddress(userId, address);
      state = const UserProfileState.addressUpdated();
    } catch (e) {
      state = UserProfileState.error(e.toString());
    }
  }

  Future<void> updateUserAddress(String userId, UserAddress address) async {
    state = const UserProfileState.loading();
    try {
      await ref.read(manageUserAddressProvider).updateAddress(userId, address);
      state = const UserProfileState.addressUpdated();
    } catch (e) {
      state = UserProfileState.error(e.toString());
    }
  }
}