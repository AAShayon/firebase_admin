// lib/features/admin/presentation/pages/user_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';

import '../../../auth/domain/entities/user_roles.dart';

import '../providers/admin_notifier.dart';

import '../providers/admin_notifier_providers.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminNotifierProvider);
    final notifier = ref.read(adminNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchUsers(),
        child: state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (users) => _buildUserList(users, notifier),
          error: (message) => Center(child: Text(message)),
          roleUpdated: (_) => const Center(child: CircularProgressIndicator()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.fetchUsers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildUserList(List<UserEntity> users, AdminNotifier notifier) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(user.displayName?.substring(0, 1) ?? '?')
                  : null,
            ),
            title: Text(user.displayName ?? 'No name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email ?? 'No email'),
                Text('Role: ${user.role.name}'),
              ],
            ),
            trailing: _buildRoleDropdown(user, notifier),
          ),
        );
      },
    );
  }

  Widget _buildRoleDropdown(UserEntity user, AdminNotifier notifier) {
    return DropdownButton<UserRole>(
      value: user.role,
      items: UserRole.values.map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(role.name),
        );
      }).toList(),
      onChanged: (UserRole? newRole) {
        if (newRole != null && newRole != user.role) {
          notifier.changeUserRole(user, newRole);
        }
      },
    );
  }
}