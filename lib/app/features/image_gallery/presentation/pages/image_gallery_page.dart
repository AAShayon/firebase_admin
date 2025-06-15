import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/image_gallery_notifier_provider.dart';
import '../providers/image_gallery_providers.dart';

class ImageGalleryPage extends ConsumerWidget {
  const ImageGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryImagesAsync = ref.watch(galleryImagesStreamProvider);
    final notifier = ref.read(imageGalleryNotifierProvider.notifier);

    void showAddImageDialog() {
      final urlController = TextEditingController();
      final nameController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Image URL to Gallery'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: urlController, decoration: const InputDecoration(labelText: 'Image URL')),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Image Name (Optional)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  notifier.addImageUrl(url: urlController.text, name: nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
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
          ),
        ],
      ),
      body: galleryImagesAsync.when(
        data: (images) {
          if (images.isEmpty) return const Center(child: Text('No images in gallery.'));
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
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => notifier.deleteImageUrl("$image"),
                  ),
                ),
                child: CachedNetworkImage(imageUrl: image.url, fit: BoxFit.cover),
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