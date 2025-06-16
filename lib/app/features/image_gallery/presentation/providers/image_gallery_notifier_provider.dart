import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_images_notifier.dart';
import 'api_images_state.dart';
import 'image_gallery_notifier.dart';
import 'image_gallery_state.dart';

final imageGalleryNotifierProvider =
StateNotifierProvider.autoDispose<ImageGalleryNotifier, ImageGalleryState>((ref) {
  return ImageGalleryNotifier(ref);
});

final apiImagesNotifierProvider =
StateNotifierProvider.autoDispose<ApiImagesNotifier, ApiImagesState>((ref) {
  return ApiImagesNotifier(ref);
});