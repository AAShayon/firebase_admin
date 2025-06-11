import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_providers.dart';
import 'search_state.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;
  Timer? _debounce;

  SearchNotifier(this.ref) : super(const SearchState.initial()) {
    // When the provider is disposed (e.g., by autoDispose), cancel the timer.
    ref.onDispose(() {
      _debounce?.cancel();
    });
  }

  Future<void> searchProducts(String query) async {
    // If there's an active timer, cancel it so we can restart the countdown.
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // If the query is empty, clear results and don't start a new timer.
    if (query.isEmpty) {
      // state = const SearchState.initial();
      // return;
      clearSearch();
      return;
    }

    // Start a new timer. The search will only run after 500ms of inactivity.
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      state = const SearchState.loading();
      try {
        final usecase = ref.read(searchProductUseCaseProvider);
        final products = await usecase.call(query);
        // Ensure the notifier hasn't been disposed before updating the state.
        if (mounted) {
          state = SearchState.loaded(query: query, products: products);

        }
      } catch (e) {
        if (mounted) {
          state = SearchState.error(e.toString());
        }
      }
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    state = const SearchState.initial();
  }
}