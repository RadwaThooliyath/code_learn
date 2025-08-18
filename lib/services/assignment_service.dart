import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/assignment_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class AssignmentService {
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

  Future<List<Assignment>> getModuleAssignments(int moduleId) async {
    try {
      final url = Uri.parse(ApiConstants.moduleAssignments(moduleId));
      print("📝 Fetching module assignments from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> assignmentsList;
        if (data is Map && data.containsKey('results')) {
          assignmentsList = data['results'];
        } else if (data is List) {
          assignmentsList = data;
        } else {
          print("❌ Unexpected response format for assignments");
          return [];
        }
        
        return assignmentsList
            .map((assignmentJson) => Assignment.fromJson(assignmentJson))
            .toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch assignments: ${response.statusCode}");
        throw Exception('Failed to fetch assignments: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching assignments: $e");
      throw Exception('Error fetching assignments: $e');
    }
  }

  Future<Assignment> getAssignmentDetail(int assignmentId) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentDetail(assignmentId));
      print("📝 Fetching assignment detail from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Assignment.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch assignment detail: ${response.statusCode}");
        throw Exception('Failed to fetch assignment detail: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching assignment detail: $e");
      throw Exception('Error fetching assignment detail: $e');
    }
  }

  Future<List<AssignmentSubmission>> getMyAssignmentSubmissions({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.assignmentSubmissions);
      
      Map<String, String> queryParams = {};
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print("📝 Fetching assignment submissions from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> submissionsList;
        if (data is Map && data.containsKey('results')) {
          submissionsList = data['results'];
        } else if (data is List) {
          submissionsList = data;
        } else {
          print("❌ Unexpected response format for submissions");
          return [];
        }
        
        return submissionsList
            .map((submissionJson) => AssignmentSubmission.fromJson(submissionJson))
            .toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch assignment submissions: ${response.statusCode}");
        throw Exception('Failed to fetch assignment submissions: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching assignment submissions: $e");
      throw Exception('Error fetching assignment submissions: $e');
    }
  }

  Future<AssignmentSubmission> createAssignmentSubmission({
    required int assignmentId,
    required String githubUrl,
    String? submissionNotes,
    String status = 'draft',
  }) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentSubmissions);
      print("📝 Creating assignment submission at: $url");
      
      final body = jsonEncode({
        'assignment': assignmentId,
        'github_url': githubUrl,
        'submission_notes': submissionNotes ?? '',
        'status': status,
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
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to create assignment submission: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create assignment submission');
      }
    } catch (e) {
      print("❌ Error creating assignment submission: $e");
      throw Exception('Error creating assignment submission: $e');
    }
  }

  Future<AssignmentSubmission> updateAssignmentSubmission({
    required int submissionId,
    String? githubUrl,
    String? submissionNotes,
    String? status,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentSubmissionDetail(submissionId));
      print("📝 Updating assignment submission at: $url");
      
      Map<String, dynamic> bodyData = {};
      if (githubUrl != null) bodyData['github_url'] = githubUrl;
      if (submissionNotes != null) bodyData['submission_notes'] = submissionNotes;
      if (status != null) bodyData['status'] = status;
      
      final body = jsonEncode(bodyData);
      print("Request Body: $body");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.put(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to update assignment submission: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update assignment submission');
      }
    } catch (e) {
      print("❌ Error updating assignment submission: $e");
      throw Exception('Error updating assignment submission: $e');
    }
  }

  Future<AssignmentSubmission> submitAssignment(int submissionId) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentSubmissionDetail(submissionId));
      print("📝 Submitting assignment at: $url");
      
      final body = jsonEncode({'status': 'submitted'});
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.patch(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to submit assignment: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit assignment');
      }
    } catch (e) {
      print("❌ Error submitting assignment: $e");
      throw Exception('Error submitting assignment: $e');
    }
  }
}