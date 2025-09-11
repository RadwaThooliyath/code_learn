import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _submittedLeadsKey = 'submitted_leads';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token;
  }

  static Future<void> saveUserData({
    required String userId,
    required String name,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_userEmailKey, email);
    }
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString(_userPhoneKey, phone);
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
    };
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Alias method for consistency with auth service
  static Future<void> clearAll() async {
    await clearAllData();
  }

  // Lead submission tracking methods
  static Future<void> saveSubmittedLead({
    required String referenceNumber,
    required String name,
    required String email,
    required String phone,
    required String areaOfInterest,
    required String estimatedContactTime,
    required List<String> nextSteps,
    required DateTime submittedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existingLeads = await getSubmittedLeads();
    
    final newLead = {
      'referenceNumber': referenceNumber,
      'name': name,
      'email': email,
      'phone': phone,
      'areaOfInterest': areaOfInterest,
      'estimatedContactTime': estimatedContactTime,
      'nextSteps': nextSteps,
      'submittedAt': submittedAt.toIso8601String(),
      'status': 'submitted',
    };
    
    existingLeads.add(newLead);
    await prefs.setString(_submittedLeadsKey, jsonEncode(existingLeads));
  }

  static Future<List<Map<String, dynamic>>> getSubmittedLeads() async {
    final prefs = await SharedPreferences.getInstance();
    final leadsString = prefs.getString(_submittedLeadsKey);
    
    if (leadsString == null) {
      return [];
    }
    
    try {
      final List<dynamic> leadsJson = jsonDecode(leadsString);
      return leadsJson.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updateLeadStatus(String referenceNumber, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final leads = await getSubmittedLeads();
    
    for (int i = 0; i < leads.length; i++) {
      if (leads[i]['referenceNumber'] == referenceNumber) {
        leads[i]['status'] = status;
        leads[i]['lastUpdated'] = DateTime.now().toIso8601String();
        break;
      }
    }
    
    await prefs.setString(_submittedLeadsKey, jsonEncode(leads));
  }

  static Future<void> clearSubmittedLeads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_submittedLeadsKey);
  }
}