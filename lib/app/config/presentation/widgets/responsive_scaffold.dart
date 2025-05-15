import 'package:flutter/material.dart';

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
            ), // 🔔
            IconButton(icon: const Icon(Icons.person), onPressed: () {}), // 👤
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

class NavigationRailSection extends StatelessWidget {
  const NavigationRailSection({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: MediaQuery.of(context).size.width >= 1024,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory_2),
          label: Text('Products'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_cart),
          label: Text('Orders'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Customers'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications),
          label: Text('Push Notifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
      selectedIndex: 0,
    );
  }
}

class NavigationDrawerSection extends StatelessWidget {
  const NavigationDrawerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(child: Text('eCommerce Admin')),
          ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
          ListTile(leading: Icon(Icons.inventory_2), title: Text('Products')),
          ListTile(leading: Icon(Icons.shopping_cart), title: Text('Orders')),
          ListTile(leading: Icon(Icons.people), title: Text('Customers')),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Push Notifications'),
          ),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        ],
      ),
    );
  }
}
