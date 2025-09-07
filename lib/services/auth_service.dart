import 'dart:convert';

import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/user_model.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class LoginException implements Exception {
  final String message;
  final Map<String, String>? fieldErrors;
  
  LoginException(this.message, {this.fieldErrors});
  
  @override
  String toString() => message;
}

class AuthService {
  Future<User?> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.login);
    final requestBody = {"email": email, "password": password};
    
    
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;
        
        if (accessToken != null) {
          await StorageService.saveToken(accessToken);
          
          if (refreshToken != null) {
            await StorageService.saveRefreshToken(refreshToken);
          }
          
          // Decode JWT to extract user info
          try {
            final parts = accessToken.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              // Add padding if needed
              String normalizedPayload = payload;
              while (normalizedPayload.length % 4 != 0) {
                normalizedPayload += '=';
              }
              
              final decoded = utf8.decode(base64Url.decode(normalizedPayload));
              final payloadData = jsonDecode(decoded);
              
              final user = User(
                id: payloadData['user_id'],
                name: payloadData['name'],
                email: null, // Email not in JWT, we might need to get it from another endpoint
                role: payloadData['role'],
                token: accessToken,
              );
              
              await StorageService.saveUserData(
                userId: user.id.toString(),
                name: user.name!,
                email: user.email, // Can be null
              );
              
              return user;
            }
          } catch (e) {
          }
        }
        
        return null;
      } else if (response.statusCode == 401) {
        // Parse response body to get specific error message
        print('🔥 LOGIN ERROR - Status Code: ${response.statusCode}');
        print('🔥 LOGIN ERROR - Response Body: ${response.body}');
        try {
          final data = jsonDecode(response.body);
          print('🔥 LOGIN ERROR - Parsed Data: $data');
          final errorMessage = data['error'] ?? data['detail'] ?? 'Invalid credentials';
          
          // Check if the error response contains field-specific errors
          Map<String, String>? fieldErrors;
          if (data is Map<String, dynamic>) {
            fieldErrors = <String, String>{};
            
            // Look for common field error patterns
            if (data.containsKey('email')) {
              fieldErrors['email'] = data['email'].toString();
            }
            if (data.containsKey('password')) {
              fieldErrors['password'] = data['password'].toString();
            }
            
            // Check if the error is about specific field
            final errorMsg = errorMessage.toLowerCase();
            if (errorMsg.contains('email')) {
              fieldErrors['email'] = 'Email not found or invalid';
            } else if (errorMsg.contains('password')) {
              fieldErrors['password'] = 'Incorrect password';
            }
            
            // If we have field-specific errors, don't use the general error message
            if (fieldErrors.isNotEmpty) {
              throw LoginException('', fieldErrors: fieldErrors);
            }
          }
          
          throw LoginException(errorMessage, fieldErrors: fieldErrors);
        } catch (e) {
          if (e is LoginException) rethrow;
          throw LoginException("Invalid email or password");
        }
      } else if (response.statusCode == 400) {
        print('🔥 LOGIN ERROR - Status Code: ${response.statusCode}');
        print('🔥 LOGIN ERROR - Response Body: ${response.body}');
        try {
          final data = jsonDecode(response.body);
          print('🔥 LOGIN ERROR - Parsed Data: $data');
          final errorMessage = data['error'] ?? data['detail'] ?? 'Invalid request';
          
          // Parse field-specific validation errors
          Map<String, String>? fieldErrors;
          if (data is Map<String, dynamic>) {
            fieldErrors = <String, String>{};
            if (data.containsKey('email')) {
              fieldErrors['email'] = data['email'].toString();
            }
            if (data.containsKey('password')) {
              fieldErrors['password'] = data['password'].toString();
            }
            
            // If we have field-specific errors, don't use the general error message
            if (fieldErrors.isNotEmpty) {
              throw LoginException('', fieldErrors: fieldErrors);
            }
          }
          
          throw LoginException(errorMessage, fieldErrors: fieldErrors);
        } catch (e) {
          if (e is LoginException) rethrow;
          throw LoginException("Please check your input and try again");
        }
      } else {
        print('🔥 LOGIN ERROR - Status Code: ${response.statusCode}');
        print('🔥 LOGIN ERROR - Response Body: ${response.body}');
        throw Exception("Login failed. Please try again later");
      }
    } catch (e) {
      if (e is Exception) {
        rethrow; // Re-throw our custom exceptions
      }
      throw Exception("Network error. Please check your internet connection");
    }
  }

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
    required String phoneNumber,
    String? address,
  }) async {
    final url = Uri.parse(ApiConstants.register);
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirm": passwordConfirm,
          "phone_number": phoneNumber,
          "address": address ?? "",
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        
        if (user.token != null) {
          await StorageService.saveToken(user.token!);
        }
        
        if (user.id != null && user.name != null && user.email != null) {
          await StorageService.saveUserData(
            userId: user.id.toString(),
            name: user.name!,
            email: user.email!,
          );
        }
        
        return user;
      } else {
        throw Exception("Failed to register ${response.statusCode}");
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAllData();
  }

  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      final url = Uri.parse(ApiConstants.refresh);
      final requestBody = {"refresh": refreshToken};
      
      
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'] as String?;
        
        if (newAccessToken != null) {
          await StorageService.saveToken(newAccessToken);
          return newAccessToken;
        }
      } else {
        // If refresh fails, clear all data and force re-login
        await StorageService.clearAllData();
      }
    } catch (e) {
      await StorageService.clearAllData();
    }
    
    return null;
  }

  Future<bool> requestPasswordReset(String email) async {
    final url = Uri.parse(ApiConstants.passwordReset);
    final requestBody = {"email": email};
    
    
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String newPasswordConfirm,
  }) async {
    final url = Uri.parse(ApiConstants.passwordResetConfirm(token));
    final requestBody = {
      "new_password": newPassword,
      "new_password_confirm": newPasswordConfirm,
    };
    
    
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset successful'
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Password reset failed',
          'errors': data
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred'
      };
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'User not authenticated'
        };
      }

      final url = Uri.parse(ApiConstants.deleteAccount);
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Clear all stored data after successful deletion
        await StorageService.clearAll();
        
        return {
          'success': true,
          'message': 'Account deleted successfully'
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Account deletion failed'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred'
      };
    }
  }
}
