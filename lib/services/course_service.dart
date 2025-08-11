import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class CourseService {
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

  Future<List<Course>> getCourses({
    String? category,
    bool? isFree,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.courses);
      
      Map<String, String> queryParams = {};
      if (category != null) queryParams['category'] = category;
      if (isFree != null) queryParams['is_free'] = isFree.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print("📚 Fetching courses from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> courses;
        if (data is Map && data.containsKey('results')) {
          courses = data['results'] as List;
        } else if (data is List) {
          courses = data;
        } else {
          print("❌ Unexpected response format for courses");
          return [];
        }
        
        // Filter courses to show only publicly available ones for students
        final filteredCourses = courses.where((courseJson) {
          final course = courseJson as Map<String, dynamic>;
          final allowPublicEnrollment = course['allow_public_enrollment'] ?? false;
          
          if (!allowPublicEnrollment) {
            print("🔒 Filtered out non-public course: ${course['title']}");
          }
          
          return allowPublicEnrollment;
        }).toList();
        
        print("📚 Showing ${filteredCourses.length}/${courses.length} publicly available courses");
        
        return filteredCourses
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
      } else {
        print("❌ Failed to fetch courses: ${response.statusCode}");
        throw Exception('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching courses: $e");
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<Course?> getCourseDetail(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.courseDetail(courseId));
      print("📖 Fetching course detail from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Course.fromJson(data);
      } else {
        print("❌ Failed to fetch course detail: ${response.statusCode}");
        throw Exception('Failed to fetch course detail: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching course detail: $e");
      throw Exception('Error fetching course detail: $e');
    }
  }

  Future<List<Course>> searchCourses(String query) async {
    try {
      final url = Uri.parse(ApiConstants.courseSearch).replace(
        queryParameters: {'q': query},
      );
      
      print("🔍 Searching courses: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        } else if (data is List) {
          return data.map((courseJson) => Course.fromJson(courseJson)).toList();
        } else {
          print("❌ Unexpected response format for course search");
          return [];
        }
      } else {
        print("❌ Failed to search courses: ${response.statusCode}");
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error searching courses: $e");
      throw Exception('Error searching courses: $e');
    }
  }

  Future<List<CourseCategory>> getCategories({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.courseCategories);
      
      Map<String, String> queryParams = {};
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print("📋 Fetching categories from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((categoryJson) => CourseCategory.fromJson(categoryJson))
              .toList();
        } else if (data is List) {
          return data.map((categoryJson) => CourseCategory.fromJson(categoryJson)).toList();
        } else {
          print("❌ Unexpected response format for categories");
          return [];
        }
      } else {
        print("❌ Failed to fetch categories: ${response.statusCode}");
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching categories: $e");
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Course>> getEnrolledCourses() async {
    try {
      final url = Uri.parse(ApiConstants.enrolledCourses);
      print("🎓 Fetching enrolled courses from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        } else if (data is List) {
          return data.map((courseJson) => Course.fromJson(courseJson)).toList();
        } else {
          print("❌ Unexpected response format for enrolled courses");
          return [];
        }
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch enrolled courses: ${response.statusCode}");
        throw Exception('Failed to fetch enrolled courses: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching enrolled courses: $e");
      throw Exception('Error fetching enrolled courses: $e');
    }
  }
}