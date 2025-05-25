import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/widgets/responsive_scaffold.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../customer/presentation/customers_page.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../home_page/presentation/pages/home_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../order/presentation/order.dart';
import '../../products/presentation/widgets/products_table.dart';
import '../../settings/presentation/pages/settings_page.dart';
//
// class LandingPage extends ConsumerStatefulWidget {
//   const LandingPage({super.key});
//
//   @override
//   ConsumerState<LandingPage> createState() => _LandingPageState();
// }
//
// class _LandingPageState extends ConsumerState<LandingPage> {
//   int _currentIndex = 0;
//   bool _isAdmin = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAdminStatus();
//   }
//
//   Future<void> _checkAdminStatus() async {
//     final authState = ref.read(authNotifierProvider);
//     setState(() {
//       _isAdmin = authState.maybeMap(
//         authenticated: (auth) => auth.user.isAdmin,
//         orElse: () => false,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: ResponsiveScaffold(
//         title: _getTitle(_currentIndex),
//         body: _getPage(_currentIndex),
//       ),
//     );
//   }
//
//   String _getTitle(int index) {
//     switch (index) {
//       case 0: return 'Home';
//       case 1: return 'Dashboard';
//       case 2: return 'Products';
//       case 3: return 'Orders';
//       case 4: return 'Customers';
//       case 5: return 'Notifications';
//       case 6: return 'Settings';
//       default: return 'Admin Dashboard';
//     }
//   }
//
//   Widget _getPage(int index) {
//     switch (index) {
//       case 0: return const HomePage(); //why not use this? for app route
//       case 1: return const DashboardPage();
//       case 2: return const ProductsTable();
//       case 3: return const OrderPage();
//       case 4: return const CustomersPage();
//       case 5: return const NotificationsPage();
//       case 6: return const SettingsPage();
//       default: return const HomePage();
//     }
//   }
//
//   Future<bool> _onWillPop() async {
//     if (_currentIndex != 0) {
//       setState(() => _currentIndex = 0);
//       return false;
//     }
//
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Exit App'),
//         content: const Text('Do you want to exit the application?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
//
//   void _updateIndex(int index) {
//     if (_currentIndex == index) return;
//     setState(() => _currentIndex = index);
//   }
// }
class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _syncIndexWithRoute();
  }

  void _syncIndexWithRoute() {
    final route = GoRouterState.of(context).uri.path;
    setState(() {
      _currentIndex = _getIndexForRoute(route);
    });
  }

  int _getIndexForRoute(String route) {
    switch (route) {
      case AppRoutes.homePath: return 0;
      case AppRoutes.dashboardPath: return 1;
      case AppRoutes.productPath: return 2;
      case AppRoutes.orderPath: return 3;
      case AppRoutes.customerPath: return 4;
      case AppRoutes.notificationsPath: return 5;
      case AppRoutes.settingsPath: return 6;
      default: return 0;
    }
  }

  Future<void> _checkAdminStatus() async {
    final authState = ref.read(authNotifierProvider);
    setState(() {
      _isAdmin = authState.maybeMap(
        authenticated: (auth) => auth.user.isAdmin,
        orElse: () => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ResponsiveScaffold(
        title: _getTitle(_currentIndex),
        body: _getPage(_currentIndex),
        onIndexChanged: _updateIndex,
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Home';
      case 1: return 'Dashboard';
      case 2: return 'Products';
      case 3: return 'Orders';
      case 4: return 'Customers';
      case 5: return 'Notifications';
      case 6: return 'Settings';
      default: return 'Admin Dashboard';
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const HomePage();
      case 1: return const DashboardPage();
      case 2: return const ProductsTable();
      case 3: return const OrderPage();
      case 4: return const CustomersPage();
      case 5: return const NotificationsPage();
      case 6: return const SettingsPage();
      default: return const HomePage();
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      _updateIndex(0);
      return false;
    }

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _updateIndex(int index) {
    if (_currentIndex == index) return;

    final route = _getRouteForIndex(index);
    if (route != null) {
      context.go(route);
    }
    setState(() => _currentIndex = index);
  }

  String? _getRouteForIndex(int index) {
    switch (index) {
      case 0: return AppRoutes.homePath;
      case 1: return AppRoutes.dashboardPath;
      case 2: return AppRoutes.productPath;
      case 3: return AppRoutes.orderPath;
      case 4: return AppRoutes.customerPath;
      case 5: return AppRoutes.notificationsPath;
      case 6: return AppRoutes.settingsPath;
      default: return AppRoutes.homePath;
    }
  }
}