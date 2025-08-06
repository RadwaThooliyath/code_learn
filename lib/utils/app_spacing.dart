import 'package:flutter/material.dart';

class AppSpacing {
  // Vertical spacing
  static const SizedBox verySmall = SizedBox(height: 8.0);
  static const SizedBox small = SizedBox(height: 16.0);
  static const SizedBox medium = SizedBox(height: 24.0);
  static const SizedBox large = SizedBox(height: 32.0);
  static const SizedBox veryLarge = SizedBox(height: 48.0);
  
  // Horizontal spacing
  static const SizedBox hSmall = SizedBox(width: 8.0);
  static const SizedBox hMedium = SizedBox(width: 16.0);
  static const SizedBox hLarge = SizedBox(width: 24.0);
  
  // Padding constants
  static const EdgeInsets paddingXS = EdgeInsets.all(4.0);
  static const EdgeInsets paddingS = EdgeInsets.all(8.0);
  static const EdgeInsets paddingM = EdgeInsets.all(16.0);
  static const EdgeInsets paddingL = EdgeInsets.all(24.0);
  static const EdgeInsets paddingXL = EdgeInsets.all(32.0);
  
  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(20.0);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets screenPaddingVertical = EdgeInsets.symmetric(vertical: 20.0);
  
  // Form spacing
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0);
  static const double formFieldSpacing = 20.0;
}