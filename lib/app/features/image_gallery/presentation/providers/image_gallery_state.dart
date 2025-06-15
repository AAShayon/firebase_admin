import 'package:freezed_annotation/freezed_annotation.dart';
part 'image_gallery_state.freezed.dart';

@freezed
class ImageGalleryState with _$ImageGalleryState {
  const factory ImageGalleryState.initial() = _Initial;
  const factory ImageGalleryState.loading() = _Loading;
  const factory ImageGalleryState.success(String message) = _Success;
  const factory ImageGalleryState.error(String message) = _Error;
}