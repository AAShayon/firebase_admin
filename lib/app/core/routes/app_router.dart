import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/initialization/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/registration_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import 'app_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
      name: 'settings',
      path: '/settings',
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child:  SettingsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
  ],
);