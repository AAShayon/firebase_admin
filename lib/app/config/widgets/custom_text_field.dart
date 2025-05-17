import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(color: AppColors.textPrimary(context)),
        hintStyle: TextStyle(color: AppColors.textSecondary(context)),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary(context), width: 2.0),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputFill(context),
      ),
      style: TextStyle(color: AppColors.textPrimary(context)),
    );
  }
}
