import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'image_gallery_notifier.dart';
import 'image_gallery_state.dart';

final imageGalleryNotifierProvider =
StateNotifierProvider.autoDispose<ImageGalleryNotifier, ImageGalleryState>((ref) {
  return ImageGalleryNotifier(ref);
});