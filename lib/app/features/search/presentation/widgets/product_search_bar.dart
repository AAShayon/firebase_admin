import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/search/presentation/providers/search_notifier_provider.dart';
import 'package:firebase_admin/app/features/search/presentation/providers/search_state.dart'; // Import the state file

class ProductSearchBar extends ConsumerStatefulWidget {
  const ProductSearchBar({super.key});

  @override
  ConsumerState<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends ConsumerState<ProductSearchBar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // This listener just handles the visibility of the clear button.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the provider to sync the text field controller with the state.
    ref.listen<SearchState>(searchNotifierProvider, (_, state) {
      // Use maybeMap to safely handle different states.
      state.maybeMap(
        // If the state is initial AND the controller isn't already empty...
        initial: (_) {
          if (_controller.text.isNotEmpty) {
            _controller.clear();
          }
        },
        // If the state is loaded AND its query differs from the controller...
        loaded: (loadedState) {
          if (_controller.text != loadedState.query) {
            _controller.text = loadedState.query;
            // Move cursor to the end after setting text
            _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
          }
        },
        // Do nothing for other states (loading, error)
        orElse: () {},
      );
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _controller,
        onChanged: (query) {
          ref.read(searchNotifierProvider.notifier).searchProducts(query);
        },
        decoration: InputDecoration(
          hintText: 'Search products by name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Always delegate state changes to the notifier.
              // The listener above will handle clearing the controller.
              ref.read(searchNotifierProvider.notifier).clearSearch();
            },
          )
              : null,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}