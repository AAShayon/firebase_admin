import 'package:firebase_admin/app/features/wishlist/presentation/pages/wishlist_page.dart';
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
import '../../notifications/domain/entities/notification_entity.dart';
import '../../notifications/presentation/providers/notification_providers.dart';
import '../../notifications/presentation/notifications_page.dart';

// --- PAGE WIDGET IMPORTS ---
import '../../home_page/presentation/pages/home_page.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../products/presentation/pages/product_table.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_){
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final authState = ref.read(authNotifierProvider);
    authState.maybeMap(
      authenticated: (auth) {
        ref.read(userProfileNotifierProvider.notifier).loadUserProfile(auth.user.id);
      },
      orElse: () {
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
    final userId = user?.id ?? '';

    // The unread count is now correctly role-based using the new private stream for users.
    final unreadCount = ref.watch(
        isAdmin ? unreadNotificationCountProvider : userUnreadNotificationCountProvider(userId)
    );
    final profileState = ref.watch(userProfileNotifierProvider);

    // 2. LISTEN to providers to trigger side-effects (like local notifications)

    // --- ADMIN-ONLY LISTENER ---
    // Listens to the global /notifications collection for new orders etc.
    if (isAdmin) {
      ref.listen<AsyncValue<List<NotificationEntity>>>(notificationsStreamProvider, (previous, next) {
        if (next is! AsyncData || previous == null || previous is! AsyncData) return;
        final genuinelyNewItems = (next.value ?? []).where((newItem) => !(previous.value ?? []).any((prevItem) => prevItem.id == newItem.id)).toList();
        for (final notification in genuinelyNewItems) {
          LocalNotificationService.showNotification(
            title: notification.title,
            body: notification.body,
            payload: notification.data['orderId'] as String? ?? 'system',
          );
        }
      });
    }

    // --- USER-ONLY LISTENER ---
    // This is now ONE simple listener on the user's private notification stream.
    // It will fire for promotions and future status updates sent to their inbox.
    if (user != null && !isAdmin) {
      ref.listen<AsyncValue<List<NotificationEntity>>>(userPrivateNotificationsStreamProvider(user.id), (previous, next) {
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(_currentIndex)),
          actions: [
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
              _buildDrawerItem(icon: Icons.home_outlined, title: 'Home', index: 0),
              _buildDrawerItem(icon: Icons.favorite_border, title: 'WishList', index: 1),
              if (isAdmin) _buildDrawerItem(icon: Icons.dashboard_outlined, title: 'Dashboard', index: 2),
              if (isAdmin) _buildDrawerItem(icon: Icons.inventory_2_outlined, title: 'Products', index: 3),
              _buildDrawerItem(icon: Icons.receipt_long_outlined, title: 'Orders', index: 4),
              if (isAdmin) _buildDrawerItem(icon: Icons.people_outline, title: 'Customers', index: 5),
              _buildDrawerItem(icon: Icons.notifications_outlined, title: 'Notifications', index: 6),
              _buildDrawerItem(icon: Icons.settings_outlined, title: 'Settings', index: 7),
              _buildDrawerItem(icon: Icons.shopping_cart_outlined, title: 'Cart', index: 8),
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
      leading: Icon(icon, color: _currentIndex == index ? Theme.of(context).primaryColor : null),
      title: Text(title),
      selected: _currentIndex == index,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        setState(() => _currentIndex = index);
      },
    );
  }

  String _getTitle(int index) {
    const titles = ['Home','Wishlist', 'Dashboard', 'Products', 'Orders', 'Customers', 'Notifications', 'Settings', 'Cart'];
    return titles.length > index ? titles[index] : 'Home';
  }

  Widget _getPage(int index) {
    const pages = [
      HomePage(),WishlistPage(), DashboardPage(), ProductsTable(), OrderPage(),
      CustomersPage(), NotificationsPage(), SettingsPage(), CartPage(isFromLanding: false),
    ];
    return pages.length > index ? pages[index] : const HomePage();
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
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
          ],
        )) ?? false;
  }
}