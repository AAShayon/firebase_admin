import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final EdgeInsetsGeometry? padding;
  final Color? dropdownColor;
  final int? elevation;
  final TextStyle? style;
  final Widget? icon;
  final Color? iconEnabledColor;
  final bool isExpanded;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    this.padding,
    this.dropdownColor,
    this.elevation,
    this.style,
    this.icon,
    this.iconEnabledColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        dropdownColor: dropdownColor ?? Theme.of(context).colorScheme.surface,
        elevation: elevation ?? 8,
        style: style ?? Theme.of(context).textTheme.bodyLarge,
        icon: icon ?? const Icon(Icons.arrow_drop_down),
        iconEnabledColor: iconEnabledColor,
        isExpanded: isExpanded,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}