import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/gallery_image_entity.dart';

part 'api_images_state.freezed.dart';

@freezed
class ApiImagesState with _$ApiImagesState {
  const factory ApiImagesState({
    @Default([]) List<GalleryImageEntity> images,
    @Default(1) int page,
    @Default(true) bool hasMore, // Assume there's more to load initially
    @Default(false) bool isLoading,
  }) = _ApiImagesState;
}