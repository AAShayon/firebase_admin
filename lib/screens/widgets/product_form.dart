import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product.dart';
import '../../services/firebase_services.dart';

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final FirebaseService _service = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  late String title, description, size;
  late double price;
  late int quantity;
  late bool availability;
  late ProductCategory category;
  File? _image;
  String? imageLink;

  final picker = ImagePicker();

  final List<String> predefinedSizes = ['S', 'M', 'L', 'XL', 'XXL', 'Custom'];

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    category = ProductCategory.ecom;
    availability = true;
    size = predefinedSizes[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? "Enter title" : null,
                  onSaved: (val) => title = val!,
                ),
                SizedBox(height: 16),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => description = val!,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Price",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                        val!.isEmpty ? "Enter price" : null,
                        onSaved: (val) => price = double.parse(val!),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Quantity",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                        val!.isEmpty ? "Enter quantity" : null,
                        onSaved: (val) => quantity = int.parse(val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: size,
                  items: predefinedSizes.map((s) {
                    return DropdownMenuItem<String>(
                      value: s,
                      child: Text(s),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      size = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Size",
                    border: OutlineInputBorder(),
                  ),
                ),
                if (size == 'Custom')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextFormField(
                      initialValue: '',
                      decoration: InputDecoration(
                        labelText: "Custom Size",
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (val) => size = val!,
                    ),
                  ),
                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Available"),
                  value: availability,
                  onChanged: (val) {
                    setState(() => availability = val);
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<ProductCategory>(
                  value: category,
                  items: ProductCategory.values.map((category) {
                    return DropdownMenuItem<ProductCategory>(
                      value: category,
                      child: Text(describeEnum(category).toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      category = val!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Image Link (optional)",
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => imageLink = val,
                ),
                SizedBox(height: 8),
                Text("OR", textAlign: TextAlign.center),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _getImage,
                  icon: Icon(Icons.image),
                  label: Text("Upload Image from Gallery"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _image!,
                        height: 150,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final product = Product(
                        id: DateTime.now().toString(),
                        title: title,
                        description: description,
                        price: price,
                        quantity: quantity,
                        size: size,
                        availability: availability,
                        imageUrl: null,
                        imageLink: imageLink,
                        category: category,
                      );
                      _service.addProduct(product, _image);
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text("Save Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}