// lib/features/user_profile/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileEntity user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoUrl != null
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? 'No name provided',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (user.email != null) ...[
            const SizedBox(height: 8),
            Text(user.email!),
          ],
        ],
      ),
    );
  }
}