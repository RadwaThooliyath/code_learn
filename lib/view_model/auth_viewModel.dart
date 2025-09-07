import 'package:uptrail/model/user_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:uptrail/services/user_profile_service.dart';
import 'package:flutter/cupertino.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String _error = "";
  bool _isLoadingProfile = false;
  Map<String, String> _fieldErrors = {};

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isLoadingProfile => _isLoadingProfile;
  Map<String, String> get fieldErrors => _fieldErrors;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _setFieldErrors(Map<String, String> fieldErrors) {
    _fieldErrors = fieldErrors;
    notifyListeners();
  }

  void _clearErrors() {
    _error = "";
    _fieldErrors = {};
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final startTime = DateTime.now();
    
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final userData = await StorageService.getUserData();
        
        if (userData['userId'] != null && userData['name'] != null) {
          final user = User(
            id: int.tryParse(userData['userId']!),
            name: userData['name'],
            email: userData['email'], // Can be null
            role: null,
          );
          _setUser(user);
        } else {
          await StorageService.clearAllData();
        }
      } else {
      }
    } catch (e) {
      await StorageService.clearAllData();
    }
    
    // Ensure minimum splash screen duration of 2.5 seconds for branding
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minSplashDuration = 2500; // 2.5 seconds
    
    if (elapsed < minSplashDuration) {
      final remainingTime = minSplashDuration - elapsed;
      await Future.delayed(Duration(milliseconds: remainingTime));
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearErrors();
    try {
      final loggedInUser = await _authService.login(email, password);
      if (loggedInUser != null) {
        _setUser(loggedInUser);
        return true;
      } else {
        _setError("Login failed. Please try again");
        return false;
      }
    } catch (e) {
      print('🔥 AUTH VIEWMODEL - Exception caught: $e');
      print('🔥 AUTH VIEWMODEL - Exception type: ${e.runtimeType}');
      
      if (e is LoginException) {
        print('🔥 AUTH VIEWMODEL - LoginException message: "${e.message}"');
        print('🔥 AUTH VIEWMODEL - LoginException fieldErrors: ${e.fieldErrors}');
        
        // Handle field-specific errors from LoginException
        if (e.fieldErrors != null && e.fieldErrors!.isNotEmpty) {
          print('🔥 AUTH VIEWMODEL - Setting field errors: ${e.fieldErrors}');
          _setFieldErrors(e.fieldErrors!);
          // Don't set general error when we have field-specific errors
        } else if (e.message.isNotEmpty) {
          print('🔥 AUTH VIEWMODEL - Setting general error: "${e.message}"');
          _setError(e.message);
        }
      } else {
        // Extract the meaningful error message from other exceptions
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11); // Remove "Exception: " prefix
        }
        _setError(errorMessage);
      }
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
    _clearErrors();
  }

  Future<void> refreshUserProfile() async {
    if (!isAuthenticated) return;
    
    _isLoadingProfile = true;
    notifyListeners();
    
    try {
      final profileData = await _profileService.getUserProfile();
      if (profileData != null) {
        _setUser(profileData);
      }
    } catch (e) {
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    if (!isAuthenticated) return false;
    
    _isLoadingProfile = true;
    notifyListeners();
    
    try {
      final updatedUser = await _profileService.updateUserProfile(
        name: name,
        phoneNumber: phoneNumber,
        address: address,
      );
      
      if (updatedUser != null) {
        _setUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  void updateUser(User user) {
    _setUser(user);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (!isAuthenticated) return false;
    
    try {
      return await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final result = await _authService.deleteAccount();
      
      if (result['success']) {
        // Clear user data and state after successful deletion
        _setUser(null);
        _setError("");
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account: $e'
      };
    }
  }
}
