import 'package:firebase_admin/app/features/products/presentation/providers/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';
import 'package:firebase_admin/app/features/products/presentation/widgets/product_form.dart';
import 'package:firebase_admin/app/features/products/presentation/widgets/add_variant_dialog.dart';
import '../../../shared/data/model/product_model.dart';
import '../../../shared/domain/entities/product_entity.dart';


class AddProductPage extends ConsumerStatefulWidget {
  final ProductEntity? productToEdit;

  const AddProductPage({super.key, this.productToEdit});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  List<ProductVariantEntity> _variants = [];
  ProductCategory _selectedCategory = ProductCategory.shirt;
  bool _availability = true;
  bool _isLoading = false;

  bool get _isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    if (_isEditMode) {
      final product = widget.productToEdit!;
      _titleController.text = product.title;
      _descriptionController.text = product.description;
      _variants = List<ProductVariantEntity>.from(product.variants);
      _selectedCategory = product.category;
      _availability = product.availability;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one variant')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final product = ProductEntity(
      id: _isEditMode ? widget.productToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      variants: _variants,
      availability: _availability,
      category: _selectedCategory,
      createdAt: _isEditMode ? widget.productToEdit!.createdAt : DateTime.now(),
    );

    try {
      if (_isEditMode) {
        await ref.read(productNotifierProvider.notifier).updateProduct(product);
      } else {
        await ref.read(productNotifierProvider.notifier).addProduct(product);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductState>(productNotifierProvider, (previous, next) {
      next.whenOrNull(
        added: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
          if (context.canPop()) context.pop();
        },
        updated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          if (context.canPop()) context.pop();
        },
        error: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Product' : 'Add Product'),
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
                variants: _variants,
                selectedCategory: _selectedCategory,
                availability: _availability,
                onCategoryChanged: (category) => setState(() => _selectedCategory = category!),
                onAvailabilityChanged: (value) => setState(() => _availability = value!),
                onAddVariant: () => showDialog(
                  context: context,
                  builder: (context) => AddVariantDialog(

                    onAdd: (size, price, quantity, color, imageUrls) {
                      setState(() {
                        _variants.add(ProductVariantEntity(
                          size: size,
                          price: price,
                          quantity: quantity,
                          color: color,
                          imageUrls: imageUrls, // Pass the URLs from the dialog
                        ));
                      });
                    },
                  ),
                ),
                onRemoveVariant: (variant) => setState(() => _variants.remove(variant)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isEditMode ? 'Update Product' : 'Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}