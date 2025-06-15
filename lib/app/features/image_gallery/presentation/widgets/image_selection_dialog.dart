import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/image_gallery_providers.dart';

class ImageSelectionDialog extends ConsumerStatefulWidget {
  final List<String> preselectedUrls;
  const ImageSelectionDialog({super.key, required this.preselectedUrls});

  @override
  ConsumerState<ImageSelectionDialog> createState() => _ImageSelectionDialogState();
}

class _ImageSelectionDialogState extends ConsumerState<ImageSelectionDialog> {
  late Set<String> _selectedUrls;

  @override
  void initState() {
    super.initState();
    _selectedUrls = Set.from(widget.preselectedUrls);
  }

  @override
  Widget build(BuildContext context) {
    final galleryImagesAsync = ref.watch(galleryImagesStreamProvider);

    return AlertDialog(
      title: const Text('Select Variant Images'),
      content: SizedBox(
        width: double.maxFinite,
        child: galleryImagesAsync.when(
          data: (images) {
            if (images.isEmpty) return const Center(child: Text('No images in gallery.'));
            return GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                final isSelected = _selectedUrls.contains(image.url);
                return GestureDetector(
                  onTap: () => setState(() => isSelected ? _selectedUrls.remove(image.url) : _selectedUrls.add(image.url)),
                  child: GridTile(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: image.url, fit: BoxFit.cover),
                        if (isSelected)
                          Container(
                            color: Colors.black.withOpacity(0.6),
                            child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedUrls.toList()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}