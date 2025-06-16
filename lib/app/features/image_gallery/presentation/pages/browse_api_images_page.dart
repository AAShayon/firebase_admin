import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/gallery_image_entity.dart';
import '../providers/image_gallery_notifier_provider.dart';

class BrowseApiImagesPage extends ConsumerStatefulWidget {
  const BrowseApiImagesPage({super.key});

  @override
  ConsumerState<BrowseApiImagesPage> createState() => _BrowseApiImagesPageState();
}

class _BrowseApiImagesPageState extends ConsumerState<BrowseApiImagesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      ref.read(apiImagesNotifierProvider.notifier).fetchNextPage();
    }
  }

  // --- THIS IS THE CORRECTED DIALOG METHOD ---
  void _showSaveConfirmationDialog(BuildContext context, WidgetRef ref, GalleryImageEntity image) {
    final nameController = TextEditingController(text: image.name);
    final formKey = GlobalKey<FormState>();
    final notifier = ref.read(imageGalleryNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add to My Gallery'),
        // We wrap the content in a SizedBox to give it constraints.
        content: SizedBox(
          // A common practice is to make it a fraction of the screen width.
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            key: formKey,
            child: SingleChildScrollView( // The scroll view is now safe inside a constrained parent.
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important for the column to not take infinite height
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: image.url,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Image Name',
                      hintText: 'e.g., "Red T-Shirt Model"',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a name for the image.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                await notifier.addImageUrl(
                  url: image.url,
                  name: nameController.text.trim(),
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
            },
            child: const Text('Save to Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiImagesState = ref.watch(apiImagesNotifierProvider);
    final notifier = ref.read(apiImagesNotifierProvider.notifier);
    final images = apiImagesState.images;

    ref.listen(imageGalleryNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 2), backgroundColor: Colors.green),
        ),
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $message"), duration: const Duration(seconds: 2), backgroundColor: Colors.red),
        ),
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse & Add Images'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => notifier.refresh(),
        child: Column(
          children: [
            if (images.isEmpty && !apiImagesState.isLoading)
              const Expanded(
                child: Center(child: Text("No images found. Pull to refresh.")),
              ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text("${image.name}", overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        tooltip: 'Add to My Gallery',
                        onPressed: () => _showSaveConfirmationDialog(context, ref, image),
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image.url,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey.shade200),
                      errorWidget: (c, u, e) => const Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            if (apiImagesState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!apiImagesState.isLoading && !apiImagesState.hasMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text("You've reached the end!")),
              ),
          ],
        ),
      ),
    );
  }
}