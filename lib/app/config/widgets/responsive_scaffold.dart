import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_notifier_provider.dart';


class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768;
    log("Size of width =================> ${MediaQuery.of(context).size.width}");

    if (isDesktop || isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            ...?actions,
          ],
        ),
        body: Row(
          children: [const NavigationRailSection(), Expanded(child: body)],
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(icon: const Icon(Icons.person), onPressed: () {}),
            ...?actions,
          ],
        ),
        drawer: const NavigationDrawerSection(),
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }
  }
}

// class NavigationRailSection extends ConsumerWidget {
//   const NavigationRailSection({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return NavigationRail(
//       extended: MediaQuery.of(context).size.width >= 1024,
//       destinations: [
//         const NavigationRailDestination(
//           icon: Icon(Icons.dashboard),
//           label: Text('Dashboard'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.inventory_2),
//           label: Text('Products'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.shopping_cart),
//           label: Text('Orders'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.people),
//           label: Text('Customers'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.notifications),
//           label: Text('Push Notifications'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.settings),
//           label: Text('Settings'),
//         ),
//         const NavigationRailDestination(
//           icon: Icon(Icons.logout),
//           label: Text('Sign Out'),
//         ),
//       ],
//       selectedIndex: 0,
//       onDestinationSelected: (index) {
//         if(index == 4){
//           context.goNamed('settings');
//         }
//         if (index == 5) {
//           // When "Sign Out" is selected
//           ref.read(authNotifierProvider.notifier).signOut();
//           context.goNamed('login');
//         }
//
//       },
//     );
//   }
// }
//
// class NavigationDrawerSection extends ConsumerWidget {
//   const NavigationDrawerSection({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(child: Text('eCommerce Admin')),
//           const ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
//           const ListTile(leading: Icon(Icons.inventory_2), title: Text('Products')),
//           const ListTile(leading: Icon(Icons.shopping_cart), title: Text('Orders')),
//           const ListTile(leading: Icon(Icons.people), title: Text('Customers')),
//           const ListTile(
//             leading: Icon(Icons.notifications),
//             title: Text('Push Notifications'),
//           ),
//            ListTile(leading: Icon(Icons.settings), title: Text('Settings'),
//             onTap: (){
//               context.goNamed('settings');
//             },),
//           const Divider(),
//           ListTile(
//             leading: const Icon(Icons.logout),
//             title: const Text('Sign Out'),
//             onTap:(){
//               ref.read(authNotifierProvider.notifier).signOut();
//               context.goNamed('login');
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // static void _handleSignOut(BuildContext context) {
//   //   final ref = context.ref;
//   //   ref.read(authNotifierProvider.notifier).signOut();
//   //   context.goNamed('login');
//   // }
// }
class NavigationRailSection extends ConsumerWidget {
  const NavigationRailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAdmin = authState.maybeMap(
      authenticated: (auth) => auth.user.isAdmin,
      orElse: () => false,
    );
    final isSigningOut = authState.maybeMap(
      loading: (_) => true,
      orElse: () => false,
    );

    return NavigationRail(
      extended: MediaQuery.of(context).size.width >= 1024,
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('Products'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.shopping_cart),
          label: Text('Orders'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Customers'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.notifications),
          label: Text('Push Notifications'),
        ),
        if (isAdmin) const NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        NavigationRailDestination(
          icon: isSigningOut
              ? const CircularProgressIndicator()
              : const Icon(Icons.logout),
          label: isSigningOut
              ? const Text('Signing out...')
              : const Text('Sign Out'),
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: isSigningOut
          ? null
          : (index) async {
        if (isAdmin && index == 5) {
          context.goNamed('settings');
        } else if (!isAdmin && index == 5) {
          await _handleSignOut(ref, context);
        } else if (index == 6) {
          await _handleSignOut(ref, context);
        }
      },
    );
  }
  Future<void> _handleSignOut(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: $e')),
        );
      }
    }
  }
}

class NavigationDrawerSection extends ConsumerWidget {
  const NavigationDrawerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAdmin = authState.maybeMap(
      authenticated: (auth) => auth.user.isAdmin,
      orElse: () => false,
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('eCommerce Admin')),
          const ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
          const ListTile(leading: Icon(Icons.inventory_2), title: Text('Products')),
          const ListTile(leading: Icon(Icons.shopping_cart), title: Text('Orders')),
          const ListTile(leading: Icon(Icons.people), title: Text('Customers')),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Push Notifications'),
          ),
          if (isAdmin) ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              context.goNamed('settings');
            },
          ),
          const Divider(),
          Consumer(
            builder: (context, ref, child) {
              final isSigningOut = ref.watch(authNotifierProvider).maybeMap(
                loading: (_) => true,
                orElse: () => false,
              );

              return ListTile(
                leading: isSigningOut
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.logout),
                title: isSigningOut
                    ? const Text('Signing out...')
                    : const Text('Sign Out'),
                onTap: isSigningOut
                    ? null
                    : () async {
                  try {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign out failed: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}