// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:firebase_admin/app/config/presentation/widgets/responsive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/presentation/widgets/stats_card.dart';
import '../../../products/presentation/pages/add_product_page.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/products_table.dart';
import '../../../stores/presentation/providers/stores_provider.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsProvider>().loadProducts();
      context.read<StoresProvider>().loadStores();
    });
  }
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final storesProvider = Provider.of<StoresProvider>(context);

    return ResponsiveScaffold(

      floatingActionButton: FloatingActionButton(
        onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddProductPage(),
        ),
      );
    },
    child: const Icon(Icons.add),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive stats grid
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        StatsCard(
                          title: 'Total Products',
                          value: productsProvider.products.length.toString(),
                          icon: Icons.inventory_2,
                        ),
                        const SizedBox(width: 16),
                        StatsCard(
                          title: 'Total Stores',
                          value: storesProvider.stores.length.toString(),
                          icon: Icons.store,
                        ),
                      ],
                    ),
                  );
                } else {
                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: constraints.maxWidth < 1024 ? 2 : 4,
                    childAspectRatio: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      StatsCard(
                        title: 'Total Products',
                        value: productsProvider.products.length.toString(),
                        icon: Icons.inventory_2,
                      ),
                      StatsCard(
                        title: 'Total Stores',
                        value: storesProvider.stores.length.toString(),
                        icon: Icons.store,
                      ),
                      StatsCard(
                        title: 'Out of Stock',
                        value: productsProvider.outOfStockCount.toString(),
                        icon: Icons.warning,
                      ),
                      StatsCard(
                        title: 'Low Stock',
                        value: productsProvider.lowStockCount.toString(),
                        icon: Icons.error_outline,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ProductsTable(products: productsProvider.recentProducts),
            ),
          ],
        ),
      ), title: 'DashBoard',
    );
  }
}