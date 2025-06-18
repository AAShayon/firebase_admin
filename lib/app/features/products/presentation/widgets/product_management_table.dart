// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../core/routes/app_router.dart';
// import '../../../shared/domain/entities/product_entity.dart';
// import '../providers/product_notifier_provider.dart';
// import 'product_variant_card.dart'; // Import the new card
//
// class ProductManagementLayout extends ConsumerWidget {
//   final List<ProductEntity> products;
//
//   const ProductManagementLayout({
//     super.key,
//     required this.products,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth < 600) {
//           // Use the beautiful card list for mobile screens
//           return _buildCardList(context, ref);
//         } else {
//           // Use the more compact DataTable for wider screens
//           return _buildDataTable(context, ref);
//         }
//       },
//     );
//   }
//
//   // --- Mobile View: A list of cards ---
//   Widget _buildCardList(BuildContext context, WidgetRef ref) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         final product = products[index];
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: product.variants.map((variant) {
//             return ProductVariantCard(
//               product: product,
//               variant: variant,
//               onEdit: () => context.pushNamed(AppRoutes.addProduct, extra: product),
//               onDelete: () => _showDeleteDialog(context, ref, product),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
//
//   // --- Desktop View: The DataTable ---
//   Widget _buildDataTable(BuildContext context, WidgetRef ref) {
//     final List<Map<String, dynamic>> flatProductList = [];
//     for (var product in products) {
//       for (var variant in product.variants) {
//         flatProductList.add({'product': product, 'variant': variant});
//       }
//     }
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columnSpacing: 20,
//         headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
//         columns: const [
//           DataColumn(label: Text('Product Name')),
//           DataColumn(label: Text('Variant')),
//           DataColumn(label: Text('Availability')),
//           DataColumn(label: Text('Stock')),
//           DataColumn(label: Text('Actions')),
//         ],
//         rows: flatProductList.map((data) {
//           final ProductEntity product = data['product'];
//           final ProductVariantEntity variant = data['variant'];
//           final bool isInStock = variant.quantity > 0;
//
//           return DataRow(cells: [
//             DataCell(Text(product.title)),
//             DataCell(Text('${variant.size} - ${variant.color}')),
//             DataCell(
//               Text(
//                 isInStock ? 'In Stock' : 'Out of Stock',
//                 style: TextStyle(color: isInStock ? Colors.green : Colors.red),
//               ),
//             ),
//             DataCell(Text(variant.quantity.toString())),
//             DataCell(
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.edit, size: 20),
//                     onPressed: () => context.pushNamed(AppRoutes.addProduct, extra: product),
//                     tooltip: 'Edit Product',
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.delete, size: 20),
//                     onPressed: () => _showDeleteDialog(context, ref, product),
//                     tooltip: 'Delete Product',
//                   ),
//                 ],
//               ),
//             ),
//           ]);
//         }).toList(),
//       ),
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Product?'),
//         content: Text('Are you sure you want to delete "${product.title}"? This will remove all its variants and cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
//           FilledButton(
//             style: FilledButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               ref.read(productNotifierProvider.notifier).deleteProduct(product.id);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../providers/product_notifier_provider.dart';

class EnhancedProductTable extends ConsumerWidget {
  final List<ProductEntity> products;

  const EnhancedProductTable({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      // Add padding around the entire scrollable area
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        // The single horizontal scroll view is essential.
        scrollDirection: Axis.horizontal,
        child: Table(
          // THIS IS THE KEY FIX:
          // Use explicit column widths instead of relying on intrinsic calculation,
          // which was causing the overflow error.
          columnWidths: const {
            0: FixedColumnWidth(120.0), // Product Name
            1: FixedColumnWidth(80.0),  // Variant
            2: FixedColumnWidth(60.0),  // Color
            3: FixedColumnWidth(60.0),  // Stock
            4: FixedColumnWidth(100.0), // Actions (enough space for 2 compact icons)
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1.0),
            borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            // Table Header
            TableRow(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              children: [
                _buildHeaderCell('Product Name'),
                _buildHeaderCell('Variant'),
                _buildHeaderCell('Color'),
                _buildHeaderCell('Stock'),
                _buildHeaderCell('Actions'),
              ],
            ),
            // Generate all data rows
            ..._buildDataRows(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  List<TableRow> _buildDataRows(BuildContext context, WidgetRef ref) {
    final List<TableRow> rows = [];
    for (final product in products) {
      for (int i = 0; i < product.variants.length; i++) {
        final variant = product.variants[i];
        rows.add(
          TableRow(
            children: [
              // 1. Product Name Cell (with merged look)
              _buildCell(
                i == 0
                    ? Text(product.title, style: const TextStyle(fontWeight: FontWeight.w500))
                    : const SizedBox.shrink(),
              ),
              // 2. Variant Cell
              _buildCell(Text(variant.size)),
              // 3. Color Cell
              _buildCell(
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getColorFromString(variant.color.toString()),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ),
              // 4. Stock Cell
              _buildCell(
                Text(
                  variant.quantity.toString(),
                  style: TextStyle(
                    color: variant.quantity > 0 ? Colors.green.shade700 : Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 5. Actions Cell
              TableCell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => context.pushNamed(AppRoutes.addProduct, extra: product),
                      tooltip: 'Edit Product',
                      // Make button compact to prevent overflow
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _showDeleteDialog(context, ref, product),
                      tooltip: 'Delete Product',
                      // Make button compact to prevent overflow
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
    return rows;
  }

  // Helper to create consistently padded cells
  Widget _buildCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: child,
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.title}"? This will remove all its variants and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(productNotifierProvider.notifier).deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static Color _getColorFromString(String colorName) {
    final normalizedColor = colorName.split('.').last.toLowerCase();
    const colorMap = {
      'red': Colors.red, 'blue': Colors.blue, 'green': Colors.green, 'yellow': Colors.yellow,
      'white': Colors.white, 'black': Colors.black, 'grey': Colors.grey, 'orange': Colors.orange,
      'pink': Colors.pink, 'purple': Colors.purple,
    };
    return colorMap[normalizedColor] ?? Colors.grey.shade300;
  }
}