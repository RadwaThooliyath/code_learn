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
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        response = await request();
      } else {
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

      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> courses;
        if (data is Map && data.containsKey('results')) {
          courses = data['results'] as List;
        } else if (data is List) {
          courses = data;
        } else {
          return [];
        }
        
        // Filter courses to show only publicly available ones for students
        final filteredCourses = courses.where((courseJson) {
          final course = courseJson as Map<String, dynamic>;
          final allowPublicEnrollment = course['allow_public_enrollment'] ?? false;
          
          if (!allowPublicEnrollment) {
          }
          
          return allowPublicEnrollment;
        }).toList();
        
        
        return filteredCourses
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  Future<Course?> getCourseDetail(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.courseDetail(courseId));
      
      final headers = await _getHeaders();
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: headers);
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        
        final course = Course.fromJson(data);
        
        
        return course;
      } else if (response.statusCode == 404) {
        return null; // Return null instead of throwing for 404
      } else {
        throw Exception('Failed to fetch course detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course detail: $e');
    }
  }


  Future<List<Course>> searchCourses(String query) async {
    try {
      final url = Uri.parse(ApiConstants.courseSearch).replace(
        queryParameters: {'q': query},
      );
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((courseJson) => Course.fromJson(courseJson))
              .toList();
        } else if (data is List) {
          return data.map((courseJson) => Course.fromJson(courseJson)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
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

      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((categoryJson) => CourseCategory.fromJson(categoryJson))
              .toList();
        } else if (data is List) {
          return data.map((categoryJson) => CourseCategory.fromJson(categoryJson)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }


  Future<void> updateVideoProgress({
    required int videoLessonId,
    required int courseId,
    required double completedPercentage,
    required bool completed,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.progress);
      
      final body = jsonEncode({
        'video_lesson_id': videoLessonId,
        'course_id': courseId,
        'completed_percentage': completedPercentage,
        'completed': completed,
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to update video progress: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating video progress: $e');
    }
  }

  Future<List<Course>> getEnrolledCourses() async {
    try {
      final url = Uri.parse(ApiConstants.enrolledCourses);
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> courseList;
        if (data is Map && data.containsKey('results')) {
          courseList = data['results'];
        } else if (data is List) {
          courseList = data;
        } else {
          return [];
        }
        
        
        // Now fetch detailed information for each course
        List<Course> detailedCourses = [];
        for (var courseData in courseList) {
          final courseId = courseData['id'];
          try {
            
            // Try regular course detail API
            Course? detailedCourse = await getCourseDetail(courseId);
            
            if (detailedCourse != null) {
              detailedCourses.add(detailedCourse);
            } else {
              // Fallback to basic course data if detail fetch fails
              detailedCourses.add(Course.fromJson(courseData));
            }
          } catch (e) {
            // Fallback to basic course data
            detailedCourses.add(Course.fromJson(courseData));
          }
        }
        
        return detailedCourses;
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch enrolled courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching enrolled courses: $e');
    }
  }
}