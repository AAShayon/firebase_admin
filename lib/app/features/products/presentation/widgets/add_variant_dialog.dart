import 'package:flutter/material.dart';
import '../../../../config/widgets/custom_drop_down.dart';
import '../../data/model/product_model.dart';

class AddVariantDialog extends StatefulWidget {
  final Function(String size, double price, int quantity, ProductColor color) onAdd;

  const AddVariantDialog({super.key, required this.onAdd});

  @override
  State<AddVariantDialog> createState() => _AddVariantDialogState();
}

class _AddVariantDialogState extends State<AddVariantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  ProductColor _selectedColor = ProductColor.red;
  String _selectedSize = 'S'; // Default size

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Variant'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomDropdown<String>(
                value: _selectedSize,
                labelText: 'Size',
                items: const [
                  DropdownMenuItem(value: 'S', child: Text('Small (S)')),
                  DropdownMenuItem(value: 'M', child: Text('Medium (M)')),
                  DropdownMenuItem(value: 'L', child: Text('Large (L)')),
                  DropdownMenuItem(value: 'XL', child: Text('Extra Large (XL)')),
                  DropdownMenuItem(value: 'XXL', child: Text('Double Extra Large (XXL)')),
                ],
                onChanged: (value) => setState(() => _selectedSize = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomDropdown<ProductColor>(
                value: _selectedColor,
                labelText: 'Color',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(
                _selectedSize,
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