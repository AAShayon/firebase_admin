import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/config/widgets/custom_button.dart';
import 'package:firebase_admin/app/core/utils/custom_size_space.dart';
import 'package:firebase_admin/app/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:firebase_admin/app/features/settings/domain/entities/settings_entity.dart';
import 'package:firebase_admin/app/features/settings/presentation/providers/settings_notifier_provider.dart';

import '../../../../config/widgets/responsive_scaffold.dart';
import '../../../../core/network/firebase_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final settingsState = ref.watch(settingsNotifierProvider);
    final user = FirebaseProvider.auth.currentUser;

    return Scaffold(
      // title: 'Settings',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    CustomSizeSpace.vMedium16,
                    ListTile(
                      leading: const Icon(Icons.person),
                      title:  Text(user!.displayName ?? 'Guest'),
                      subtitle: Text(
                        authState.maybeMap(
                          authenticated: (auth) => auth.user.id,
                          orElse: () => 'Guest',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomSizeSpace.vMedium16,

            // Theme Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    CustomSizeSpace.vMedium16,
                    settingsState.when(
                      initial: () => const CircularProgressIndicator(),
                      loading: () => const CircularProgressIndicator(),
                      error: (error) => Text('Error: $error'),
                      loaded: (themeMode) => Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.color_lens),
                            title: const Text('Theme'),
                            subtitle: Text(themeMode.toString().split('.').last),
                            onTap: () => _showThemeDialog(context, ref),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomSizeSpace.vMedium16,

            // Security Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    CustomSizeSpace.vMedium16,
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Update Password'),
                      onTap: () => _showUpdatePasswordDialog(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(settingsNotifierProvider).maybeWhen(
      loaded: (mode) => mode,
      orElse: () => AppThemeMode.system,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(mode.toString().split('.').last),
                value: mode,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsNotifierProvider.notifier).setTheme(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                CustomSizeSpace.vMedium16,
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                CustomSizeSpace.vMedium16,
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CustomButton(
              text: 'Update',
              onPressed: () async {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  await ref.read(authNotifierProvider.notifier).updatePassword(
                    newPasswordController.text,
                    currentPasswordController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}