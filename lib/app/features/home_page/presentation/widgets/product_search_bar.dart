import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/search/presentation/providers/search_notifier_provider.dart';

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
    // Rebuilds the widget to show/hide the clear button when text changes.
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This ensures the text field is cleared if the search state is reset from elsewhere.
    ref.listen(searchNotifierProvider, (_, state) {
      if (state.maybeWhen(initial: () => true, orElse: () => false)) {
        if (_controller.text.isNotEmpty) {
          _controller.clear();
        }
      }
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
              // Clearing the controller will trigger onChanged with an empty string,
              // which in turn resets the search state in the notifier.
              _controller.clear();
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