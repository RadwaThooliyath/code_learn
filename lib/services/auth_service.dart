import 'dart:convert';

import 'package:code_learn/api_constants/api_constants.dart';
import 'package:code_learn/model/user_model.dart';
import 'package:code_learn/services/storage_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<User?> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.login);
    final requestBody = {"email": email, "password": password};
    
    print("Login URL: $url");
    print("Request Body: ${jsonEncode(requestBody)}");
    
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode(requestBody),
      );
      
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📦 Login response data: $data");
        
        final accessToken = data['access'] as String?;
        final refreshToken = data['refresh'] as String?;
        
        if (accessToken != null) {
          print("💾 Saving access token: ${accessToken.substring(0, 10)}...");
          await StorageService.saveToken(accessToken);
          
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
              print("🔓 JWT payload: $payloadData");
              
              final user = User(
                id: payloadData['user_id'],
                name: payloadData['name'],
                email: null, // Email not in JWT, we might need to get it from another endpoint
                role: payloadData['role'],
                token: accessToken,
              );
              
              print("💾 Saving user data from JWT: ID=${user.id}, Name=${user.name}, Role=${user.role}");
              await StorageService.saveUserData(
                userId: user.id.toString(),
                name: user.name!,
                email: user.email, // Can be null
              );
              
              return user;
            }
          } catch (e) {
            print("❌ Error decoding JWT: $e");
          }
        }
        
        print("⚠️ No access token found in response");
        return null;
      } else {
        print("Login failed with status: ${response.statusCode}");
        print("Error response: ${response.body}");
        throw Exception("Failed to login ${response.statusCode}");
      }
    } catch (e) {
      print("Login error : $e");
      return null;
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
      print("Register error : $e");
      return null;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAllData();
  }

  Future<bool> isLoggedIn() async {
    return await StorageService.isLoggedIn();
  }
}
