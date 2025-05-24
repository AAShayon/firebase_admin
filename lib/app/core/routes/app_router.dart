// import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
// import 'package:firebase_admin/app/features/home_page/presentation/pages/home_page.dart';
// import 'package:firebase_admin/app/features/products/presentation/widgets/products_table.dart';
// import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../features/auth/presentation/providers/auth_notifier_provider.dart';
// import '../../features/auth/presentation/providers/auth_state.dart';
// import '../../features/initialization/presentation/pages/splash_screen.dart';
// import '../../features/auth/presentation/pages/login_page.dart';
// import '../../features/auth/presentation/pages/registration_page.dart';
// import '../../features/dashboard/presentation/pages/dashboard_page.dart';
// import 'app_transitions.dart';
//
// final GoRouter appRouter = GoRouter(
//   initialLocation: '/splash',
//   redirect: (BuildContext context, GoRouterState state) async {
//     final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
//
//     if (state.uri.path == '/splash') return null;
//
//     if (authState is Loading) return '/loading';
//
//
//     return authState.when(
//       initial: () => '/splash',
//       loading: () => '/loading',
//       authenticated: (user) {
//         // Handle admin-only routes
//         final isAdminRoute = [
//           '/products',
//           '/dashboard',
//         ].contains(state.uri.path);
//
//         if (isAdminRoute && !user.isAdmin) {
//           return '/homepage';
//         }
//         return null; // Allow access
//       },
//       unauthenticated: () {
//         // Allow auth-related routes
//         if (['/login', '/register'].contains(state.uri.path)) {
//           return null;
//         }
//         return '/login';
//       },
//       error: (error) {
//         // On error, allow retry on login screen
//         if (state.uri.path == '/login') return null;
//         return '/login';
//       },
//     );
//   },
//   routes: [
//     GoRoute(
//       path: '/',
//       redirect: (context, state) {
//         final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
//         return authState.maybeMap(
//           authenticated: (_) => '/homepage',
//           orElse: () => '/login',
//         );
//       },
//     ),
//     GoRoute(
//       name: 'loading',
//       path: '/loading',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: CustomLoadingScreen(),
//         transitionType: AppRouteTransitionType.fade,
//       ),
//     ),
//     GoRoute(
//       name: 'splash',
//       path: '/splash',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: const SplashScreen(),
//         transitionType: AppRouteTransitionType.fade,
//       ),
//     ),
//     GoRoute(
//       name: 'login',
//       path: '/login',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: const LoginPage(),
//         transitionType: AppRouteTransitionType.slideFromRight,
//       ),
//     ),
//     GoRoute(
//       name: 'register',
//       path: '/register',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: const RegistrationPage(),
//         transitionType: AppRouteTransitionType.slideFromLeft,
//       ),
//     ),
//     GoRoute(
//       name: 'homePage',
//       path: '/homePage',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: HomePage(),
//         transitionType: AppRouteTransitionType.fade,
//       ),
//     ),
//     GoRoute(
//       name: 'product',
//       path: '/product',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: ProductsTable(),
//         transitionType: AppRouteTransitionType.fade,
//       ),
//     ),
//     GoRoute(
//       name: 'dashboard',
//       path: '/dashboard',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: const DashboardPage(),
//         transitionType: AppRouteTransitionType.scale,
//       ),
//     ),
//     GoRoute(
//       name: 'settings',
//       path: '/settings',
//       pageBuilder: (context, state) => buildPageRoute(
//         context: context,
//         state: state,
//         child: const SettingsPage(),
//         transitionType: AppRouteTransitionType.scale,
//       ),
//     ),
//   ],
// );
//
//
// class AuthGuard {
//   static String? checkAccess(BuildContext context, String routePath) {
//     final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
//     final isAdmin = authState.maybeMap(
//       authenticated: (auth) => auth.user.isAdmin,
//       orElse: () => false,
//     );
//
//     final adminOnlyRoutes = ['/products', '/dashboard'];
//
//     if (adminOnlyRoutes.contains(routePath) && !isAdmin) {
//       return '/homepage'; // Redirect non-admins
//     }
//
//     return null; // Allow access
//   }
// }


import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/features/home_page/presentation/pages/home_page.dart';
import 'package:firebase_admin/app/features/products/presentation/widgets/products_table.dart';
import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/initialization/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'app_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) async {
    final authState = ProviderScope.containerOf(context).read(authNotifierProvider);

    // Always allow splash screen
    if (state.uri.path == '/splash') return null;

    // Show loading screen if auth state is loading
    if (authState is Loading) return '/loading';

    return authState.when(
      initial: () => '/splash', // Shouldn't normally happen as we start at splash
      loading: () => '/loading',
      authenticated: (user) {
        // Check if trying to access admin-only routes
        if (!user.isAdmin && _isAdminOnlyRoute(state.uri.path)) {
          return '/homepage'; // Redirect non-admins from admin routes
        }
        return null; // Allow access for all other routes
      },
      unauthenticated: () {
        // Allow access to auth routes when unauthenticated
        if (_isAuthRoute(state.uri.path)) return null;
        return '/login'; // Redirect to login for other routes
      },
      error: (error) {
        // On error, allow retry on login screen
        if (state.uri.path == '/login') return null;
        return '/login';
      },
    );
  },
  routes: [
    // Root redirect
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
        return authState.maybeMap(
          authenticated: (_) => '/homepage',
          orElse: () => '/login',
        );
      },
    ),

    // Loading screen
    GoRoute(
      name: 'loading',
      path: '/loading',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CustomLoadingScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),

    // Splash screen
    GoRoute(
      name: 'splash',
      path: '/splash',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SplashScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),

    // Auth routes
    GoRoute(
      name: 'login',
      path: '/login',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const LoginPage(),
        transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),
    GoRoute(
      name: 'register',
      path: '/register',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const RegistrationPage(),
        transitionType: AppRouteTransitionType.slideFromLeft,
      ),
    ),

    // Main app routes
    GoRoute(
      name: 'homepage',
      path: '/homepage',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const HomePage(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),

    // Admin-only routes (protected in redirect logic)
    GoRoute(
      name: 'products',
      path: '/products',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const ProductsTable(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),
    GoRoute(
      name: 'dashboard',
      path: '/dashboard',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const DashboardPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),

    // Settings route (accessible to all authenticated users)
    GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SettingsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
  ],
);

// Helper functions
bool _isAdminOnlyRoute(String path) {
  return ['/dashboard', '/products'].contains(path);
}

bool _isAuthRoute(String path) {
  return ['/login', '/register', '/splash'].contains(path);
}