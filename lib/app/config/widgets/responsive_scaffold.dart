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
        const NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const NavigationRailDestination(
          icon: Icon(Icons.logout),
          label: Text('Sign Out'),
        ),
      ],
      selectedIndex: 0,
      onDestinationSelected: (index) {
        if (index == 5) {
          // When "Sign Out" is selected
          ref.read(authNotifierProvider.notifier).signOut();
          context.goNamed('login');
        }
      },
    );
  }
}

class NavigationDrawerSection extends ConsumerWidget {
  const NavigationDrawerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap:(){
              ref.read(authNotifierProvider.notifier).signOut();
              context.goNamed('login');
            },
          ),
        ],
      ),
    );
  }

  // static void _handleSignOut(BuildContext context) {
  //   final ref = context.ref;
  //   ref.read(authNotifierProvider.notifier).signOut();
  //   context.goNamed('login');
  // }
}