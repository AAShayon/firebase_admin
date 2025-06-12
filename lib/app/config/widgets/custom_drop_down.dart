import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value; // MODIFIED: Allow null values
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final String? hintText; // ADDED: For better UX
  final String? Function(T?)? validator; // ADDED: For form validation
  final EdgeInsetsGeometry? padding;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    this.value, // MODIFIED: Not required anymore
    required this.items,
    required this.onChanged,
    required this.labelText,
    this.hintText, // ADDED
    this.validator, // ADDED
    this.padding,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        // The validator is passed directly to the underlying FormField
        validator: validator, // ADDED
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText, // ADDED
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Using a slightly larger radius for style
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0),
          filled: true,
          // Using a more standard fill color from your other widget for consistency
          fillColor: Colors.grey.shade100,
        ),
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: Theme.of(context).textTheme.bodyLarge,
        icon: const Icon(Icons.arrow_drop_down_rounded),
        isExpanded: isExpanded,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}