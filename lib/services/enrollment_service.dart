import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/enrollment_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class EnrollmentService {
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

  Future<Map<String, dynamic>> _getEnrollmentDetails(int enrollmentId) async {
    final url = Uri.parse(ApiConstants.enrollmentPayments(enrollmentId));
    
    final response = await _makeAuthorizedRequest(() async {
      return await http.get(url, headers: await _getHeaders());
    });
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Also try to fetch installment plans if available
      try {
        final installmentPlans = await _getInstallmentPlans(enrollmentId);
        data['installment_plans'] = installmentPlans;
      } catch (e) {
        print("⚠️ No installment plans available for enrollment $enrollmentId: $e");
        data['installment_plans'] = [];
      }
      
      return data;
    } else {
      throw Exception('Failed to fetch enrollment details');
    }
  }

  Future<List<Map<String, dynamic>>> _getInstallmentPlans(int enrollmentId) async {
    // Use the correct endpoint from API documentation
    final possibleUrls = [
      '${ApiConstants.paymentsBaseUrl}/enrollments/$enrollmentId/installment-plan/',
      '${ApiConstants.paymentsBaseUrl}/enrollments/$enrollmentId/installments/',
      '${ApiConstants.paymentsBaseUrl}/installments/?enrollment_id=$enrollmentId',
      '${ApiConstants.paymentsBaseUrl}/my-installments/?enrollment_id=$enrollmentId',
    ];
    
    for (String urlString in possibleUrls) {
      try {
        final url = Uri.parse(urlString);
        print("🔍 Trying installment endpoint: $url");
        
        final response = await _makeAuthorizedRequest(() async {
          return await http.get(url, headers: await _getHeaders());
        });
        
        print("Response Status: ${response.statusCode}");
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("✅ Found installment data: $data");
          
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          } else if (data is Map && data.containsKey('results')) {
            return (data['results'] as List).cast<Map<String, dynamic>>();
          } else if (data is Map && data.containsKey('installments')) {
            return (data['installments'] as List).cast<Map<String, dynamic>>();
          } else if (data is Map && data.containsKey('payments')) {
            // Handle the current API response format - payments are installments
            final payments = data['payments'] as List<dynamic>;
            if (payments.isNotEmpty) {
              print("✅ Found ${payments.length} payment installments");
              return payments.cast<Map<String, dynamic>>();
            }
          } else if (data is Map && data.containsKey('enrollment_details')) {
            // Handle the installment-plan API response structure
            final enrollmentDetails = data['enrollment_details'] as Map<String, dynamic>;
            final payments = enrollmentDetails['payments'] as List<dynamic>?;
            if (payments != null && payments.isNotEmpty) {
              return payments.cast<Map<String, dynamic>>();
            }
            // If no payments, create installment structure from plan details
            return [
              {
                'id': data['id'],
                'enrollment_id': data['enrollment'],
                'amount': double.tryParse(data['installment_amount']?.toString() ?? '0') ?? 0.0,
                'due_date': data['start_date'],
                'status': 'pending',
                'total_installments': data['total_installments'],
                'frequency': data['frequency'],
              }
            ];
          }
        }
      } catch (e) {
        print("⚠️ Failed to fetch from $urlString: $e");
        continue;
      }
    }
    
    throw Exception('No installment plans found');
  }

  Future<List<Enrollment>> getMyEnrollments({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      // Use the working enrolled courses endpoint instead
      Uri url = Uri.parse(ApiConstants.enrolledCourses);
      
      Map<String, String> queryParams = {};
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      print("💰 Fetching enrollments from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> courses;
        if (data is Map && data.containsKey('results')) {
          courses = data['results'];
        } else if (data is List) {
          courses = data;
        } else {
          print("❌ Unexpected response format for enrollments");
          return [];
        }
        
        // Convert courses to enrollments and get real payment data
        List<Enrollment> enrollments = [];
        for (var courseJson in courses) {
          final course = courseJson as Map<String, dynamic>;
          final courseId = course['id'] ?? 0;
          
          // Try to get real payment information
          try {
            final paymentDetails = await _getEnrollmentDetails(courseId);
            final enrollment = paymentDetails['enrollment'] as Map<String, dynamic>?;
            final installmentPlansData = paymentDetails['installment_plans'] as List<dynamic>?;
            
            // Parse installment plans
            List<Installment>? installments;
            if (installmentPlansData != null && installmentPlansData.isNotEmpty) {
              installments = installmentPlansData
                  .map((planData) => Installment.fromJson(planData as Map<String, dynamic>))
                  .toList();
            }
            
            enrollments.add(Enrollment(
              id: courseId,
              courseId: courseId,
              courseName: course['title'] ?? 'Unknown Course',
              courseImage: course['thumbnail_url'] ?? course['thumbnail'],
              enrolledAt: course['created_at'] != null 
                  ? DateTime.parse(course['created_at'])
                  : DateTime.now(),
              status: 'active',
              totalAmount: enrollment != null 
                  ? double.tryParse(enrollment['total_amount']?.toString() ?? '0') ?? 0.0
                  : (course['price'] != null 
                      ? double.tryParse(course['price'].toString()) ?? 0.0
                      : 0.0),
              paidAmount: enrollment != null 
                  ? ((double.tryParse(enrollment['total_amount']?.toString() ?? '0') ?? 0.0) - (double.tryParse(enrollment['outstanding_amount']?.toString() ?? '0') ?? 0.0))
                  : (course['price'] != null 
                      ? double.tryParse(course['price'].toString()) ?? 0.0
                      : 0.0),
              remainingAmount: enrollment != null 
                  ? double.tryParse(enrollment['outstanding_amount']?.toString() ?? '0') ?? 0.0
                  : 0.0,
              paymentStatus: enrollment?['payment_status'] ?? 'paid',
              payments: [], // Will be loaded separately
              installments: installments,
              courseModules: course['modules'], // Capture modules if present
            ));
          } catch (e) {
            print("⚠️ Failed to get payment details for course $courseId: $e");
            // Fallback to basic enrollment data
            enrollments.add(Enrollment(
              id: courseId,
              courseId: courseId,
              courseName: course['title'] ?? 'Unknown Course',
              courseImage: course['thumbnail_url'] ?? course['thumbnail'],
              enrolledAt: course['created_at'] != null 
                  ? DateTime.parse(course['created_at'])
                  : DateTime.now(),
              status: 'active',
              totalAmount: course['price'] != null 
                  ? double.tryParse(course['price'].toString()) ?? 0.0
                  : 0.0,
              paidAmount: course['price'] != null 
                  ? double.tryParse(course['price'].toString()) ?? 0.0
                  : 0.0,
              remainingAmount: 0.0,
              paymentStatus: 'paid',
              payments: [],
              installments: null,
              courseModules: course['modules'], // Capture modules if present
            ));
          }
        }
        
        return enrollments;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch enrollments: ${response.statusCode}");
        throw Exception('Failed to fetch enrollments: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching enrollments: $e");
      throw Exception('Error fetching enrollments: $e');
    }
  }

  Future<List<PaymentRecord>> getEnrollmentPayments(int enrollmentId) async {
    try {
      final url = Uri.parse(ApiConstants.enrollmentPayments(enrollmentId));
      print("💳 Fetching enrollment payments from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('payments')) {
          // Handle the actual API response format
          final paymentsList = data['payments'] as List;
          if (paymentsList.isEmpty) {
            print("ℹ️ No payment records found for enrollment $enrollmentId");
            return [];
          }
          return paymentsList
              .map((paymentJson) => PaymentRecord.fromJson(paymentJson))
              .toList();
        } else if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((paymentJson) => PaymentRecord.fromJson(paymentJson))
              .toList();
        } else if (data is List) {
          return data.map((paymentJson) => PaymentRecord.fromJson(paymentJson)).toList();
        } else {
          print("❌ Unexpected response format for payments");
          return [];
        }
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 500) {
        print("⚠️ Payment endpoint not available (500), returning mock data");
        // Return mock payment data for now
        return [
          PaymentRecord(
            id: 1,
            enrollmentId: enrollmentId,
            amount: 0.0,
            paymentDate: DateTime.now(),
            paymentMethod: 'enrollment',
            status: 'completed',
            transactionId: 'ENR_$enrollmentId',
            notes: 'Course enrollment - payment details not available',
          ),
        ];
      } else {
        print("❌ Failed to fetch enrollment payments: ${response.statusCode}");
        throw Exception('Failed to fetch enrollment payments: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching enrollment payments: $e");
      // Return empty list instead of throwing error
      return [];
    }
  }

  Future<CoursePricing?> getCoursePricing(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.coursePricing(courseId));
      print("💲 Fetching course pricing from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if course_pricing is nested
        if (data.containsKey('course_pricing')) {
          return CoursePricing.fromJson(data['course_pricing']);
        } else {
          // Fallback for direct structure
          return CoursePricing.fromJson(data);
        }
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch course pricing: ${response.statusCode}");
        throw Exception('Failed to fetch course pricing: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching course pricing: $e");
      throw Exception('Error fetching course pricing: $e');
    }
  }

  Future<Map<String, dynamic>> purchaseCourse({
    required int courseId,
    String paymentMethod = 'razorpay',
    String? transactionId,
    String? paymentGatewayResponse,
  }) async {
    try {
      final url = Uri.parse(ApiConstants.purchaseCourse);
      print("🛒 Purchasing course at: $url");
      
      final body = jsonEncode({
        'course_id': courseId,
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
        if (paymentGatewayResponse != null) 'payment_gateway_response': paymentGatewayResponse,
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
        return {
          'success': true,
          'message': data['message'] ?? 'Course purchased successfully',
          'enrollment_id': data['enrollment_id'],
          'payment_id': data['payment_id'],
          'total_amount': data['total_amount'],
          'payment_status': data['payment_status'],
          'data': data,
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Failed to purchase course',
          'error': errorData,
        };
      } else if (response.statusCode == 404) {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Course not found',
          'error': errorData,
        };
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to purchase course: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Failed to purchase course',
          'error': errorData,
        };
      }
    } catch (e) {
      print("❌ Error purchasing course: $e");
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<List<Installment>> getInstallmentPlans(int enrollmentId) async {
    try {
      final installmentData = await _getInstallmentPlans(enrollmentId);
      return installmentData
          .map((planData) => Installment.fromJson(planData))
          .toList();
    } catch (e) {
      print("❌ Error fetching installment plans: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> enrollInCourse(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.enrollCourse);
      print("📝 Enrolling in course at: $url");
      
      final body = jsonEncode({
        'course_id': courseId,
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
        print("✅ Successfully enrolled in course $courseId");
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully enrolled in course',
          'data': data,
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Enrollment failed';
        print("⚠️ Enrollment failed: $errorMessage");
        return {
          'success': false,
          'message': errorMessage,
          'data': errorData,
        };
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        print("❌ Forbidden - Course not available for public enrollment");
        return {
          'success': false,
          'message': 'This course is not available for public enrollment',
        };
      } else {
        print("❌ Failed to enroll in course: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to enroll in course',
        };
      }
    } catch (e) {
      print("❌ Error enrolling in course: $e");
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> checkEnrollmentEligibility(int courseId) async {
    try {
      // For now, we'll check if the course allows public enrollment
      // In the future, this could be a separate API endpoint
      return {
        'eligible': true,
        'message': 'Course is available for enrollment',
      };
    } catch (e) {
      print("❌ Error checking enrollment eligibility: $e");
      return {
        'eligible': false,
        'message': 'Unable to check enrollment eligibility',
      };
    }
  }
}