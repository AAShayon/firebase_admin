import '../../domain/entities/gallery_image_entity.dart';
import '../../domain/repositories/image_gallery_repository.dart';
import '../datasources/image_gallery_remote_data_source.dart';
import '../models/gallery_image_model.dart';

class ImageGalleryRepositoryImpl implements ImageGalleryRepository {
  final ImageGalleryRemoteDataSource remoteDataSource;
  ImageGalleryRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<GalleryImageEntity>> getGalleryImages() {
    return remoteDataSource.getGalleryImages().map((snapshot) {
      return snapshot.docs.map((doc) => GalleryImageModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> addImageUrl({required String url, String? name}) {
    return remoteDataSource.addImageUrl(url: url, name: name);
  }

  @override
  Future<void> deleteImageUrl(String imageId) {
    return remoteDataSource.deleteImageUrl(imageId);
  }
}