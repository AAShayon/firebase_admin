
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';

final  getUsersProvider =Provider<GetUsersUseCase>((ref){
  return locator<GetUsersUseCase>();
});

final updateUserRoleProvider = Provider<UpdateUserRoleUseCase>((ref) {
  return locator<UpdateUserRoleUseCase>();
});