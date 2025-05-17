import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../theme/text_font_style.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.buttonBackground(context);
    final txtColor = textColor ?? AppColors.buttonText(context);

    return ElevatedButton.icon(
      icon: icon ?? const SizedBox.shrink(),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      label: TextFontStyle.myAppText(
        context,
        text,
        style: TextStyleType.medium,
        color: txtColor,
      ),
    );
  }
}
