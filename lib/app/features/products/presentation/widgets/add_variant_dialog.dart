// import 'package:firebase_admin/app/features/shared/data/model/product_model.dart';
// import 'package:flutter/material.dart';
// import '../../../../config/widgets/custom_drop_down.dart';
//
//
// class AddVariantDialog extends StatefulWidget {
//   // MODIFIED: The callback now includes a list of image URLs
//   final Function(String size, double price, int quantity, ProductColor color, List<String> imageUrls) onAdd;
//
//   const AddVariantDialog({super.key, required this.onAdd});
//
//   @override
//   State<AddVariantDialog> createState() => _AddVariantDialogState();
// }
//
// class _AddVariantDialogState extends State<AddVariantDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _priceController = TextEditingController();
//   final _quantityController = TextEditingController();
//   ProductColor _selectedColor = ProductColor.red;
//   String _selectedSize = 'S'; // Default size
//
//   // ADDED: List of controllers to manage multiple image URLs for the variant
//   final List<TextEditingController> _imageUrlControllers = [TextEditingController()];
//
//   @override
//   void dispose() {
//     _priceController.dispose();
//     _quantityController.dispose();
//     // ADDED: Dispose all image URL controllers
//     for (var controller in _imageUrlControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   void _addImageUrlField() {
//     setState(() {
//       _imageUrlControllers.add(TextEditingController());
//     });
//   }
//
//   void _removeImageUrlField(TextEditingController controller) {
//     setState(() {
//       _imageUrlControllers.remove(controller);
//       controller.dispose();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Add Variant'),
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               CustomDropdown<String>(
//                 value: _selectedSize,
//                 labelText: 'Size',
//                 items: const [
//                   DropdownMenuItem(value: 'S', child: Text('Small (S)')),
//                   DropdownMenuItem(value: 'M', child: Text('Medium (M)')),
//                   DropdownMenuItem(value: 'L', child: Text('Large (L)')),
//                   DropdownMenuItem(value: 'XL', child: Text('Extra Large (XL)')),
//                   DropdownMenuItem(value: 'XXL', child: Text('Double Extra Large (XXL)')),
//                 ],
//                 onChanged: (value) => setState(() => _selectedSize = value!),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _quantityController,
//                 decoration: const InputDecoration(labelText: 'Quantity'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//               ),
//               const SizedBox(height: 16),
//               CustomDropdown<ProductColor>(
//                 value: _selectedColor,
//                 labelText: 'Color',
//                 items: ProductColor.values.map((color) {
//                   return DropdownMenuItem(
//                     value: color,
//                     child: Text(color.toString().split('.').last),
//                   );
//                 }).toList(),
//                 onChanged: (value) => setState(() => _selectedColor = value!),
//               ),
//               const Divider(height: 32),
//               // --- ADDED: Image URL Management UI ---
//               const Text('Variant Image URLs', style: TextStyle(fontWeight: FontWeight.bold)),
//               ..._imageUrlControllers.map((controller) {
//                 return Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: controller,
//                           decoration: const InputDecoration(labelText: 'Image URL'),
//                           validator: (value) {
//                             if (_imageUrlControllers.first == controller && (value == null || value.isEmpty)) {
//                               return 'At least one URL is required';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       if (_imageUrlControllers.length > 1)
//                         IconButton(
//                           icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
//                           onPressed: () => _removeImageUrlField(controller),
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//               TextButton.icon(
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Another Image URL'),
//                 onPressed: _addImageUrlField,
//               ),
//             ],
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_formKey.currentState!.validate()) {
//               // MODIFIED: Collect image URLs from controllers
//               final imageUrls = _imageUrlControllers
//                   .map((c) => c.text.trim())
//                   .where((url) => url.isNotEmpty)
//                   .toList();
//
//               // MODIFIED: Pass the new list in the callback
//               widget.onAdd(
//                 _selectedSize,
//                 double.parse(_priceController.text),
//                 int.parse(_quantityController.text),
//                 _selectedColor,
//                 imageUrls,
//               );
//               Navigator.pop(context);
//             }
//           },
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../config/widgets/custom_drop_down.dart';
import '../../../image_gallery/presentation/widgets/image_selection_dialog.dart';
import '../../../shared/data/model/product_model.dart';

class AddVariantDialog extends StatefulWidget {
  // The callback now expects the color enum, not the string name.
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
  String _selectedSize = 'S';

  // This list of controllers remains the core of our manual entry system.
  final List<TextEditingController> _imageUrlControllers = [TextEditingController()];

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
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

  void _removeImageUrlField(int index) {
    setState(() {
      // Dispose the controller before removing it to prevent memory leaks.
      _imageUrlControllers[index].dispose();
      _imageUrlControllers.removeAt(index);
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
              // --- Standard Variant Fields (Unchanged) ---
              CustomDropdown<String>(
                labelText: 'Size', value: _selectedSize,
                items: ['S', 'M', 'L', 'XL', 'XXL'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => setState(() => _selectedSize = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _quantityController, decoration: const InputDecoration(labelText: 'Stock Quantity'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              CustomDropdown<ProductColor>(
                labelText: 'Color', value: _selectedColor,
                items: ProductColor.values.map((c) => DropdownMenuItem(value: c, child: Text(describeEnum(c).toUpperCase()))).toList(),
                onChanged: (value) => setState(() => _selectedColor = value!),
              ),
              const Divider(height: 32, thickness: 1),

              // --- ENHANCED IMAGE URL UI ---
              const Text('Variant Image URLs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // This button opens the gallery selection dialog
              OutlinedButton.icon(
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Select from Gallery'),
                onPressed: () async {
                  // Get the current URLs from the text fields
                  final currentUrls = _imageUrlControllers.map((c) => c.text.trim()).where((url) => url.isNotEmpty).toList();

                  final List<String>? result = await showDialog<List<String>>(
                    context: context,
                    builder: (_) => ImageSelectionDialog(preselectedUrls: currentUrls),
                  );

                  if (result != null) {
                    setState(() {
                      // Dispose old controllers
                      for (var controller in _imageUrlControllers) {
                        controller.dispose();
                      }
                      _imageUrlControllers.clear();
                      // Create new controllers populated with the selected URLs
                      for (var url in result) {
                        _imageUrlControllers.add(TextEditingController(text: url));
                      }
                      // Ensure there's at least one empty field if the result was empty
                      if (_imageUrlControllers.isEmpty) {
                        _imageUrlControllers.add(TextEditingController());
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              const Text('OR add manually below:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),

              // The list of manual entry fields
              ..._imageUrlControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(labelText: 'Image URL'),
                          validator: (value) {
                            if (index == 0 && (value == null || value.isEmpty)) {
                              return 'At least one URL is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_imageUrlControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeImageUrlField(index),
                        ),
                    ],
                  ),
                );
              }).toList(),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Another URL Field'),
                onPressed: _addImageUrlField,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final imageUrls = _imageUrlControllers
                  .map((c) => c.text.trim())
                  .where((url) => url.isNotEmpty)
                  .toList();

              if (imageUrls.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add or select at least one image URL.')));
                return;
              }

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
          child: const Text('Add Variant'),
        ),
      ],
    );
  }
}