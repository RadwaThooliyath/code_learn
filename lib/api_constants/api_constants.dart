import 'dart:io';

class ApiConstants {
  static const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  
  static const String _macLocalBaseUrl = "http://127.0.0.1:8000/api/users/auth";
  static const String _iOSSimulatorBaseUrl = "http://localhost:8000/api/users/auth";
  static const String _androidEmulatorBaseUrl = "http://10.0.2.2:8000/api/users/auth";
  
  // For real devices - Your Mac's actual IP address
  // Found with: ifconfig | grep "inet " | grep -v 127.0.0.1
  static const String _realDeviceBaseUrl = "http://192.168.1.46:8000/api/users/auth"; // Your actual Mac IP
  
  static const String _productionBaseUrl = "https://your-production-api.com/api/users/auth";
  
  static String get authBase {
    if (kDebugMode) {
      if (Platform.isIOS) {
        final isSimulator = _isSimulator();
        final url = isSimulator ? _iOSSimulatorBaseUrl : _realDeviceBaseUrl;
        print("📱 iOS Platform - Simulator: $isSimulator, URL: $url");
        return url;
      } else if (Platform.isAndroid) {
        final isEmulator = _isEmulator();
        final url = isEmulator ? _androidEmulatorBaseUrl : _realDeviceBaseUrl;
        print("🤖 Android Platform - Emulator: $isEmulator, URL: $url");
        return url;
      } else {
        print("💻 Desktop Platform - URL: $_macLocalBaseUrl");
        return _macLocalBaseUrl;
      }
    }
    return _productionBaseUrl;
  }
  
  // Detect if running on simulator/emulator
  static bool _isSimulator() {
    if (Platform.isIOS) {
      // iOS Simulator detection - check multiple indicators
      return Platform.environment['SIMULATOR_DEVICE_NAME'] != null ||
             Platform.environment['SIMULATOR_ROOT'] != null ||
             Platform.environment.containsKey('SIMULATOR_UDID');
    } else if (Platform.isAndroid) {
      // Android Emulator detection
      return Platform.environment.containsKey('ANDROID_EMU_SDK_VERSION') ||
             Platform.environment.containsKey('ANDROID_AVD_NAME');
    }
    return false;
  }
  
  static bool _isEmulator() => _isSimulator();
  
  static String get login => "$authBase/login/";
  static String get register => "$authBase/register/";
}