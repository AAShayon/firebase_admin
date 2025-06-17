import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/image_gallery_providers.dart';

class ImageSelectionDialog extends ConsumerStatefulWidget {
  final List<String> preselectedUrls;
  final bool allowMultiSelect; // Determines if user can select one or many images

  const ImageSelectionDialog({
    super.key,
    required this.preselectedUrls,
    this.allowMultiSelect = true, // Defaults to allowing multiple selections
  });

  @override
  ConsumerState<ImageSelectionDialog> createState() => _ImageSelectionDialogState();
}

class _ImageSelectionDialogState extends ConsumerState<ImageSelectionDialog> {
  // Use a Set for efficient add/remove/contains operations
  late Set<String> _selectedUrls;

  @override
  void initState() {
    super.initState();
    // Initialize the selection with the URLs passed from the parent widget
    _selectedUrls = Set.from(widget.preselectedUrls);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get the list of all available gallery images
    final galleryImagesAsync = ref.watch(galleryImagesStreamProvider);

    return AlertDialog(
      title: Text(widget.allowMultiSelect ? 'Select Images' : 'Select an Image'),
      // Use a SizedBox to give the dialog a constrained size, preventing layout errors.
      content: SizedBox(
        width: double.maxFinite, // Take up available width
        child: galleryImagesAsync.when(
          data: (images) {
            if (images.isEmpty) {
              return const Center(child: Text('No images found in your gallery.'));
            }
            // Display the images in a responsive grid
            return GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                final isSelected = _selectedUrls.contains(image.url);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // --- THIS IS THE KEY LOGIC ---
                      if (widget.allowMultiSelect) {
                        // If multi-select is allowed, just toggle the item in the set.
                        if (isSelected) {
                          _selectedUrls.remove(image.url);
                        } else {
                          _selectedUrls.add(image.url);
                        }
                      } else {
                        // If single-select, clear the set and add only the new item.
                        _selectedUrls.clear();
                        _selectedUrls.add(image.url);
                      }
                    });
                  },
                  child: GridTile(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: image.url,
                            fit: BoxFit.cover,
                            placeholder: (c,u) => Container(color: Colors.grey.shade200),
                            errorWidget: (c,u,e) => const Icon(Icons.error_outline),
                          ),
                        ),
                        // Show a checkmark overlay if the image is selected
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                            ),
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Pop without a value on cancel
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            // Pop with the final list of selected URLs
            Navigator.of(context).pop(_selectedUrls.toList());
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}