import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier_provider.dart';
import '../../features/home_page/presentation/pages/home_page.dart';
import '../../features/initialization/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/widgets/products_table.dart';
import 'app_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (BuildContext context, GoRouterState state) async {
    final authNotifier = ProviderScope.containerOf(context).read(authNotifierProvider);

    final isSplashRoute = state.uri.path == '/splash';

    // If we're already on splash screen, no redirect needed
    if (isSplashRoute) return null;

    // Check auth state
    final isLoggedIn = authNotifier.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    );

    // Handle initial route after sign-out
    if (state.uri.path == '/') {
      return isLoggedIn ? '/homePage' : '/login';
    }

    // Restrict access to protected routes
    final isRestrictedRoute = [
      '/dashboard',
      '/settings',
    ].contains(state.uri.path);

    if (!isLoggedIn && isRestrictedRoute) {
      return '/login';
    }

    // Redirect away from auth routes if already logged in
    final isAuthRoute = [
      '/login',
      '/register',
    ].contains(state.uri.path);

    if (isLoggedIn && isAuthRoute) {
      return '/homePage';
    }

    return null;
  },
  routes: [
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
    GoRoute(
      name: 'homePage',
      path: '/homePage',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const HomePage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: 'product',
      path: '/product',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const ProductsTable(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) {
        final authNotifier = ProviderScope.containerOf(context).read(authNotifierProvider);

        // Check if user is admin
        final isAdmin = authNotifier.maybeMap(
          authenticated: (auth) => auth.user.isAdmin,
          orElse: () => false,
        );

        if (!isAdmin) {
          // Redirect non-admin users to dashboard
          return buildPageRoute(
            context: context,
            state: state,
            child: const DashboardPage(),
            transitionType: AppRouteTransitionType.scale,
          );
        }

        // Allow admin to access settings
        return buildPageRoute(
          context: context,
          state: state,
          child: const SettingsPage(),
          transitionType: AppRouteTransitionType.scale,
        );
      },
    ),
  ],
);