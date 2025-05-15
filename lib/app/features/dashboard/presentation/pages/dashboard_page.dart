// // lib/features/dashboard/presentation/pages/dashboard_page.dart
// import 'package:firebase_admin/app/config/presentation/widgets/responsive_scaffold.dart';
// import 'package:flutter/material.dart';
//
//
// import '../../../../config/presentation/widgets/stats_card.dart';
// import '../../../products/presentation/pages/add_product_page.dart';
// import '../../../products/presentation/providers/products_provider.dart';
// import '../../../products/presentation/widgets/products_table.dart';
// import '../../../stores/presentation/providers/stores_provider.dart';
//
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<ProductsProvider>().loadProducts();
//       context.read<StoresProvider>().loadStores();
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final productsProvider = Provider.of<ProductsProvider>(context);
//     final storesProvider = Provider.of<StoresProvider>(context);
//
//     return ResponsiveScaffold(
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const AddProductPage(),
//         ),
//       );
//     },
//     child: const Icon(Icons.add),
//     ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Responsive stats grid
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth < 600) {
//                   return SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         StatsCard(
//                           title: 'Total Products',
//                           value: productsProvider.products.length.toString(),
//                           icon: Icons.inventory_2,
//                         ),
//                         const SizedBox(width: 16),
//                         StatsCard(
//                           title: 'Total Stores',
//                           value: storesProvider.stores.length.toString(),
//                           icon: Icons.store,
//                         ),
//                       ],
//                     ),
//                   );
//                 } else {
//                   return GridView.count(
//                     shrinkWrap: true,
//                     crossAxisCount: constraints.maxWidth < 1024 ? 2 : 4,
//                     childAspectRatio: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     children: [
//                       StatsCard(
//                         title: 'Total Products',
//                         value: productsProvider.products.length.toString(),
//                         icon: Icons.inventory_2,
//                       ),
//                       StatsCard(
//                         title: 'Total Stores',
//                         value: storesProvider.stores.length.toString(),
//                         icon: Icons.store,
//                       ),
//                       StatsCard(
//                         title: 'Out of Stock',
//                         value: productsProvider.outOfStockCount.toString(),
//                         icon: Icons.warning,
//                       ),
//                       StatsCard(
//                         title: 'Low Stock',
//                         value: productsProvider.lowStockCount.toString(),
//                         icon: Icons.error_outline,
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Recent Products',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ProductsTable(products: productsProvider.recentProducts),
//             ),
//           ],
//         ),
//       ), title: 'DashBoard',
//     );
//   }
// }
///
// import 'package:flutter/material.dart';
// import '../../../../config/presentation/widgets/stats_card.dart';
// import '../../../products/domain/entities/product_entity.dart';
// import '../../../products/presentation/pages/add_product_page.dart';
// import '../../../products/presentation/widgets/products_table.dart';
// import 'package:firebase_admin/app/config/presentation/widgets/responsive_scaffold.dart';
//
//
// // ✅ Typed static products
// final List<ProductEntity> staticProducts = [
//   ProductEntity(
//     id: '1',
//     name: 'Product A',
//     description: 'High quality product A',
//     imageUrl: null,
//     sizes: [
//       ProductSizeEntity(size: 'S', price: 10.0, quantity: 5),
//       ProductSizeEntity(size: 'M', price: 12.0, quantity: 10),
//     ],
//     createdAt: DateTime.now().subtract(const Duration(days: 2)),
//     updatedAt: DateTime.now().subtract(const Duration(days: 1)),
//   ),
//   ProductEntity(
//     id: '2',
//     name: 'Product B',
//     description: 'Out of stock item',
//     imageUrl: null,
//     sizes: [
//       ProductSizeEntity(size: 'M', price: 15.0, quantity: 0),
//     ],
//     createdAt: DateTime.now().subtract(const Duration(days: 3)),
//     updatedAt: DateTime.now().subtract(const Duration(days: 2)),
//   ),
//   ProductEntity(
//     id: '3',
//     name: 'Product C',
//     description: 'Low stock item',
//     imageUrl: null,
//     sizes: [
//       ProductSizeEntity(size: 'L', price: 20.0, quantity: 3),
//     ],
//     createdAt: DateTime.now().subtract(const Duration(days: 1)),
//     updatedAt: DateTime.now(),
//   ),
// ];
//
// final List<String> staticStores = ['Store 1', 'Store 2'];
//
// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});
//
//   int get totalProducts => staticProducts.length;
//
//   int get outOfStockCount =>
//       staticProducts.where((product) =>
//           product.sizes.every((size) => size.quantity == 0)).length;
//
//   int get lowStockCount =>
//       staticProducts.where((product) =>
//           product.sizes.any((size) => size.quantity > 0 && size.quantity <= 5)).length;
//
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveScaffold(
//       title: 'Dashboard',
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddProductPage()),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth < 600) {
//                   return SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         StatsCard(
//                           title: 'Total Products',
//                           value: totalProducts.toString(),
//                           icon: Icons.inventory_2,
//                         ),
//                         const SizedBox(width: 16),
//                         StatsCard(
//                           title: 'Total Stores',
//                           value: staticStores.length.toString(),
//                           icon: Icons.store,
//                         ),
//                       ],
//                     ),
//                   );
//                 } else {
//                   return GridView.count(
//                     shrinkWrap: true,
//                     crossAxisCount: constraints.maxWidth < 1024 ? 2 : 4,
//                     childAspectRatio: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     children: [
//                       StatsCard(
//                         title: 'Total Products',
//                         value: totalProducts.toString(),
//                         icon: Icons.inventory_2,
//                       ),
//                       StatsCard(
//                         title: 'Total Stores',
//                         value: staticStores.length.toString(),
//                         icon: Icons.store,
//                       ),
//                       StatsCard(
//                         title: 'Out of Stock',
//                         value: outOfStockCount.toString(),
//                         icon: Icons.warning,
//                       ),
//                       StatsCard(
//                         title: 'Low Stock',
//                         value: lowStockCount.toString(),
//                         icon: Icons.error_outline,
//                       ),
//                     ],
//                   );
//                 }
//               },
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Recent Products',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ProductsTable(products: staticProducts),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_admin/app/config/presentation/widgets/responsive_scaffold.dart';
import 'package:firebase_admin/app/config/presentation/widgets/stats_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'eCommerce Admin',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              _buildStatsSection(context),
              const SizedBox(height: 24),

              // Sales Chart
              _buildSalesChartSection(),
              const SizedBox(height: 24),

              // Top Customers
              _buildTopCustomersSection(),
              const SizedBox(height: 24),

              // Push Notification
              _buildNotificationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth < 1024;

        if (isMobile) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    _buildStatCard('📦', 'Total Products', '125'),
                    const SizedBox(width: 12),
                    _buildStatCard('💰', 'Total Sales', '\$12,500'),
                    const SizedBox(width: 12),
                    _buildStatCard('👥', 'Total Customers', '85'),
                    const SizedBox(width: 12),
                    _buildStatCard('📉', 'Low Stock', '7', color: Colors.red),
                  ],
                ),
              ),
            ),
          );
        }else {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 2 : 4,
            childAspectRatio: isTablet ? 1.2 : 1.5, // Adjusted aspect ratio
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: const EdgeInsets.all(8),
            children: [
              _buildStatCard('📦', 'Total Products', '125'),
              _buildStatCard('💰', 'Total Sales', '\$12,500', color: Colors.green),
              _buildStatCard('👥', 'Total Customers', '85'),
              _buildStatCard('📉', 'Low Stock', '7', color: Colors.red),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, {Color? color}) {
    return StatsCard(
      emoji: emoji,
      title: title,
      value: value,
      color: color,
    );
  }

  Widget _buildSalesChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Sales Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Chart Placeholder',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection() {
    final customers = [
      {'name': 'John Doe', 'orders': 25, 'revenue': 1200.00},
      {'name': 'Jane Smith', 'orders': 22, 'revenue': 1050.00},
      {'name': 'Robert Johnson', 'orders': 18, 'revenue': 950.00},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧑‍💼 Top Customers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Orders')),
                  DataColumn(label: Text('Revenue')),
                ],
                rows: customers
                    .map((customer) => DataRow(cells: [
                  DataCell(Text(customer['name'].toString())),
                  DataCell(Text(customer['orders'].toString())),
                  DataCell(Text('\$${customer['revenue']}')),
                ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔔 Push Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Summer Sale',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Get 30% off on all items today!',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Send to',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: 'all',
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Customers')),
                DropdownMenuItem(value: 'active', child: Text('Active Customers')),
                DropdownMenuItem(
                    value: 'high', child: Text('High Spenders')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Send Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}