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

class NavigationRailSection extends ConsumerWidget {
  const NavigationRailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAdmin = authState.maybeMap(
      authenticated: (auth) => auth.user.isAdmin,
      orElse: () => false,
    );

    return Consumer(
      builder: (context, ref, child) {
        final isSigningOut = ref.watch(authNotifierProvider).maybeMap(
          loading: (_) => true,
          orElse: () => false,
        );

        return NavigationRail(
          extended: MediaQuery.of(context).size.width >= 1024,
          destinations: [
            NavigationRailDestination(
              icon: const Icon(Icons.home),
              label: const Text('Home'),
            ),

            const NavigationRailDestination(
              icon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            if (isAdmin) const NavigationRailDestination(
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
            const NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
            ),
            NavigationRailDestination(
              icon: isSigningOut
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(Icons.logout),
              label: isSigningOut
                  ? Text('Signing out...')
                  : Text('Sign Out'),
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: isSigningOut
              ? null
              : (index) async {
            if (isSigningOut) return;

            switch (index) {
              case 0:
                context.goNamed('homepage');
                break;
              case 1:
                if (isAdmin) context.pushNamed('dashboard');
                break;
              case 2:
                if (isAdmin) context.pushNamed('products');
                break;
              case 3:
                context.pushNamed('orders');
                break;
              case 4:
                context.pushNamed('customers');
                break;
              case 5:
                context.pushNamed('notifications');
                break;
              case 6:
                context.pushNamed('settings');
                break;
              case 7:
                await _handleSignOut(ref, context);
                break;
            }
          },
        );
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.goNamed('homepage'),
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => context.pushNamed('/dashboard'),
            ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Products'),
              onTap: () => context.pushNamed('/products'),
            ),
          const ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Orders'),
          ),
          const ListTile(
            leading: Icon(Icons.people),
            title: Text('Customers'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Push Notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.pushNamed('settings'),
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
    );
  }
}