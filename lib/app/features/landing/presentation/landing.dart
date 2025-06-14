// import 'package:firebase_admin/app/features/cart/presentation/pages/cart_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:badges/badges.dart' as badges;
// import '../../../core/network/service/local_notification_service.dart';
// import '../../../core/routes/app_router.dart';
// import '../../auth/presentation/providers/auth_notifier_provider.dart';
// import '../../dashboard/presentation/pages/dashboard_page.dart';
// import '../../home_page/presentation/pages/home_page.dart';
// import '../../notifications/domain/entities/notification_entity.dart';
// import '../../notifications/presentation/notifications_page.dart';
// import '../../notifications/presentation/providers/notification_providers.dart';
// import '../../order/presentation/pages/orders_page.dart';
// import '../../products/presentation/widgets/products_table.dart';
// import '../../settings/presentation/pages/settings_page.dart';
// import '../../customer/presentation/customers_page.dart';
// import '../../user_profile/presentation/providers/user_profile_notifier_provider.dart';
//
// class LandingPage extends ConsumerStatefulWidget {
//   final int initialIndex;
//
//   // UPDATE the constructor to accept the index, with a default value of 0
//   const LandingPage({super.key, this.initialIndex = 0});
//   @override
//   ConsumerState<LandingPage> createState() => _LandingPageState();
// }
//
// class _LandingPageState extends ConsumerState<LandingPage> {
//   late int _currentIndex;
//   bool _isAdmin = false;
//   late String userID;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _checkAdminStatus();
//     WidgetsBinding.instance.addPostFrameCallback((_){
//     _loadProfile();
//     });
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
//     if(_isAdmin){
//       _setupNotificationListener();
//     }
//   }
//   void _setupNotificationListener() {
//     // This listener will react to every change in the notifications stream.
//     ref.listen<AsyncValue<List<NotificationEntity>>>(notificationsStreamProvider, (previous, next) {
//       // We only care about successful data events, not loading or error states here.
//       if (next is AsyncData) {
//         final previousData = previous?.valueOrNull ?? [];
//         final nextData = next.valueOrNull ?? [];
//
//         // If the new list has more items than the old one, it means a new notification arrived.
//         if (nextData.length > previousData.length) {
//           // The newest notification is always the first one in the list (since we sort by time).
//           final newNotification = nextData.first;
//
//           // Show a local notification on the admin's device.
//           LocalNotificationService.showNotification(
//             title: newNotification.title,
//             body: newNotification.body,
//             payload: newNotification.data['orderId'] ?? '',
//           );
//         }
//       }
//     });
//   }
//   Future<void> _loadProfile() async {
//     final authState = ref.read(authNotifierProvider);
//     authState.maybeMap(
//       authenticated: (auth) {
//         userID = auth.user.id;
//         ref.read(userProfileNotifierProvider.notifier).loadUserProfile(userID);
//       },
//       orElse: () {},
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authNotifierProvider);
//     final profileState = ref.watch(userProfileNotifierProvider);
//     final user = authState.maybeMap(
//       authenticated: (auth) => auth.user,
//       orElse: () => null,
//     );
//     final unreadCount = ref.watch(unreadNotificationCountProvider);
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(_getTitle(_currentIndex)),
//           actions: [
//             if (_currentIndex == 2 && _isAdmin)
//               IconButton(
//                 icon: const Icon(Icons.add),
//                 onPressed: () => context.pushNamed(AppRoutes.addProduct),
//               ),
//             IconButton(
//               icon: badges.Badge(
//                 showBadge: unreadCount > 0,
//                 badgeContent: Text(
//                   unreadCount.toString(),
//                   style: const TextStyle(color: Colors.white, fontSize: 10),
//                 ),
//                 child: const Icon(Icons.notifications_outlined),
//               ),
//               onPressed: () {
//                 // Navigate to the Notifications tab in the LandingPage
//                 setState(() => _currentIndex = 5);
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.person),
//               onPressed: () {
//                 context.goNamed(AppRoutes.profile);
//               },
//             ),
//           ],
//         ),
//         drawer: Drawer(
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               UserAccountsDrawerHeader(
//                 accountName: profileState.maybeWhen(
//                   loaded: (profile) => Text(profile.displayName ?? 'No name'),
//                   orElse: () => const Text('Loading...'),
//                 ),
//                 accountEmail: Text(user?.email ?? 'No email'),
//                 currentAccountPicture: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     user?.displayName?.isNotEmpty == true ? user!.displayName![0] : '?',
//                     style: const TextStyle(fontSize: 30),
//                   ),
//                 ),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.home),
//                 title: const Text('Home'),
//                 selected: _currentIndex == 0,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 0);
//                 },
//               ),
//               if (_isAdmin)
//                 ListTile(
//                   leading: const Icon(Icons.dashboard),
//                   title: const Text('Dashboard'),
//                   selected: _currentIndex == 1,
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() => _currentIndex = 1);
//                   },
//                 ),
//               if (_isAdmin)
//                 ListTile(
//                   leading: const Icon(Icons.inventory_2),
//                   title: const Text('Products'),
//                   selected: _currentIndex == 2,
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() => _currentIndex = 2);
//                   },
//                 ),
//               ListTile(
//                 leading: const Icon(Icons.shopping_cart),
//                 title: const Text('Orders'),
//                 selected: _currentIndex == 3,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 3);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.people),
//                 title: const Text('Customers'),
//                 selected: _currentIndex == 4,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 4);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.notifications),
//                 title: const Text('Notifications'),
//                 selected: _currentIndex == 5,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 5);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings),
//                 title: const Text('Settings'),
//                 selected: _currentIndex == 6,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 6);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.shopping_cart),
//                 title: const Text('Cart'),
//                 selected: _currentIndex == 7,
//                 onTap: () {
//                   Navigator.pop(context);
//                   setState(() => _currentIndex = 7);
//                 },
//               ),
//               const Divider(),
//               Consumer(
//                 builder: (context, ref, _) {
//                   final isSigningOut = ref.watch(authNotifierProvider).maybeMap(
//                     loading: (_) => true,
//                     orElse: () => false,
//                   );
//                   return ListTile(
//                     leading: isSigningOut
//                         ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                         : const Icon(Icons.logout),
//                     title: isSigningOut
//                         ? const Text('Signing out...')
//                         : const Text('Sign Out'),
//                     onTap: isSigningOut
//                         ? null
//                         : () async {
//                       try {
//                         await ref
//                             .read(authNotifierProvider.notifier)
//                             .signOut();
//                         if (context.mounted) {
//                           Navigator.pop(context);
//                           context.go('/login');
//                         }
//                       } catch (e) {
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text('Sign out failed: $e')),
//                           );
//                         }
//                       }
//                     },
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         body: _getPage(_currentIndex),
//       ),
//     );
//   }
//
//   String _getTitle(int index) {
//     switch (index) {
//       case 0:
//         return 'Home';
//       case 1:
//         return 'Dashboard';
//       case 2:
//         return 'Products';
//       case 3:
//         return 'Orders';
//       case 4:
//         return 'Customers';
//       case 5:
//         return 'Notifications';
//       case 6:
//         return 'Settings';
//       case 7:
//         return 'Cart';
//       default:
//         return 'Home';
//     }
//   }
//
//   Widget _getPage(int index) {
//     switch (index) {
//       case 0:
//         return const HomePage();
//       case 1:
//         return const DashboardPage();
//       case 2:
//         return const ProductsTable();
//       case 3:
//         return const OrderPage();
//       case 4:
//         return const CustomersPage();
//       case 5:
//         return const NotificationsPage();
//       case 6:
//         return const SettingsPage();
//       case 7:
//         return  CartPage(isFromLanding: false,);
//       default:
//         return const HomePage();
//     }
//   }
//
//   Future<bool> _onWillPop() async {
//     if (_currentIndex != 0) {
//       setState(() => _currentIndex = 0);
//       return false;
//     }
//     return await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Exit App'),
//           content: const Text('Do you want to exit the application?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('Yes'),
//             ),
//           ],
//         )) ??
//         false;
//   }
//
//   void _updateIndex(int index) {
//     if (_currentIndex == index) return;
//     setState(() => _currentIndex = index);
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

