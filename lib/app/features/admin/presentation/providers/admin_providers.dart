
import 'package:firebase_admin/app/features/admin/domain/usecases/get_admin_details_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_all_admin_details_use_case.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';

final  getUsersProvider =Provider<GetUsersUseCase>((ref){
  return locator<GetUsersUseCase>();
});

final updateUserRoleProvider = Provider<UpdateUserRoleUseCase>((ref) {
  return locator<UpdateUserRoleUseCase>();
});

final adminDetailsProvider =Provider<GetAdminDetailsUseCase>((ref){
  return locator<GetAdminDetailsUseCase>();
});
final allAdminDetailsProvider =Provider<GetAllAdminDetailsUseCase>((ref){
  return locator<GetAllAdminDetailsUseCase>();
});