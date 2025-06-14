import 'package:firebase_admin/app/core/di/injector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_all_users_use_case.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/manage_user_address_usecase.dart';
import '../../domain/usecases/update_user_contact_use_case.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/watch_user_profile_use_case.dart';

// Use Cases
final getUserProfileProvider = Provider<GetUserProfileUseCase>((ref) {
  return locator<GetUserProfileUseCase>();
});

final manageUserAddressProvider = Provider<ManageUserAddressUseCase>((ref) {
  return locator<ManageUserAddressUseCase>();
});

final updateUserProfileUseCaseProvider = Provider<UpdateUserProfileUseCase>((ref) {
  return locator<UpdateUserProfileUseCase>();
});
final updateUserContactUseCaseProvider = Provider<UpdateUserContactNoUseCase>((ref) {
  return locator<UpdateUserContactNoUseCase>();
});
final watchUserProfileUseCaseProvider = Provider<WatchUserProfileUseCase>((ref) {
  return locator<WatchUserProfileUseCase>();
});
final getAllUsersUseCaseProvider = Provider<GetAllUsersUseCase>((ref) {
  return locator<GetAllUsersUseCase>();
});

final allUsersProvider = FutureProvider.autoDispose<List<UserProfileEntity>>((ref) {
  return ref.watch(getAllUsersUseCaseProvider).call();
});

final userProfileStreamProvider = StreamProvider.autoDispose
    .family<UserProfileEntity, String>((ref, userId) {

  // 1. Get the use case instance from its provider.
  final watchUserProfile = ref.watch(watchUserProfileUseCaseProvider);

  // 2. Call the use case to get the stream.
  return watchUserProfile(userId);
});
