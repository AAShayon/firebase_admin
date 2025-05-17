import 'package:flutter/material.dart';

import '../theme/app_color.dart';
import '../theme/text_font_style.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider(context),
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFontStyle.myAppText(
            context,
            text,
            style: TextStyleType.small,
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider(context),
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }
}
