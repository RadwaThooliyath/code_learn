import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/services/storage_service.dart';

class ContentServiceException implements Exception {
  final String message;
  final int? statusCode;
  
  ContentServiceException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}

class ContentService {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<T> _makeRequest<T>(
    String url, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(url);
      final finalUri = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      print('ContentService: Making request to $finalUri');

      final response = await http.get(
        finalUri,
        headers: await _getHeaders(),
      ).timeout(_timeout);

      print('ContentService: Response status ${response.statusCode}');
      print('ContentService: Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle both custom API format (with success field) and Django REST framework format
        if (responseBody['success'] == true || !responseBody.containsKey('success')) {
          if (fromJson != null) {
            return fromJson(responseBody);
          }
          return responseBody as T;
        } else {
          final error = responseBody['error']?['message'] ?? 'Unknown error occurred';
          print('ContentService: API Error: $error');
          throw ContentServiceException(error, statusCode: response.statusCode);
        }
      } else {
        final errorMessage = responseBody['error']?['message'] ?? 
            'Request failed with status ${response.statusCode}';
        print('ContentService: HTTP Error: $errorMessage');
        throw ContentServiceException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      print('ContentService: Exception caught: $e');
      if (e is ContentServiceException) {
        rethrow;
      }
      throw ContentServiceException('Network error: ${e.toString()}');
    }
  }

  static Future<DashboardData> getDashboardData() async {
    return await _makeRequest<DashboardData>(
      ApiConstants.contentDashboard,
      fromJson: (json) => DashboardData.fromJson(json),
    );
  }

