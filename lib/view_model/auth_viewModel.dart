import 'package:code_learn/model/user_model.dart';
import 'package:code_learn/services/auth_service.dart';
import 'package:code_learn/services/storage_service.dart';
import 'package:flutter/cupertino.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _error = "";

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    print("🔍 Checking authentication status...");
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      print("📱 Is logged in: $isLoggedIn");
      
      if (isLoggedIn) {
        final userData = await StorageService.getUserData();
        print("👤 User data: $userData");
        
        if (userData['userId'] != null && userData['name'] != null) {
          final user = User(
            id: int.tryParse(userData['userId']!),
            name: userData['name'],
            email: userData['email'], // Can be null
            role: null,
          );
          _setUser(user);
          print("✅ User restored: ${user.name} (${user.email ?? 'No email'})");
        } else {
          print("❌ Incomplete user data (missing userId or name), clearing storage");
          await StorageService.clearAllData();
        }
      } else {
        print("❌ No valid token found");
      }
    } catch (e) {
      print("💥 Error checking auth status: $e");
      await StorageService.clearAllData();
    } finally {
      _isInitialized = true;
      print("✅ Auth initialization complete. Authenticated: $isAuthenticated");
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError("");
    try {
      final loggedInUser = await _authService.login(email, password);
      if (loggedInUser != null) {
        _setUser(loggedInUser);
        return true;
      } else {
        _setError("Invalid credentials or failed to login");
        return false;
      }
    } catch (e) {
      _setError("Login failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String phoneNumber,
    String? address,
  }) async {
    _setLoading(true);
    _setError("");
    try {
      final registeredUser = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirm: passwordConfirm,
        phoneNumber: phoneNumber,
        address: address,
      );
      if (registeredUser != null) {
        _setUser(registeredUser);
        return true;
      } else {
        _setError("Registration failed");
        return false;
      }
    } catch (e) {
      _setError("Registration failed: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _setUser(null);
    _setError("");
  }

  void clearError() {
    _setError("");
  }
}
