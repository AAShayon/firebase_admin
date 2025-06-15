import 'package:firebase_admin/app/features/image_gallery/domain/repositories/image_gallery_repository.dart';

class DeleteImageUrlUseCase {
  final ImageGalleryRepository repository;
  DeleteImageUrlUseCase(this.repository);

  Future<void> call(String imageId) {
    return repository.deleteImageUrl(imageId);
  }
}
