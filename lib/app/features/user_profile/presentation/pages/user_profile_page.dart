import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/user_profile/presentation/providers/user_profile_state.dart';
import 'package:firebase_admin/app/features/user_profile/presentation/widgets/address_list_tile.dart';
import 'package:firebase_admin/app/features/user_profile/presentation/widgets/profile_header.dart';
import 'package:firebase_admin/app/features/user_profile/domain/entities/user_profile_entity.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../providers/user_profile_notifier_provider.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    await ref.read(userProfileNotifierProvider.notifier).loadUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Add Address page using GoRouter
          context.pushNamed(AppRoutes.addAddress);
        },
        tooltip: 'Add New Address',
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }

  Widget _buildBody(UserProfileState state) {
    return state.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (user) => _buildProfileView(user),
      error: (message) => Center(child: Text('Error: $message')),
      addressUpdated: () {
        Future.microtask(() => _loadProfile());
        return const Center(child: CircularProgressIndicator());
      },
      contactUpdated: () {
        Future.microtask(() => _loadProfile());
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildProfileView(UserProfileEntity user) {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(user: user),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Addresses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user.addresses.isNotEmpty)
                    Text(
                      '${user.addresses.length} saved',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            _buildAddressList(user),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(UserProfileEntity user) {
    if (user.addresses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Center(child: Text('No addresses saved yet.\nTap the + button to add one.', textAlign: TextAlign.center)),
      );
    }


    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: user.addresses.length,
      itemBuilder: (context, index) {
        final address = user.addresses[index];
        return AddressListTile(
          address: address,
          onTap: () {
            context.pushNamed(
              AppRoutes.editAddress,
              pathParameters: {'addressId': address.id},
              extra: address, // Pass the full object for convenience
            );
          },
          onSetDefault: () => _setDefaultAddress(ref, address.id),
          onDelete: () => _deleteAddress(context, ref, address),
        );
      },
    );
  }


  // void _showEditAddressDialog(
  //     BuildContext context, WidgetRef ref, UserAddress address) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AddAddressDialog(
  //       address: address,
  //       onSave: (updatedAddress) {
  //         ref
  //             .read(userProfileNotifierProvider.notifier)
  //             .updateUserAddress(widget.userId, updatedAddress);
  //       },
  //     ),
  //   );
  // }
///
//   void _setDefaultAddress(WidgetRef ref, UserAddress address) {
//     final updatedAddress = address.copyWith(isDefault: true);
//     ref
//         .read(userProfileNotifierProvider.notifier)
//         .updateUserAddress(widget.userId, updatedAddress);
//   }
  void _setDefaultAddress(WidgetRef ref, String addressId) {
    // Your data source already has the logic to handle unsetting the old default.
    // We just need to call the appropriate method in the notifier.
    // Let's assume you add a `setDefaultAddress` method to your notifier.
    // If not, you'll need to add it. For now, this is the intended architecture.
    // You would ideally have a method like this in your notifier:
    // await notifier.setDefaultAddress(widget.userId, addressId);

    // The existing updateUserAddress can also work if the backend logic is correct
    final currentState = ref.read(userProfileNotifierProvider);
    final address = currentState.maybeWhen(loaded: (user) => user.addresses.firstWhere((a) => a.id == addressId), orElse: () => null);
    if(address != null) {
      ref.read(userProfileNotifierProvider.notifier).updateUserAddress(widget.userId, address.copyWith(isDefault: true));
    }
  }

  void _deleteAddress(BuildContext context, WidgetRef ref, UserAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(userProfileNotifierProvider.notifier)
                  .deleteUserAddress(widget.userId, address.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(userProfileNotifierProvider);
    final user = state.maybeWhen(
      loaded: (user) => user,
      orElse: () => null,
    );

    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedUser = user.copyWith(
                displayName: nameController.text,
                email: emailController.text,
              );
              ref
                  .read(userProfileNotifierProvider.notifier)
                  .updateProfile(updatedUser);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}