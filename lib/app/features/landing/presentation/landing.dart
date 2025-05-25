import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../home_page/presentation/pages/home_page.dart';
import '../../notifications/presentation/notifications_page.dart';
import '../../order/presentation/order.dart';
import '../../products/presentation/widgets/products_table.dart';
import '../../settings/presentation/pages/settings_page.dart';
import '../../customer/presentation/customers_page.dart';

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
    final authState = ref.watch(authNotifierProvider);
    final user = authState.maybeMap(
      authenticated: (auth) => auth.user,
      orElse: () => null,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_currentIndex)),
          actions: [
            if (_currentIndex == 2 && _isAdmin)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.pushNamed(AppRoutes.addProduct),
              ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {},
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.displayName ?? 'Admin User'),
                accountEmail: Text(user?.email ?? 'No email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.displayName?.isNotEmpty == true ? user!.displayName![0] : '?',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: _currentIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 0);
                },
              ),
              if (_isAdmin)
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  selected: _currentIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
              if (_isAdmin)
                ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Products'),
                  selected: _currentIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text('Orders'),
                selected: _currentIndex == 3,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Customers'),
                selected: _currentIndex == 4,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                selected: _currentIndex == 5,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                selected: _currentIndex == 6,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 6);
                },
              ),
              const Divider(),
              Consumer(
                builder: (context, ref, _) {
                  final isSigningOut = ref.watch(authNotifierProvider).maybeMap(
                    loading: (_) => true,
                    orElse: () => false,
                  );
                  return ListTile(
                    leading: isSigningOut
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.logout),
                    title: isSigningOut
                        ? const Text('Signing out...')
                        : const Text('Sign Out'),
                    onTap: isSigningOut
                        ? null
                        : () async {
                      try {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          context.go('/login');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Sign out failed: $e')),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: _getPage(_currentIndex),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Products';
      case 3:
        return 'Orders';
      case 4:
        return 'Customers';
      case 5:
        return 'Notifications';
      case 6:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const DashboardPage();
      case 2:
        return const ProductsTable();
      case 3:
        return const OrderPage();
      case 4:
        return const CustomersPage();
      case 5:
        return const NotificationsPage();
      case 6:
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
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
        )) ??
        false;
  }

  void _updateIndex(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }
}