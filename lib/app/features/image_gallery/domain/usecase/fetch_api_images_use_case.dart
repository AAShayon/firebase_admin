import '../entities/gallery_image_entity.dart';
import '../repositories/image_gallery_repository.dart';

// This use case is responsible for fetching a list of images from the external API.
class FetchApiImagesUseCase {
  final ImageGalleryRepository repository;
  FetchApiImagesUseCase(this.repository);

  // It will return a list of entities, but these are not yet saved to our gallery.
  Future<List<GalleryImageEntity>> call({int page = 1, int limit = 30}) {
    return repository.fetchApiImages(page: page, limit: limit);
  }
}