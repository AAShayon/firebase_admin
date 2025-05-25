import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admin/app/config/widgets/responsive_scaffold.dart';

// Sample Product Entity
class ProductEntitys {
  final String name;
  final String description;
  final String imageUrl;
  final List<ProductSize> sizes;

  ProductEntitys({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sizes,
  });
}

class ProductSize {
  final String size;
  final int quantity;

  ProductSize({required this.size, required this.quantity});
}

// Main Widget
class ProductsTable extends StatelessWidget {
  const ProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    final List<ProductEntitys> products = [
      ProductEntitys(
        name: "Cotton Shirt",
        description: "Premium cotton casual shirt for men.",
        imageUrl: "https://picsum.photos/id/237/300/200",
        sizes: [
          ProductSize(size: "M", quantity: 10),
          ProductSize(size: "L", quantity: 5),
        ],
      ),
      ProductEntitys(
        name: "Denim Jacket",
        description: "Trendy denim jacket perfect for winter.",
        imageUrl: "https://picsum.photos/id/238/300/200",
        sizes: [
          ProductSize(size: "S", quantity: 3),
          ProductSize(size: "XL", quantity: 2),
        ],
      ),
      ProductEntitys(
        name: "Sports Shoes",
        description: "Comfortable running shoes with grip sole.",
        imageUrl: "https://picsum.photos/id/239/300/200",
        sizes: [
          ProductSize(size: "8", quantity: 7),
          ProductSize(size: "9", quantity: 4),
        ],
      ),
    ];

    return Scaffold(
      // title: 'Product Table',
      body: isMobile
          ? ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductListItem(product: products[index]);
        },
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Sizes')),
            DataColumn(label: Text('Actions')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.name)),
                DataCell(Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )),
                DataCell(Text(product.sizes
                    .map((s) => s.size)
                    .join(', '))),
                DataCell(Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {}),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {}),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}


// Mobile Card View with Cached Image
class ProductListItem extends StatelessWidget {
  final ProductEntitys product;

  const ProductListItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Cached image with graceful loading
          CachedNetworkImage(
            imageUrl: product.imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.broken_image, size: 40)),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(product.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: product.sizes.map((size) {
                    return Chip(
                      label: Text('${size.size}: ${size.quantity}'),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
