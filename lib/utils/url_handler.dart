import 'package:flutter/material.dart';
import 'package:uptrail/view/password_reset_confirm_page.dart';
import 'package:uptrail/view/loginPage.dart';

class UrlHandler {
  static void handleUrl(BuildContext context, String url) {
    final uri = Uri.parse(url);
    
    // Handle password reset confirmation URLs
    if (uri.path.contains('/auth/password-reset-confirm/')) {
      final pathSegments = uri.pathSegments;
      final tokenIndex = pathSegments.indexOf('password-reset-confirm') + 1;
      
      if (tokenIndex < pathSegments.length) {
        final token = pathSegments[tokenIndex];
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => PasswordResetConfirmPage(token: token),
          ),
          (route) => false,
        );
        return;
      }
    }
    
    // Default fallback - navigate to login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
  
  static bool isPasswordResetUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.path.contains('/auth/password-reset-confirm/');
    } catch (e) {
      return false;
    }
  }
  
  static String? extractTokenFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final tokenIndex = pathSegments.indexOf('password-reset-confirm') + 1;
      
      if (tokenIndex < pathSegments.length) {
        return pathSegments[tokenIndex];
      }
    } catch (e) {
      // Handle parsing errors gracefully
    }
    return null;
  }
}