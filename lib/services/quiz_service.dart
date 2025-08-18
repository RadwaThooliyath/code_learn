import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class QuizService {
  final AuthService _authService = AuthService();
  
  Future<Map<String, String>> _getHeaders() async {
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
      print("🔄 Token expired, attempting refresh...");
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        print("✅ Token refreshed, retrying request...");
        response = await request();
      } else {
        print("❌ Token refresh failed, user needs to re-login");
      }
    }
    
    return response;
  }

  Future<List<Quiz>> getModuleQuizzes(int moduleId) async {
    try {
      final url = Uri.parse(ApiConstants.moduleQuizzes(moduleId));
      print("🧠 Fetching module quizzes from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> quizzesList;
        if (data is Map && data.containsKey('results')) {
          quizzesList = data['results'];
        } else if (data is List) {
          quizzesList = data;
        } else {
          print("❌ Unexpected response format for quizzes");
          return [];
        }
        
        return quizzesList
            .map((quizJson) => Quiz.fromJson(quizJson))
            .toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch quizzes: ${response.statusCode}");
        throw Exception('Failed to fetch quizzes: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching quizzes: $e");
      throw Exception('Error fetching quizzes: $e');
    }
  }

  Future<Quiz> getQuizDetail(int quizId) async {
    try {
      final url = Uri.parse(ApiConstants.quizDetail(quizId));
      print("🧠 Fetching quiz detail from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quiz.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch quiz detail: ${response.statusCode}");
        throw Exception('Failed to fetch quiz detail: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching quiz detail: $e");
      throw Exception('Error fetching quiz detail: $e');
    }
  }

  Future<List<QuizAttempt>> getMyQuizAttempts({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.quizAttempts);
      
      Map<String, String> queryParams = {};
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print("🧠 Fetching quiz attempts from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> attemptsList;
        if (data is Map && data.containsKey('results')) {
          attemptsList = data['results'];
        } else if (data is List) {
          attemptsList = data;
        } else {
          print("❌ Unexpected response format for quiz attempts");
          return [];
        }
        
        return attemptsList
            .map((attemptJson) => QuizAttempt.fromJson(attemptJson))
            .toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch quiz attempts: ${response.statusCode}");
        throw Exception('Failed to fetch quiz attempts: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching quiz attempts: $e");
      throw Exception('Error fetching quiz attempts: $e');
    }
  }

  Future<QuizAttempt> startQuizAttempt(int quizId) async {
    try {
      final url = Uri.parse(ApiConstants.startQuizAttempt(quizId));
      print("🧠 Starting quiz attempt at: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return QuizAttempt.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to start quiz attempt: ${response.statusCode}");
        String errorMessage = 'Failed to start quiz attempt';
        
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON (like HTML error page), use status code
          if (response.statusCode == 500) {
            errorMessage = 'Server error - please try again later';
          } else if (response.statusCode == 403) {
            errorMessage = 'You do not have permission to take this quiz';
          } else if (response.statusCode == 404) {
            errorMessage = 'Quiz not found';
          } else {
            errorMessage = 'Failed to start quiz (Error ${response.statusCode})';
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Error starting quiz attempt: $e");
      throw Exception('Error starting quiz attempt: $e');
    }
  }

  Future<QuizAttempt> submitQuizAttempt({
    required int attemptId,
    required List<QuizAnswer> answers,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.submitQuizAttempt(attemptId));
      print("🧠 Submitting quiz attempt at: $url");
      
      final body = jsonEncode({
        'answers': answers.map((answer) => answer.toJson()).toList(),
      });
      
      print("Request Body: $body");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return QuizAttempt.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to submit quiz attempt: ${response.statusCode}");
        String errorMessage = 'Failed to submit quiz attempt';
        
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON (like HTML error page), use status code
          if (response.statusCode == 500) {
            errorMessage = 'Server error - please try again later';
          } else if (response.statusCode == 403) {
            errorMessage = 'You do not have permission to submit this quiz';
          } else if (response.statusCode == 404) {
            errorMessage = 'Quiz attempt not found';
          } else {
            errorMessage = 'Failed to submit quiz (Error ${response.statusCode})';
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Error submitting quiz attempt: $e");
      throw Exception('Error submitting quiz attempt: $e');
    }
  }
}