// Import all necessary pages and providers for this page
import '../../../core/routes/app_router.dart';
import '../../../core/network/service/local_notification_service.dart';

import '../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../user_profile/presentation/providers/user_profile_notifier_provider.dart';

import '../../notifications/domain/entities/notification_entity.dart';
import '../../notifications/presentation/providers/notification_providers.dart';
import '../../notifications/presentation/notifications_page.dart';

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
        // This is a good place for a defensive logout.
        context.go(AppRoutes.loginPath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- THIS IS THE CORRECT PLACE FOR LISTENERS AND WATCHERS ---

    // 1. WATCH providers to get data and rebuild the UI when it changes.
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(userProfileNotifierProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    final user = authState.maybeMap(
      authenticated: (auth) => auth.user,
      orElse: () => null,
    );
    final isAdmin = user?.isAdmin ?? false;

    // 2. LISTEN to providers to perform actions (like showing a notification)
    //    without causing a rebuild. This is the correct place for your listener logic.
    if (isAdmin) {
      ref.listen<AsyncValue<List<NotificationEntity>>>(notificationsStreamProvider, (previous, next) {
        // We only care about successful data events.
        if (next is AsyncData) {
          final previousData = previous?.valueOrNull ?? [];
          final nextData = next.valueOrNull ?? [];

          // This logic finds notifications that are in the new list but weren't in the old one.
          // This prevents showing a notification for old data when the listener first starts.
          final newNotifications = nextData.where((n) => !previousData.any((p) => p.id == n.id)).toList();

          for (final notification in newNotifications) {
            // Show a local notification on the admin's device for each new item.
            LocalNotificationService.showNotification(
              title: notification.title,
              body: notification.body,
              payload: notification.data['orderId'] as String? ?? '',
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

  // Helper widget to reduce code duplication in the drawer.
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