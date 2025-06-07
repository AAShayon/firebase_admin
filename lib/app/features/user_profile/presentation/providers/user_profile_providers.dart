import 'package:firebase_admin/app/core/di/injector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/manage_user_address_usecase.dart';
import '../../domain/usecases/update_user_contact_use_case.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';

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

