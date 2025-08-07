import 'dart:io';

class ApiConstants {
  static const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  
  static const String _macLocalBaseUrl = "http://127.0.0.1:8000/api/users/auth";
  static const String _iOSSimulatorBaseUrl = "http://localhost:8000/api/users/auth";
  static const String _androidEmulatorBaseUrl = "http://10.0.2.2:8000/api/users/auth";
  static const String _productionBaseUrl = "https://your-production-api.com/api/users/auth";
  
  static String get authBase {
    if (kDebugMode) {
      if (Platform.isIOS) {
        return _iOSSimulatorBaseUrl;
      } else if (Platform.isAndroid) {
        return _androidEmulatorBaseUrl;
      } else {
        return _macLocalBaseUrl;
      }
    }
    return _productionBaseUrl;
  }
  
  static String get login => "$authBase/login/";
  static String get register => "$authBase/register/";
}