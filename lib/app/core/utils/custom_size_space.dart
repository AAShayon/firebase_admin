import 'package:flutter/material.dart';

class CustomSizeSpace {
  static const SizedBox vSmall8 = SizedBox(height: 8);
  static const SizedBox vMedium16 = SizedBox(height: 16);
  static const SizedBox vLarge24 = SizedBox(height: 24);
  static const SizedBox vXL32 = SizedBox(height: 32);
  static const SizedBox vXXL48 = SizedBox(height: 48);


  static const SizedBox hSmall8 = SizedBox(width: 8);
  static const SizedBox hMedium16 = SizedBox(width: 16);
  static const SizedBox hLarge24 = SizedBox(width: 24);
  static const SizedBox hXL32 = SizedBox(width: 32);
  static const SizedBox hXXL48 = SizedBox(width: 48);

  static SizedBox verticalCustom(double height) => SizedBox(height: height);
  static SizedBox horizontalCustom(double width) => SizedBox(width: width);
}