  static Future<PaginatedResponse<NewsArticle>> getNews({
    int page = 1,
    String? category,
    String? search,
    bool? featured,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      if (featured != null) 'featured': featured.toString(),
    };

    return await _makeRequest<PaginatedResponse<NewsArticle>>(
      ApiConstants.contentNews,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (item) => NewsArticle.fromJson(item),
      ),
    );
  }

  static Future<NewsArticle> getNewsDetail(String slug) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      ApiConstants.newsDetail(slug),
    );
    // Handle both wrapped and direct responses
    final data = response['data'] ?? response;
    return NewsArticle.fromJson(data);
  }

  static Future<PaginatedResponse<Placement>> getPlacements({
    int page = 1,
    String? placementType,
    String? course,
    bool? featured,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (placementType != null) 'placement_type': placementType,
      if (course != null) 'course': course,
      if (featured != null) 'is_featured': featured.toString(),
      if (search != null) 'search': search,
    };

    return await _makeRequest<PaginatedResponse<Placement>>(
      ApiConstants.contentPlacements,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (item) => Placement.fromJson(item),
      ),
    );
  }

  static Future<Placement> getPlacementDetail(int id) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      ApiConstants.placementDetail(id),
    );
    // Handle both wrapped and direct responses
    final data = response['data'] ?? response;
    return Placement.fromJson(data);
  }

  static Future<PaginatedResponse<Testimonial>> getTestimonials({
    int page = 1,
    String? testimonialType,
    String? course,
    int? rating,
    bool? featured,
    String? search,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (testimonialType != null) 'testimonial_type': testimonialType,
      if (course != null) 'course': course,
      if (rating != null) 'overall_rating': rating.toString(),
      if (featured != null) 'is_featured': featured.toString(),
      if (search != null) 'search': search,
    };

    return await _makeRequest<PaginatedResponse<Testimonial>>(
      ApiConstants.contentTestimonials,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(
        json,
        (item) => Testimonial.fromJson(item),
      ),
    );
  }

  static Future<Testimonial> getTestimonialDetail(int id) async {
    final response = await _makeRequest<Map<String, dynamic>>(
      ApiConstants.testimonialDetail(id),
    );
    // Handle both wrapped and direct responses
    final data = response['data'] ?? response;
    return Testimonial.fromJson(data);
  }

  static Future<Map<String, dynamic>> likeTestimonial(int id) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.testimonialLike(id)),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          return responseBody['data'];
        } else {
          throw ContentServiceException(
            responseBody['error']?['message'] ?? 'Failed to like testimonial',
            statusCode: response.statusCode,
          );
        }
      } else {
        final errorMessage = responseBody['error']?['message'] ?? 
            'Failed to like testimonial with status ${response.statusCode}';
        throw ContentServiceException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ContentServiceException) {
        rethrow;
      }
      throw ContentServiceException('Network error: ${e.toString()}');
    }
  }

  static Future<LeadSubmissionResponse> submitLead(LeadSubmission lead) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.contentLeadSubmission),
        headers: await _getHeaders(),
        body: jsonEncode(lead.toJson()),
      ).timeout(_timeout);

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle both new API format (without success field) and old format (with success field)
        if (responseBody['success'] == true || !responseBody.containsKey('success')) {
          return LeadSubmissionResponse.fromJson(responseBody);
        } else {
          throw ContentServiceException(
            responseBody['error']?['message'] ?? 'Lead submission failed',
            statusCode: response.statusCode,
          );
        }
      } else {
        // Handle validation errors (like duplicate email)
        if (response.statusCode == 400 && responseBody is Map) {
          // Check for field-specific errors
          String errorMessage = 'Lead submission failed';
          
          if (responseBody.containsKey('email') && responseBody['email'] is List) {
            errorMessage = responseBody['email'][0].toString();
          } else if (responseBody.containsKey('phone') && responseBody['phone'] is List) {
            errorMessage = responseBody['phone'][0].toString();
          } else if (responseBody.containsKey('error') && responseBody['error']['message'] != null) {
            errorMessage = responseBody['error']['message'];
          } else if (responseBody.containsKey('detail')) {
            errorMessage = responseBody['detail'];
          }
          
          throw ContentServiceException(
            errorMessage,
            statusCode: response.statusCode,
          );
        }
        
        final errorMessage = responseBody['error']?['message'] ?? 
            'Lead submission failed with status ${response.statusCode}';
        throw ContentServiceException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ContentServiceException) {
        rethrow;
      }
      throw ContentServiceException('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> searchContent({
    required String query,
    String? type,
    int limit = 5,
  }) async {
    final queryParams = <String, String>{
      'q': query,
      'limit': limit.toString(),
      if (type != null) 'type': type,
    };

    return await _makeRequest<Map<String, dynamic>>(
      ApiConstants.contentSearch,
      queryParams: queryParams,
    );
  }

  static Future<ContentCategories> getCategories() async {
    return await _makeRequest<ContentCategories>(
      ApiConstants.contentCategories,
      fromJson: (json) => ContentCategories.fromJson(json),
    );
  }

  static Future<List<UserLead>> getMyLeads() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.contentMyLeads),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      print('ContentService: My leads response status ${response.statusCode}');
      print('ContentService: My leads response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle both paginated and direct list responses
        final List<dynamic> leadsData;
        if (responseBody is Map && responseBody.containsKey('results')) {
          leadsData = responseBody['results'];
        } else if (responseBody is List) {
          leadsData = responseBody;
        } else {
          throw ContentServiceException('Invalid response format for my leads');
        }

        return leadsData.map((leadJson) {
          print('ContentService: Parsing lead JSON: $leadJson');
          try {
            return UserLead.fromJson(leadJson);
          } catch (e) {
            print('ContentService: Error parsing lead JSON: $e');
            print('ContentService: Problematic JSON: $leadJson');
            rethrow;
          }
        }).toList();
      } else {
        final errorMessage = responseBody['error']?['message'] ?? 
            responseBody['detail'] ?? 
            'Failed to fetch leads with status ${response.statusCode}';
        print('ContentService: My leads error: $errorMessage');
        throw ContentServiceException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      print('ContentService: Exception in getMyLeads: $e');
      if (e is ContentServiceException) {
        rethrow;
      }
      throw ContentServiceException('Network error: ${e.toString()}');
    }
  }

  static Future<UserLead> getMyLeadDetail(int leadId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.myLeadDetail(leadId)),
        headers: await _getHeaders(),
      ).timeout(_timeout);

      print('ContentService: Lead detail response status ${response.statusCode}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle both wrapped and direct responses
        final data = responseBody['data'] ?? responseBody;
        return UserLead.fromJson(data);
      } else {
        final errorMessage = responseBody['error']?['message'] ?? 
            responseBody['detail'] ?? 
            'Failed to fetch lead detail with status ${response.statusCode}';
        throw ContentServiceException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ContentServiceException) {
        rethrow;
      }
      throw ContentServiceException('Network error: ${e.toString()}');
    }
  }
}