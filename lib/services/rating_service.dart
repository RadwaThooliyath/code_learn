import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/rating_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class RatingService {
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

  /// Get rating statistics for a course
  Future<RatingStats> getCourseRatingStats(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.courseRatingStats(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RatingStats.fromJson(data);
      } else {
        throw Exception('Failed to fetch rating stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rating stats: $e');
    }
  }

  /// Get user's rating status for a course
  Future<UserRatingStatus> getUserRatingStatus(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.userRatingStatus(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("🔍 DEBUG: User rating status response:");
      print("🔍 Status Code: ${response.statusCode}");
      print("🔍 Response Body: ${response.body}");
      print("🔍 Request URL: $url");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Parsed rating status data: $data");
        return UserRatingStatus.fromJson(data);
      } else {
        throw Exception('Failed to fetch user rating status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user rating status: $e');
    }
  }

  /// Get all ratings for a course
  Future<List<CourseRating>> getCourseRatings(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.courseRatings(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> ratingsList;
        if (data is Map && data.containsKey('results')) {
          ratingsList = data['results'];
        } else if (data is List) {
          ratingsList = data;
        } else {
          return [];
        }
        
        return ratingsList.map((r) => CourseRating.fromJson(r)).toList();
      } else {
        throw Exception('Failed to fetch course ratings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course ratings: $e');
    }
  }

  /// Submit or update a course rating
  Future<CourseRating> submitCourseRating({
    required int courseId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.courseRatings(courseId));
      
      final body = jsonEncode({
        'course': courseId,
        'rating': rating,
        'review_text': reviewText ?? '',
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("🔍 DEBUG: Rating submission response:");
      print("🔍 Status Code: ${response.statusCode}");
      print("🔍 Response Headers: ${response.headers}");
      print("🔍 Response Body: ${response.body}");
      print("🔍 Request URL: $url");
      print("🔍 Request Body: $body");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CourseRating.fromJson(data);
      } else {
        print("❌ Rating submission failed with status ${response.statusCode}");
        try {
          final errorData = jsonDecode(response.body);
          print("❌ Error response data: $errorData");
          throw Exception(errorData['error'] ?? 'Failed to submit rating');
        } catch (jsonError) {
          print("❌ Failed to parse error response as JSON: $jsonError");
          throw Exception('Failed to submit rating: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Error submitting rating: $e');
    }
  }

  /// Update user's existing rating
  Future<CourseRating> updateCourseRating({
    required int courseId,
    required int rating,
    String? reviewText,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.userCourseRating(courseId));
      
      final body = jsonEncode({
        'course': courseId,
        'rating': rating,
        'review_text': reviewText ?? '',
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.put(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CourseRating.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update rating');
      }
    } catch (e) {
      throw Exception('Error updating rating: $e');
    }
  }

  /// Delete user's rating
  Future<bool> deleteCourseRating(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.userCourseRating(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.delete(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete rating: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting rating: $e');
    }
  }

  /// Get all reviews for a course
  Future<List<CourseReview>> getCourseReviews(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.courseReviews(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> reviewsList;
        if (data is Map && data.containsKey('results')) {
          reviewsList = data['results'];
        } else if (data is List) {
          reviewsList = data;
        } else {
          return [];
        }
        
        return reviewsList.map((r) => CourseReview.fromJson(r)).toList();
      } else {
        throw Exception('Failed to fetch course reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course reviews: $e');
    }
  }

  /// Submit a detailed review
  Future<CourseReview> submitCourseReview({
    required int courseId,
    required String title,
    required String content,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.courseReviews(courseId));
      
      final body = jsonEncode({
        'title': title,
        'content': content,
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
        return CourseReview.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to submit review');
      }
    } catch (e) {
      throw Exception('Error submitting review: $e');
    }
  }

  /// Toggle helpful vote for a review
  Future<Map<String, dynamic>> toggleReviewHelpful(int reviewId) async {
    try {
      final url = Uri.parse(ApiConstants.toggleReviewHelpful(reviewId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'is_helpful': data['is_helpful'],
          'helpful_count': data['helpful_count'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to toggle helpful vote');
      }
    } catch (e) {
      throw Exception('Error toggling helpful vote: $e');
    }
  }
}