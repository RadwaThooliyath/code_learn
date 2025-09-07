import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/user_model.dart';
import 'package:uptrail/services/storage_service.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _makeAuthorizedRequest(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    
    if (response.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshResponse = await http.post(
            Uri.parse(ApiConstants.refresh),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          );
          
          if (refreshResponse.statusCode == 200) {
            final refreshData = jsonDecode(refreshResponse.body);
            final newAccessToken = refreshData['access'];
            await StorageService.saveToken(newAccessToken);
            
            response = await request();
          }
        } catch (e) {
        }
      }
    }
    
    return response;
  }

  Future<User?> getUserProfile() async {
    try {
      final response = await _makeAuthorizedRequest(() async {
        final headers = await _getAuthHeaders();
        return http.get(
          Uri.parse(ApiConstants.userProfile),
          headers: headers,
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<User?> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (address != null) updateData['address'] = address;

      final response = await _makeAuthorizedRequest(() async {
        final headers = await _getAuthHeaders();
        return http.put(
          Uri.parse(ApiConstants.userProfile),
          headers: headers,
          body: jsonEncode(updateData),
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final response = await _makeAuthorizedRequest(() async {
        final headers = await _getAuthHeaders();
        return http.post(
          Uri.parse(ApiConstants.changePassword),
          headers: headers,
          body: jsonEncode({
            'old_password': currentPassword,
            'new_password': newPassword,
            'new_password_confirm': confirmNewPassword,
          }),
        );
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserStatistics() async {
    try {
      final response = await _makeAuthorizedRequest(() async {
        final headers = await _getAuthHeaders();
        return http.get(
          Uri.parse('${ApiConstants.usersBaseUrl}/stats/'),
          headers: headers,
        );
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}