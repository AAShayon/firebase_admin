// lib/features/admin/presentation/providers/admin_notifier_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import 'admin_notifier.dart';
import 'admin_state.dart';

final adminNotifierProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(
    getUsers: locator<GetUsersUseCase>(),
    updateUserRole: locator<UpdateUserRoleUseCase>(),
  );
});