import 'package:flutter/material.dart';

class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => getScreenWidth(context) < 768;
  
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 768 && width < 1024;
  }
  
  static bool isDesktop(BuildContext context) => getScreenWidth(context) >= 1024;
  
  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(20);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(40);
    } else {
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 40);
    }
  }
  
  // Responsive form width
  static double getFormWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return 400; // Fixed width for desktop
    }
  }
  
  // Responsive font sizes
  static double getHeadingSize(BuildContext context) {
    if (isMobile(context)) {
      return 28;
    } else if (isTablet(context)) {
      return 32;
    } else {
      return 36;
    }
  }
  
  static double getSubheadingSize(BuildContext context) {
    if (isMobile(context)) {
      return 20;
    } else if (isTablet(context)) {
      return 22;
    } else {
      return 24;
    }
  }
}