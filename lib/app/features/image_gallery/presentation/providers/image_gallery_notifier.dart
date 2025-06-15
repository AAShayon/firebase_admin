import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_gallery_providers.dart';
import 'image_gallery_state.dart';

class ImageGalleryNotifier extends StateNotifier<ImageGalleryState> {
  final Ref _ref;
  ImageGalleryNotifier(this._ref) : super(const ImageGalleryState.initial());

  Future<void> addImageUrl({required String url, String? name}) async {
    state = const ImageGalleryState.loading();
    try {
      await _ref.read(addImageUrlUseCaseProvider).call(url: url, name: name);
      state = const ImageGalleryState.success('Image URL added successfully!');
    } catch (e) {
      state = ImageGalleryState.error(e.toString());
    }
  }

  Future<void> deleteImageUrl(String imageId) async {
    state = const ImageGalleryState.loading();
    try {
      await _ref.read(deleteImageUrlUseCaseProvider).call(imageId);
      state = const ImageGalleryState.success('Image URL deleted.');
    } catch (e) {
      state = ImageGalleryState.error(e.toString());
    }
  }
}