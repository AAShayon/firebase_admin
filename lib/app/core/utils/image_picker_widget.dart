import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? image;
  final Function(File) onImagePicked;

  const ImagePickerWidget({
    super.key,
    required this.image,
    required this.onImagePicked,
  });

  Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(context),
          child: const Text('Upload Product Image'),
        ),
        if (image != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(image!, height: 150, fit: BoxFit.cover),
          ),
        ],
      ],
    );
  }
}