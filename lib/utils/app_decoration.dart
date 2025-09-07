import 'package:flutter/material.dart';
import '../app_constants/colors.dart';

class AppDecoration {
  // Border radius constants
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 20.0;
  
  // Border radius objects
  static BorderRadius get borderRadiusS => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusM => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusL => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  
  // Form field decoration
  static InputDecoration formFieldDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color fillColor = AppColors.white,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      filled: true,
      fillColor: fillColor,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusL,
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusL,
        borderSide: const BorderSide(color: AppColors.robinEggBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusL,
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadiusL,
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
  
  // Box shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Container decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusL,
    boxShadow: softShadow,
  );
  
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: borderRadiusL,
    boxShadow: mediumShadow,
  );
  
  // Gradient decorations
  static BoxDecoration get primaryGradientDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.green1,
        AppColors.logoDarkTeal,
      ],
    ),
    borderRadius: borderRadiusL,
    boxShadow: softShadow,
  );
  
  static BoxDecoration get accentGradientDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.logoDarkTeal,
        AppColors.green1,
      ],
    ),
    borderRadius: borderRadiusL,
    boxShadow: softShadow,
  );
}