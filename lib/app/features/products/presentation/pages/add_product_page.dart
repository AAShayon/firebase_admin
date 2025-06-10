import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_admin/app/features/products/domain/entities/product_entity.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';
import 'package:firebase_admin/app/features/products/presentation/widgets/product_form.dart';
import 'package:firebase_admin/app/features/products/presentation/widgets/add_variant_dialog.dart';

import '../../data/model/product_model.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageLinkController = TextEditingController();
  final List<ProductVariantEntity> _variants = [];
  ProductCategory _selectedCategory = ProductCategory.shirt;
  bool _availability = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageLinkController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // 1. Get navigation references BEFORE async operations
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 2. Validate synchronously first
    if (!_formKey.currentState!.validate()) return;
    if (_variants.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please add at least one variant')),
      );
      return;
    }

    // 3. Create product
    final product = ProductEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      variants: _variants,
      availability: _availability,
      imageUrl: null,
      imageLink: _imageLinkController.text,
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    try {
      // 4. Perform async operation
      await ref.read(productNotifierProvider.notifier).addProduct(product);

      // 5. Handle success - no mounted check needed because:
      //    - We're using local Navigator reference
      //    - We'll handle errors properly
      messenger.showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      navigator.pop();

    } catch (e) {
      // 6. Handle errors safely
      messenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProductForm(
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
                imageLinkController: _imageLinkController,
                variants: _variants,
                selectedCategory: _selectedCategory,
                availability: _availability,
                onCategoryChanged: (category) => setState(() => _selectedCategory = category),
                onAvailabilityChanged: (value) => setState(() => _availability = value),
                onAddVariant: () => showDialog(
                  context: context,
                  builder: (context) => AddVariantDialog(
                    onAdd: (size, price, quantity, color) {
                      setState(() {
                        _variants.add(ProductVariantEntity(
                          size: size,
                          price: price,
                          quantity: quantity,
                          color: color,
                        ));
                      });
                    },
                  ),
                ),
                onRemoveVariant: (variant) => setState(() => _variants.remove(variant)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}