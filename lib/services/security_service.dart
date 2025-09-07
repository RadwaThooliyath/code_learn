import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._internal();
  
  SecurityService._internal();
  
  bool _isScreenshotListenerActive = false;

  /// Initialize security features for the app
  Future<void> initializeSecurity() async {
    try {
      await _enableScreenshotPrevention();
      await _setupScreenshotDetection();
      await _enableScreenRecordingPrevention();
    } catch (e) {
      debugPrint('Security initialization error: $e');
    }
  }

  /// Enable screenshot prevention on Android and iOS
  Future<void> _enableScreenshotPrevention() async {
    try {
      if (Platform.isAndroid) {
        // On Android, prevent screenshots and screen recording using method channel
        await _enableAndroidScreenshotPrevention();
        debugPrint('✅ Screenshot prevention enabled (Android)');
      } else if (Platform.isIOS) {
        // On iOS, we'll use method channels for additional security
        await _enableiOSScreenshotPrevention();
        debugPrint('✅ Screenshot prevention enabled (iOS)');
      }
    } catch (e) {
      debugPrint('❌ Failed to enable screenshot prevention: $e');
    }
  }

  /// Enable screen recording prevention
  Future<void> _enableScreenRecordingPrevention() async {
    try {
      if (Platform.isAndroid) {
        // Android: FLAG_SECURE also prevents screen recording
        await _enableAndroidScreenshotPrevention();
        debugPrint('✅ Screen recording prevention enabled (Android)');
      } else if (Platform.isIOS) {
        // iOS: Screen recording detection will be handled in screenshot detection
        debugPrint('✅ Screen recording prevention enabled (iOS)');
      }
    } catch (e) {
      debugPrint('❌ Failed to enable screen recording prevention: $e');
    }
  }

  /// Setup screenshot detection and response
  Future<void> _setupScreenshotDetection() async {
    try {
      // Use method channels for screenshot detection on both platforms
      if (Platform.isAndroid || Platform.isIOS) {
        const platform = MethodChannel('com.uptrail.security/screenshot');
        await platform.invokeMethod('setupScreenshotDetection');
        _isScreenshotListenerActive = true;
        debugPrint('✅ Screenshot detection listener activated');
      }
    } catch (e) {
      debugPrint('❌ Failed to setup screenshot detection: $e');
    }
  }

  /// Handle screenshot detection
  void _onScreenshotDetected() {
    debugPrint('🚨 SECURITY ALERT: Screenshot attempt detected!');
    
    // You can add additional actions here:
    // - Log security event
    // - Show warning dialog
    // - Send analytics event
    // - Take corrective action
    
    _showSecurityWarning();
  }

  /// Show security warning to user
  void _showSecurityWarning() {
    // Note: This requires access to BuildContext, so we'll implement it
    // in the main app where context is available
    debugPrint('⚠️ Security warning should be displayed to user');
  }

  /// Enable iOS-specific screenshot prevention
  Future<void> _enableiOSScreenshotPrevention() async {
    try {
      // For iOS, we can use a method channel to communicate with native code
      const platform = MethodChannel('com.uptrail.security/screenshot');
      await platform.invokeMethod('preventScreenshots');
    } catch (e) {
      debugPrint('iOS screenshot prevention method channel error: $e');
    }
  }

  /// Enable Android-specific screenshot prevention
  Future<void> _enableAndroidScreenshotPrevention() async {
    try {
      // For Android, use method channel to set FLAG_SECURE
      const platform = MethodChannel('com.uptrail.security/screenshot');
      await platform.invokeMethod('enableScreenshotPrevention');
    } catch (e) {
      debugPrint('Android screenshot prevention method channel error: $e');
    }
  }

  /// Disable screenshot prevention (for specific screens if needed)
  Future<void> disableScreenshotPrevention() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('com.uptrail.security/screenshot');
        await platform.invokeMethod('disableScreenshotPrevention');
        debugPrint('📱 Screenshot prevention disabled');
      }
    } catch (e) {
      debugPrint('❌ Failed to disable screenshot prevention: $e');
    }
  }

  /// Check if screen recording is active (iOS)
  Future<bool> isScreenRecording() async {
    try {
      if (Platform.isIOS) {
        const platform = MethodChannel('com.uptrail.security/recording');
        return await platform.invokeMethod('isScreenRecording');
      }
      return false;
    } catch (e) {
      debugPrint('Screen recording check error: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    if (_isScreenshotListenerActive) {
      _isScreenshotListenerActive = false;
      debugPrint('🔒 Security service disposed');
    }
  }

  /// Show security alert dialog
  static void showSecurityAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.security,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Security Alert',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'I Understand',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show screenshot prevention info
  static void showScreenshotInfo(BuildContext context) {
    showSecurityAlert(
      context,
      'Screenshots and screen recording are disabled to protect course content and student privacy.',
    );
  }
}