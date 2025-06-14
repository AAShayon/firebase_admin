import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

// --- CORE & SHARED IMPORTS ---
import '../../../core/routes/app_router.dart';
import '../../../core/network/service/local_notification_service.dart';

// --- FEATURE-SPECIFIC IMPORTS ---
import '../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../user_profile/presentation/providers/user_profile_notifier_provider.dart';

import '../../order/domain/entities/order_entity.dart';
import '../../order/presentation/providers/order_providers.dart';

import '../../notifications/domain/entities/notification_entity.dart';
import '../../notifications/presentation/providers/notification_providers.dart';
import '../../notifications/presentation/notifications_page.dart';

// --- PAGE WIDGET IMPORTS ---
import '../../home_page/presentation/pages/home_page.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../products/presentation/widgets/products_table.dart';
import '../../order/presentation/pages/orders_page.dart';
import '../../customer/presentation/customers_page.dart';
import '../../settings/presentation/pages/settings_page.dart';
import '../../cart/presentation/pages/cart_page.dart';


class LandingPage extends ConsumerStatefulWidget {
  final int initialIndex;

  const LandingPage({super.key, this.initialIndex = 0});
  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // This runs after the first frame is built, ensuring `ref` is available.
    // Its only job is to trigger data loading that doesn't depend on the build context.
    WidgetsBinding.instance.addPostFrameCallback((_){
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    // We can read the auth state here to get the user ID for fetching the profile.
    final authState = ref.read(authNotifierProvider);
    authState.maybeMap(
      authenticated: (auth) {
        ref.read(userProfileNotifierProvider.notifier).loadUserProfile(auth.user.id);
      },
      orElse: () {
        // Handle case where user is not authenticated but somehow reached this page.
        if (context.mounted) {
          context.go(AppRoutes.loginPath);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. WATCH providers to get data for the UI
    final authState = ref.watch(authNotifierProvider);
    final user = authState.maybeMap(authenticated: (auth) => auth.user, orElse: () => null);
    final isAdmin = user?.isAdmin ?? false;

    final unreadCount = ref.watch(isAdmin ? unreadNotificationCountProvider : userUnreadNotificationCountProvider(user?.id ?? ''));
    final profileState = ref.watch(userProfileNotifierProvider);

    // --- FULLY CORRECTED AND FINAL LISTENER LOGIC ---
    // ADMIN LISTENER: For new orders AND public promotions
    if (isAdmin) {
      ref.listen<AsyncValue<List<NotificationEntity>>>(notificationsStreamProvider, (previous, next) {
        if (next is! AsyncData || previous == null || previous is! AsyncData) return;
        final genuinelyNewItems = (next.value ?? []).where((newItem) => !(previous.value ?? []).any((prevItem) => prevItem.id == newItem.id)).toList();
        for (final notification in genuinelyNewItems) {
          LocalNotificationService.showNotification(
            title: notification.title,
            body: notification.body,
            payload: notification.data['orderId'] as String? ?? 'promotion',
          );
        }
      });
    }

    // USER LISTENER: For THEIR order updates AND public promotions
    if (user != null && !isAdmin) {
      // Listener for order status updates
      ref.listen<AsyncValue<List<OrderEntity>>>(userOrdersStreamProvider(user.id), (previous, next) {
        if (next is! AsyncData || previous == null || previous.valueOrNull == null) return;
        final prevOrders = previous.value!;
        final nextOrders = next.value!;
        if (prevOrders.length != nextOrders.length) return;
        final prevOrdersMap = {for (var o in prevOrders) o.id: o.status};
        for (final nextOrder in nextOrders) {
          final oldStatus = prevOrdersMap[nextOrder.id];
          if (oldStatus != null && oldStatus != nextOrder.status) {
            LocalNotificationService.showNotification(
              title: 'Order Status Updated',
              body: 'Your order #${nextOrder.id.substring(0, 8)}... is now ${nextOrder.status.toString().split('.').last}.',
              payload: nextOrder.id,
            );
          }
        }
      });

      // Listener for public/promotional notifications
      ref.listen<AsyncValue<List<NotificationEntity>>>(publicNotificationsStreamProvider, (previous, next) {
        if (next is! AsyncData || previous == null || previous is! AsyncData) return;
        final genuinelyNewItems = (next.value ?? []).where((newItem) => !(previous.value ?? []).any((prevItem) => prevItem.id == newItem.id)).toList();
        for (final notification in genuinelyNewItems) {
          final target = notification.data['target'] as String?;
          if (target == 'all_users' || target == user.id) {
            LocalNotificationService.showNotification(
              title: notification.title,
              body: notification.body,
              payload: 'promotion',
            );
          }
        }
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_currentIndex)),
          actions: [
            if (_currentIndex == 2 && isAdmin)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.pushNamed(AppRoutes.addProduct),
              ),
            IconButton(
              tooltip: 'Notifications',
              icon: badges.Badge(
                showBadge: unreadCount > 0,
                badgeContent: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                child: const Icon(Icons.notifications_outlined),
              ),
              onPressed: () => setState(() => _currentIndex = 5),
            ),
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.goNamed(AppRoutes.profile),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: profileState.maybeWhen(
                  loaded: (profile) => Text(profile.displayName ?? 'No Name'),
                  orElse: () => const Text('Loading...'),
                ),
                accountEmail: Text(user?.email ?? 'No Email'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 30, color: Colors.blueGrey),
                  ),
                ),
              ),
              _buildDrawerItem(icon: Icons.home, title: 'Home', index: 0),
              if (isAdmin)
                _buildDrawerItem(icon: Icons.dashboard, title: 'Dashboard', index: 1),
              if (isAdmin)
                _buildDrawerItem(icon: Icons.inventory_2, title: 'Products', index: 2),
              _buildDrawerItem(icon: Icons.receipt_long, title: 'Orders', index: 3),
              _buildDrawerItem(icon: Icons.people, title: 'Customers', index: 4),
              _buildDrawerItem(icon: Icons.notifications, title: 'Notifications', index: 5),
              _buildDrawerItem(icon: Icons.settings, title: 'Settings', index: 6),
              _buildDrawerItem(icon: Icons.shopping_cart_outlined, title: 'Cart', index: 7),
              const Divider(),
              Consumer(
                builder: (context, ref, _) {
                  final isSigningOut = ref.watch(authNotifierProvider).maybeMap(
                    loading: (_) => true,
                    orElse: () => false,
                  );
                  return ListTile(
                    leading: isSigningOut
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: isSigningOut ? null : () async {
                      try {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.loginPath);
                        }
                      } catch (e) {
                        // Optionally show an error snackbar
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

  Widget _buildDrawerItem({required IconData icon, required String title, required int index}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _currentIndex == index,
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentIndex = index);
      },
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
      case 7: return 'Cart';
      default: return 'Home';
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
      case 7: return CartPage(isFromLanding: false);
      default: return const HomePage();
    }
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false; // Prevents the app from closing
    }
    return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Do you want to exit the application?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
          ],
        )) ?? false;
  }
}