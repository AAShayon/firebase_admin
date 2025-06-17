import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../image_gallery/presentation/widgets/image_selection_dialog.dart';

class PromotionDetailsForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedImageUrl;
  final ValueChanged<String> onImageSelected;

  const PromotionDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedImageUrl,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Promotion Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title / Headline *'),
              validator: (value) => (value == null || value.isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description *'),
              maxLines: 3,
              validator: (value) => (value == null || value.isEmpty) ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Banner Image', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: selectedImageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: selectedImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => const Icon(Icons.error),
                ),
              )
                  : const Center(child: Text('No Image Selected')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: const Text('Select Banner Image'),
              onPressed: () async {
                final List<String>? result = await showDialog<List<String>>(
                  context: context,
                  // We only allow selecting ONE image for the banner.
                  builder: (_) => const ImageSelectionDialog(preselectedUrls: [], allowMultiSelect: false),
                );
                // The dialog will now return a list with 0 or 1 item.
                if (result != null && result.isNotEmpty) {
                  onImageSelected(result.first);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}