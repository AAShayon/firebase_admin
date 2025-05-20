// lib/core/navigation/nav_guard.dart
import 'package:firebase_admin/app/features/auth/domain/entities/user_roles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier_provider.dart';


class NavigationGuard {
  static String? checkAccess(GoRouterState state, WidgetRef ref) {
    final authState = ref.read(authNotifierProvider);
    final currentRoute = state.matchedLocation;

    return authState.maybeMap(
      authenticated: (auth) {
        // Admin routes
        if (currentRoute.startsWith('/admin')) {
          if (auth.user.role.hierarchyLevel < UserRole.admin.hierarchyLevel) {
            return '/dashboard';
          }
        }

        return null;
      },
      orElse: () => currentRoute != '/login' ? '/login' : null,
    );
  }
}