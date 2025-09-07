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
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        response = await request();
      } else {
      }
    }
    
    return response;
  }

  Future<List<Assignment>> getModuleAssignments(int moduleId) async {
    try {
      final url = Uri.parse(ApiConstants.moduleAssignments(moduleId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> assignmentsList;
        if (data is Map && data.containsKey('results')) {
          assignmentsList = data['results'];
        } else if (data is List) {
          assignmentsList = data;
        } else {
          return [];
        }
        
        return assignmentsList
            .map((assignmentJson) => Assignment.fromJson(assignmentJson))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch assignments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assignments: $e');
    }
  }

  Future<Assignment> getAssignmentDetail(int assignmentId) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentDetail(assignmentId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Assignment.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch assignment detail: ${response.statusCode}');
      }
    } catch (e) {
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

      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> submissionsList;
        if (data is Map && data.containsKey('results')) {
          submissionsList = data['results'];
        } else if (data is List) {
          submissionsList = data;
        } else {
          return [];
        }
        
        return submissionsList
            .map((submissionJson) => AssignmentSubmission.fromJson(submissionJson))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch assignment submissions: ${response.statusCode}');
      }
    } catch (e) {
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
      
      final body = jsonEncode({
        'assignment': assignmentId,
        'github_url': githubUrl,
        'submission_notes': submissionNotes ?? '',
        'status': status,
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create assignment submission');
      }
    } catch (e) {
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
      
      Map<String, dynamic> bodyData = {};
      if (githubUrl != null) bodyData['github_url'] = githubUrl;
      if (submissionNotes != null) bodyData['submission_notes'] = submissionNotes;
      if (status != null) bodyData['status'] = status;
      
      final body = jsonEncode(bodyData);
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.put(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update assignment submission');
      }
    } catch (e) {
      throw Exception('Error updating assignment submission: $e');
    }
  }

  Future<AssignmentSubmission> submitAssignment(int submissionId) async {
    try {
      final url = Uri.parse(ApiConstants.assignmentSubmissionDetail(submissionId));
      
      final body = jsonEncode({'status': 'submitted'});
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.patch(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AssignmentSubmission.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit assignment');
      }
    } catch (e) {
      throw Exception('Error submitting assignment: $e');
    }
  }
}