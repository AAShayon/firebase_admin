import '../entities/gallery_image_entity.dart';
import '../repositories/image_gallery_repository.dart';

class GetGalleryImagesUseCase {
  final ImageGalleryRepository repository;
  GetGalleryImagesUseCase(this.repository);

  Stream<List<GalleryImageEntity>> call() {
    return repository.getGalleryImages();
  }
}