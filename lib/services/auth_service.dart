import 'dart:convert';

import 'package:code_learn/api_constants/api_constants.dart';
import 'package:code_learn/model/user_model.dart';
import 'package:http/http.dart' as http;

class AuthService {
  //final String baseUrl = "http://127.0.0.1:8000/api/users/auth";

  Future<User?> login(String email, String password) async {
    final url = Uri.parse(ApiConstants.login);
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception("Failed to login ${response.statusCode}");
      }
    } catch (e) {
      print("Login error : $e");
      return null;
    }
  }

  Future<User?> register(String name, String email, String password) async {
    final url = Uri.parse(ApiConstants.register);
    try {
      final response = await http.post(
        url,
        headers: {"content-type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception("failed to register ${response.statusCode}");
      }
    } catch (e) {
      print("Register error : $e");
      return null;
    }
  }
}
