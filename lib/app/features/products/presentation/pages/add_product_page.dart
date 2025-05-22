import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/widgets/responsive_scaffold.dart';
import '../../data/model/product_model.dart';
import '../../domain/entities/product_entity.dart';

import '../providers/product_notifier_provider.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<ProductVariantEntity> _variants = [];
  File? _image;
  ProductCategory _selectedCategory = ProductCategory.shirt;
  bool _availability = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addVariant() {
    showDialog(
      context: context,
      builder: (context) => _AddVariantDialog(
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
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _variants.isNotEmpty) {
      final product = ProductEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        variants: _variants,
        availability: _availability,
        imageUrl: _image != null ? _image!.path : null,
        imageLink: null,
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );

      await ref.read(productNotifierProvider.notifier).addProduct(product);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Add Product',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Product Title'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ProductCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available'),
                value: _availability,
                onChanged: (value) => setState(() => _availability = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Product Image'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 16),
                Image.file(_image!, height: 150, fit: BoxFit.cover),
              ],
              const SizedBox(height: 24),
              const Text('Product Variants', style: TextStyle(fontSize: 18)),
              ..._variants.map((variant) => ListTile(
                title: Text('Size: ${variant.size}'),
                subtitle: Text(
                  'Color: ${variant.color.toString().split('.').last}\n'
                      'Price: \$${variant.price.toStringAsFixed(2)}\n'
                      'Quantity: ${variant.quantity}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => _variants.remove(variant)),
                ),
              )).toList(),
              ElevatedButton(
                onPressed: _addVariant,
                child: const Text('Add Variant'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

class _AddVariantDialog extends StatefulWidget {
  final Function(String size, double price, int quantity, ProductColor color) onAdd;

  const _AddVariantDialog({required this.onAdd});

  @override
  State<_AddVariantDialog> createState() => __AddVariantDialogState();
}

class __AddVariantDialogState extends State<_AddVariantDialog> {
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  ProductColor _selectedColor = ProductColor.red;

  @override
  void dispose() {
    _sizeController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Variant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(labelText: 'Size (e.g., S, M, L)'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            DropdownButtonFormField<ProductColor>(
              value: _selectedColor,
              decoration: const InputDecoration(labelText: 'Color'),
              items: ProductColor.values.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedColor = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_sizeController.text.isNotEmpty &&
                _priceController.text.isNotEmpty &&
                _quantityController.text.isNotEmpty) {
              widget.onAdd(
                _sizeController.text,
                double.parse(_priceController.text),
                int.parse(_quantityController.text),
                _selectedColor,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}