import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/gallery_image_entity.dart';
import '../../domain/usecase/add_image_url_use_case.dart';
import '../../domain/usecase/delete_image_use_case.dart';
import '../../domain/usecase/fetch_api_images_use_case.dart';
import '../../domain/usecase/get_gallery_images_use_case.dart';


// Use Case Providers
final getGalleryImagesUseCaseProvider = Provider<GetGalleryImagesUseCase>((ref) => locator<GetGalleryImagesUseCase>());
final addImageUrlUseCaseProvider = Provider<AddImageUrlUseCase>((ref) => locator<AddImageUrlUseCase>());
final deleteImageUrlUseCaseProvider = Provider<DeleteImageUrlUseCase>((ref) => locator<DeleteImageUrlUseCase>());

// Stream Provider to get the images for the UI
final galleryImagesStreamProvider = StreamProvider.autoDispose<List<GalleryImageEntity>>((ref) {
  return ref.watch(getGalleryImagesUseCaseProvider)();
});
final fetchApiImagesUseCaseProvider = Provider<FetchApiImagesUseCase>((ref) {
  return locator<FetchApiImagesUseCase>();
});
