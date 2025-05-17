import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF4361EE);  // Vibrant blue
  static const Color lightPrimaryVariant = Color(0xFF3A0CA3);  // Deep purple-blue
  static const Color lightSecondary = Color(0xFF4CC9F0);  // Sky blue
  static const Color lightSecondaryVariant = Color(0xFF4895EF);  // Medium blue
  static const Color lightBackground = Color(0xFFF8F9FA);  // Very light gray
  static const Color lightSurface = Color(0xFFFFFFFF);  // Pure white
  static const Color lightError = Color(0xFFE63946);  // Vibrant red
  static const Color lightSuccess = Color(0xFF2EC4B6);  // Teal
  static const Color lightWarning = Color(0xFFFF9F1C);  // Orange
  static const Color lightInfo = Color(0xFF7209B7);  // Purple

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF4CC9F0);  // Sky blue
  static const Color darkPrimaryVariant = Color(0xFF4895EF);  // Medium blue
  static const Color darkSecondary = Color(0xFF4361EE);  // Vibrant blue
  static const Color darkSecondaryVariant = Color(0xFF3A0CA3);  // Deep purple-blue
  static const Color darkBackground = Color(0xFF121212);  // True black
  static const Color darkSurface = Color(0xFF1E1E1E);  // Dark gray
  static const Color darkError = Color(0xFFFF6B6B);  // Soft red
  static const Color darkSuccess = Color(0xFF52B788);  // Soft green
  static const Color darkWarning = Color(0xFFFFD166);  // Soft yellow
  static const Color darkInfo = Color(0xFFA663CC);  // Soft purple

  // Neutral Colors (work for both themes)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralBlack = Color(0xFF000000);
  static const Color neutralGrey50 = Color(0xFFFAFAFA);
  static const Color neutralGrey100 = Color(0xFFF5F5F5);
  static const Color neutralGrey200 = Color(0xFFEEEEEE);
  static const Color neutralGrey300 = Color(0xFFE0E0E0);
  static const Color neutralGrey400 = Color(0xFFBDBDBD);
  static const Color neutralGrey500 = Color(0xFF9E9E9E);
  static const Color neutralGrey600 = Color(0xFF757575);
  static const Color neutralGrey700 = Color(0xFF616161);
  static const Color neutralGrey800 = Color(0xFF424242);
  static const Color neutralGrey900 = Color(0xFF212121);

  // Data Visualization Colors
  static const List<Color> chartColors = [
    Color(0xFF4361EE),
    Color(0xFF3A0CA3),
    Color(0xFF4CC9F0),
    Color(0xFF4895EF),
    Color(0xFF7209B7),
    Color(0xFFF72585),
    Color(0xFF2EC4B6),
    Color(0xFFFF9F1C),
  ];

  // Contextual Methods
  static Color primary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimary : lightPrimary;

  static Color primaryVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPrimaryVariant : lightPrimaryVariant;

  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondary : lightSecondary;

  static Color secondaryVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSecondaryVariant : lightSecondaryVariant;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color error(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkError : lightError;

  static Color success(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSuccess : lightSuccess;

  static Color warning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkWarning : lightWarning;

  static Color info(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkInfo : lightInfo;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neutralWhite : neutralGrey900;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neutralGrey400 : neutralGrey600;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? neutralGrey800 : neutralGrey200;

  // Special Gradients
  static LinearGradient primaryGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const LinearGradient(
        colors: [darkPrimary, darkPrimaryVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : const LinearGradient(
        colors: [lightPrimary, lightPrimaryVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient secondaryGradient(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const LinearGradient(
        colors: [darkSecondary, darkSecondaryVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          : const LinearGradient(
        colors: [lightSecondary, lightSecondaryVariant],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Button Styles
  static Color buttonBackground(BuildContext context) => primary(context);
  static Color buttonText(BuildContext context) => neutralWhite;
  static Color buttonBorder(BuildContext context) => Colors.transparent;

  // Card Styles
  static Color cardBackground(BuildContext context) => surface(context);
  static Color cardShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withAlpha(128)
          : Colors.grey.withAlpha(51);


  // Input Field Styles
  static Color inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? neutralGrey900
          : neutralGrey50;

  static Color inputBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? neutralGrey700
          : neutralGrey300;

  // Status Colors
  static Color activeStatus(BuildContext context) => success(context);
  static Color inactiveStatus(BuildContext context) => warning(context);
  static Color pendingStatus(BuildContext context) => info(context);
  static Color criticalStatus(BuildContext context) => error(context);
}