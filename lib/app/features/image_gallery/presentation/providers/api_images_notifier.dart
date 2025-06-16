import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_images_state.dart';
import 'image_gallery_providers.dart';

class ApiImagesNotifier extends StateNotifier<ApiImagesState> {
  final Ref _ref;
  ApiImagesNotifier(this._ref) : super(const ApiImagesState()) {
    // Fetch the first page when the notifier is created
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    // Prevent multiple simultaneous fetches
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final useCase = _ref.read(fetchApiImagesUseCaseProvider);
      // Fetch images for the current page
      final newImages = await useCase(page: state.page);

      // If the API returns fewer images than we requested, it's the last page.
      if (newImages.length < 30) { // Assuming a limit of 30 per page
        state = state.copyWith(hasMore: false);
      }

      // Add the new images to the existing list and increment the page number
      state = state.copyWith(
        images: [...state.images, ...newImages],
        page: state.page + 1,
        isLoading: false,
      );
    } catch (e) {
      // Handle error, maybe set an error state
      print("Failed to fetch next page of images: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  void refresh() {
    // Reset the state and fetch the first page again
    state = const ApiImagesState();
    fetchNextPage();
  }
}