

import '../entities/gallery_image_entity.dart';

abstract class ImageGalleryRepository {
  Stream<List<GalleryImageEntity>> getGalleryImages();
  Future<void> addImageUrl({required String url, String? name});
  Future<void> deleteImageUrl(String imageId);
}