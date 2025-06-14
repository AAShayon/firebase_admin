import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/config/widgets/custom_drop_down.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../providers/dashboard_notifier_provider.dart';

class DashboardNotificationSection extends ConsumerStatefulWidget {
  const DashboardNotificationSection({super.key});

  @override
  ConsumerState<DashboardNotificationSection> createState() => _DashboardNotificationSectionState();
}

class _DashboardNotificationSectionState extends ConsumerState<DashboardNotificationSection> {
  // Local state to manage dropdown selections
  String _selectedAudience = 'all_users';
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final dashboardNotifier = ref.read(dashboardNotifierProvider.notifier);
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final allUsersAsync = ref.watch(allUsersProvider);

    final isSending = dashboardState.maybeWhen(loading: () => true, orElse: () => false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IgnorePointer(
          ignoring: isSending,
          child: Opacity(
            opacity: isSending ? 0.5 : 1.0,
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔔 Publish Notification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dashboardNotifier.notificationTitleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dashboardNotifier.notificationBodyController,
                    decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown<String>(
                    labelText: 'Target Audience',
                    value: _selectedAudience,
                    items: const [
                      DropdownMenuItem(value: 'all_users', child: Text('All Users')),
                      DropdownMenuItem(value: 'specific_user', child: Text('Specific User')),
                      // Add other topics here if you implement them
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedAudience = value;
                          _selectedUserId = null; // Reset specific user when audience changes
                        });
                      }
                    },
                  ),

                  // Conditionally show the user selection dropdown
                  if (_selectedAudience == 'specific_user')
                    allUsersAsync.when(
                      data: (users) => CustomDropdown<String>(
                        labelText: 'Select User',
                        hintText: 'Choose a customer',
                        value: _selectedUserId,
                        items: users.map((user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.displayName ?? user.email ?? user.id),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedUserId = value),
                        validator: (value) => value == null ? 'Please select a user' : null,
                      ),
                      loading: () => const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator()),
                      error: (e, s) => Text('Error loading users: $e'),
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pass the correct target to the notifier
                        final target = _selectedAudience == 'specific_user'
                            ? _selectedUserId
                            : _selectedAudience;
                        if (target != null) {
                          dashboardNotifier.sendNotification(target: target);
                        }
                      },
                      child: isSending
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : const Text('Publish Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}