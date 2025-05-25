import 'package:firebase_admin/app/config/widgets/loading_screen.dart';
import 'package:firebase_admin/app/features/customer/presentation/customers_page.dart';
import 'package:firebase_admin/app/features/notifications/presentation/notifications_page.dart';
import 'package:firebase_admin/app/features/order/presentation/order.dart';
import 'package:firebase_admin/app/features/settings/presentation/pages/settings_page.dart';
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
// lib/config/routes/app_routes.dart

class AppRoutes {
  // Route names
  static const splash = 'splash';
  static const loading = 'loading';
  static const login = 'login';
  static const register = 'register';
  static const landing = 'landing';
  static const dashboard = 'dashboard';
  static const home = 'homePage';
  static const product = 'product';
  static const order = 'order';
  static const customer = 'customer';
  static const notifications = 'notifications';
  static const settings = 'settings';

  static const splashPath = '/splash';
  static const loadingPath = '/loading';
  static const loginPath = '/login';
  static const registerPath = '/register';
  static const landingPath = '/landing';
  static const dashboardPath = '/dashboard';
  static const homePath = '/homePage';
  static const productPath = '/product';
  static const orderPath = '/order';
  static const customerPath = '/customer';
  static const notificationsPath = '/notifications';
  static const settingsPath = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splashPath,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final authState = ProviderScope.containerOf(context).read(authNotifierProvider);
        return authState.maybeMap(
          authenticated: (_) => AppRoutes.homePath,
          orElse: () => AppRoutes.loginPath,
        );
      },
    ),

    GoRoute(
      name: AppRoutes.splash,
      path: AppRoutes.splashPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SplashScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),

    GoRoute(
      name: AppRoutes.loading,
      path: AppRoutes.loadingPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CustomLoadingScreen(),
        transitionType: AppRouteTransitionType.fade,
      ),
    ),

    GoRoute(
      name: AppRoutes.login,
      path: AppRoutes.loginPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const LoginPage(),
        transitionType: AppRouteTransitionType.slideFromRight,
      ),
    ),

    GoRoute(
      name: AppRoutes.register,
      path: AppRoutes.registerPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const RegistrationPage(),
        transitionType: AppRouteTransitionType.slideFromLeft,
      ),
    ),

    GoRoute(
      name: AppRoutes.dashboard,
      path: AppRoutes.dashboardPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const DashboardPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),

    GoRoute(
      name: AppRoutes.home,
      path: AppRoutes.homePath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const HomePage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),

    GoRoute(
      name: AppRoutes.product,
      path: AppRoutes.productPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const ProductsTable(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.order,
      path: AppRoutes.orderPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const OrderPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),    GoRoute(
      name: AppRoutes.customer,
      path: AppRoutes.customerPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const CustomersPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),    GoRoute(
      name: AppRoutes.notifications,
      path: AppRoutes.notificationsPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const NotificationsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
    GoRoute(
      name: AppRoutes.settings,
      path: AppRoutes.settingsPath,
      pageBuilder: (context, state) => buildPageRoute(
        context: context,
        state: state,
        child: const SettingsPage(),
        transitionType: AppRouteTransitionType.scale,
      ),
    ),
  ],
);