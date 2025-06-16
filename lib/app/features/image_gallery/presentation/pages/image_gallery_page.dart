import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/image_gallery_notifier_provider.dart';
import '../providers/image_gallery_providers.dart';
import '../providers/image_gallery_state.dart'; // Import the state file

class ImageGalleryPage extends ConsumerWidget {
  const ImageGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryImagesAsync = ref.watch(galleryImagesStreamProvider);

    // Set up a listener for success/error snackbars
    ref.listen<ImageGalleryState>(imageGalleryNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        ),
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
        ),
        orElse: () {},
      );
    });

    void showAddImageDialog() {
      final urlController = TextEditingController();
      final nameController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add Image URL to Gallery'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Image URL', hintText: 'https://...'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'URL cannot be empty.';
                    if (Uri.tryParse(value)?.hasAbsolutePath != true) return 'Please enter a valid URL.';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Image Name (Optional)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),

            // --- THIS IS THE CORRECTED LOGIC ---
            FilledButton(
              onPressed: () async { // Make the callback async
                if (formKey.currentState?.validate() ?? false) {
                  // 1. Read the notifier BEFORE popping the dialog.
                  final notifier = ref.read(imageGalleryNotifierProvider.notifier);

                  // 2. Perform the async operation.
                  await notifier.addImageUrl(
                    url: urlController.text.trim(),
                    name: nameController.text.trim(),
                  );

                  // 3. Only pop the dialog AFTER the operation is complete.
                  //    Check if the dialog's context is still valid.
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }

    // Also, let's fix the onDelete call. It needs the image ID, not the whole object.
    void showDeleteConfirmation(String imageId) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete Image?'),
          content: const Text('Are you sure you want to delete this image URL from the gallery?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref.read(imageGalleryNotifierProvider.notifier).deleteImageUrl(imageId);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            )
          ],
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: showAddImageDialog,
            tooltip: 'Add Image URL',
          ),
        ],
      ),
      body: galleryImagesAsync.when(
        data: (images) {
          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your gallery is empty.'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: showAddImageDialog, child: const Text('Add your first image URL'))
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black45,
                  title: Text(image.name ?? 'Untitled', overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                    onPressed: () => showDeleteConfirmation(image.id), // <-- Corrected this call
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: image.url,
                  fit: BoxFit.cover,
                  placeholder: (c,u) => Container(color: Colors.grey.shade200),
                  errorWidget: (c,u,e) => const Icon(Icons.error),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}