import 'package:firebase_admin/app/features/image_gallery/domain/repositories/image_gallery_repository.dart';

class AddImageUrlUseCase {
  final ImageGalleryRepository repository;
  AddImageUrlUseCase(this.repository);

  Future<void> call({required String url, String? name}) {
    return repository.addImageUrl(url: url, name: name);
  }
}