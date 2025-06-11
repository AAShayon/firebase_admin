import 'package:flutter/material.dart';
import '../../../../config/widgets/custom_drop_down.dart';
import '../../data/model/product_model.dart';

class AddVariantDialog extends StatefulWidget {
  // MODIFIED: The callback now includes a list of image URLs
  final Function(String size, double price, int quantity, ProductColor color, List<String> imageUrls) onAdd;

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

  // ADDED: List of controllers to manage multiple image URLs for the variant
  final List<TextEditingController> _imageUrlControllers = [TextEditingController()];

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    // ADDED: Dispose all image URL controllers
    for (var controller in _imageUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addImageUrlField() {
    setState(() {
      _imageUrlControllers.add(TextEditingController());
    });
  }

  void _removeImageUrlField(TextEditingController controller) {
    setState(() {
      _imageUrlControllers.remove(controller);
      controller.dispose();
    });
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const Divider(height: 32),
              // --- ADDED: Image URL Management UI ---
              const Text('Variant Image URLs', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._imageUrlControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(labelText: 'Image URL'),
                          validator: (value) {
                            if (_imageUrlControllers.first == controller && (value == null || value.isEmpty)) {
                              return 'At least one URL is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_imageUrlControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeImageUrlField(controller),
                        ),
                    ],
                  ),
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Another Image URL'),
                onPressed: _addImageUrlField,
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
              // MODIFIED: Collect image URLs from controllers
              final imageUrls = _imageUrlControllers
                  .map((c) => c.text.trim())
                  .where((url) => url.isNotEmpty)
                  .toList();

              // MODIFIED: Pass the new list in the callback
              widget.onAdd(
                _selectedSize,
                double.parse(_priceController.text),
                int.parse(_quantityController.text),
                _selectedColor,
                imageUrls,
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