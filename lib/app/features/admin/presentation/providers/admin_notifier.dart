// lib/features/admin/presentation/providers/admin_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_roles.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import 'admin_providers.dart';
import 'admin_state.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref ref;

  AdminNotifier(this.ref) : super(const AdminState.initial());

  Future<void> fetchUsers() async {
    state = const AdminState.loading();
    try {
      final getUsersUseCase = ref.read(getUsersProvider);
      final users = await getUsersUseCase.call();
      state = AdminState.loaded(users);
    } catch (e) {
      state = AdminState.error('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<void> changeUserRole(UserEntity user, UserRole newRole) async {
    try {
      final updateUserRoleUseCase = ref.read(updateUserRoleProvider);
      final updatedUser = await updateUserRoleUseCase.call();
      state = AdminState.roleUpdated(updatedUser);
      // Refresh users after update (optional)
      await fetchUsers();
    } catch (e) {
      state = AdminState.error('Failed to update user role: ${e.toString()}');
    }
  }
  Future<void> getAdminDetails(String userId) async {
    try {
      final getAdminDetailsUseCase = ref.read(adminDetailsProvider);
      final adminDetails = await getAdminDetailsUseCase.call(userId);
      state =AdminState.loaded(adminDetails);

    } catch (e) {
      // Handle errors

  }


}

