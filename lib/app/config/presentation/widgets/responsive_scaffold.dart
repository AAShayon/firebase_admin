// lib/core/presentation/widgets/responsive_scaffold.dart
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
          actions: actions,
        ),
        body: Row(
          children: [
            const NavigationRailSection(),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
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
          icon: Icon(Icons.store),
          label: Text('Stores'),
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
          DrawerHeader(child: Text('Admin Panel')),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.inventory_2),
            title: Text('Products'),
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Stores'),
          ),
        ],
      ),
    );
  }
}