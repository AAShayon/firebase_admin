import 'package:flutter/material.dart';
import 'app_color.dart';

enum TextStyleType { small, medium, large }

class TextFontStyle {
  TextFontStyle._();

  // Fixed font sizes for mobile
  static double fontSizeSmall = 12;
  static double fontSizeMedium = 15;
  static double fontSizeLarge = 18;

  // Styles for different text types
  static TextStyle smallText(BuildContext context) => _getTextStyle(
    context,
    fontSizeSmall,
    FontWeight.normal,
  );

  static TextStyle mediumText(BuildContext context) => _getTextStyle(
    context,
    fontSizeMedium,
    FontWeight.normal,
  );

  static TextStyle largeText(BuildContext context) => _getTextStyle(
    context,
    fontSizeLarge,
    FontWeight.bold,
  );

  // Helper method to create text styles
  static TextStyle _getTextStyle(
      BuildContext context,
      double fontSize,
      FontWeight fontWeight,
      ) {
    return TextStyle(
      color: AppColors.textPrimary(context),
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // Helper Widget for Text with Dynamic Style
  static Widget myAppText(
      BuildContext context,
      String text, {
        TextStyleType style = TextStyleType.medium,
        Color? color,
        double? textSize,
        String? fontFamily, // optional, in case you want custom font via pubspec
        FontWeight? fontWeight,
        TextAlign? textAlign,
        TextOverflow? overflow,
        int? maxLines,
      }) {
    final TextStyle baseStyle;
    switch (style) {
      case TextStyleType.small:
        baseStyle = smallText(context);
        break;
      case TextStyleType.large:
        baseStyle = largeText(context);
        break;
      case TextStyleType.medium:
      baseStyle = mediumText(context);
        break;
    }

    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: baseStyle.copyWith(
        color: color ?? baseStyle.color,
        fontSize: textSize ?? baseStyle.fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight ?? baseStyle.fontWeight,
      ),
    );
  }
}
