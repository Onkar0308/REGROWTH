import 'package:flutter/material.dart';

class AppColors {
  // Colors
  static const Color primary = Color(0xFFA5C1F8);
  static const Color secondary = Color(0xFFB5E7F7); // Light blue
  static const Color accent = Color(0xFFBFD2F8);
  static const Color pink = Color(0xFFFED1DC);
  static const Color white = Color(0xFFFCFEFE); // Off-white
  static const Color black = Color(0xFF212124); // Dark gray
  static const Color grey = Color(0xFFBEBEBE); // Dark gray
  static const Color textblue = Color(0xFF5F96FB);
  static const Color buttoncolor = Colors.blue;

  // Gradient colors
  static final List<Color> splashGradient = [
    primary,
    pink,
  ];
  static final List<Color> mainGradient = [
    primary,
    pink,
  ];
  static final List<Color> lightGradient = [
    accent,
    white,
  ];
}

//Assets Paths
class AppAssets {
  // Images
  static const String imagePath = "assets/images";
  static const String iconPath = "assets/icons";

  // Logo paths
  static const String logo = "$imagePath/assets/images/Regrowth_logo_1.PNG";
}

// In constants.dart
class AppTextStyles {
  static const TextStyle listTileTitle = TextStyle(
    fontFamily: 'Lexend',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.022,
    color: Color.fromRGBO(0, 0, 0, 1),
  );
}
