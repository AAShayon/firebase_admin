// lib/features/admin/presentation/providers/admin_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_roles.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import 'admin_state.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final GetUsersUseCase getUsers;
  final UpdateUserRoleUseCase updateUserRole;

  AdminNotifier({
    required this.getUsers,
    required this.updateUserRole,
  }) : super(AdminState.initial());

  Future<void> fetchUsers() async {
    state = AdminState.loading();
    try {
      final users = await getUsers();
      state = AdminState.loaded(users);
    } catch (e) {
      state = AdminState.error(e.toString());
    }
  }

  Future<void> changeUserRole(UserEntity user, UserRole newRole) async {
    try {
      await updateUserRole(user.id, newRole);
      final updatedUser = UserEntity(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        isAdmin: newRole != UserRole.user,
        role: newRole,
      );
      state = AdminState.roleUpdated(updatedUser);
    } catch (e) {
      state = AdminState.error(e.toString());
    }
  }
}