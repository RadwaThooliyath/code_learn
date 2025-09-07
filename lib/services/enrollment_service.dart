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
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        response = await request();
      } else {
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
    ];
    
    for (String urlString in possibleUrls) {
      try {
        final url = Uri.parse(urlString);
        
        final response = await _makeAuthorizedRequest(() async {
          return await http.get(url, headers: await _getHeaders());
        });
        
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
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
      // Use the correct payment endpoint for enrollments
      Uri url = Uri.parse('${ApiConstants.paymentsBaseUrl}/my-enrollments/');
      
      Map<String, String> queryParams = {};
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
        
        List<dynamic> enrollmentList;
        if (data is Map && data.containsKey('results')) {
          enrollmentList = data['results'];
        } else if (data is List) {
          enrollmentList = data;
        } else {
          return [];
        }
        
        // Convert API response to Enrollment objects
        List<Enrollment> enrollments = [];
        for (var enrollmentJson in enrollmentList) {
          final enrollmentData = enrollmentJson as Map<String, dynamic>;
          
          // Parse enrollment data from the payment API response
          final enrollmentId = enrollmentData['id'] ?? 0;
          final courseId = enrollmentData['course'] ?? 0;
          final courseName = enrollmentData['course_title'] ?? 'Unknown Course';
          final courseImage = null; // Not provided in this API response
          final installmentPlan = enrollmentData['installment_plan'] as Map<String, dynamic>?;
          
          // Extract payment information directly from enrollment data
          final totalAmount = double.tryParse(enrollmentData['total_amount']?.toString() ?? '0') ?? 0.0;
          final outstandingAmount = double.tryParse(enrollmentData['outstanding_amount']?.toString() ?? '0') ?? 0.0;
          final paidAmount = double.tryParse(enrollmentData['paid_amount']?.toString() ?? '0') ?? 0.0;
          final paymentStatus = enrollmentData['payment_status'] ?? 'unknown';
          
          // Debug payment calculations
          
          // Determine correct payment status based on amounts
          String finalPaymentStatus;
          if (outstandingAmount <= 0 && totalAmount > 0) {
            finalPaymentStatus = 'completed';
          } else if (paidAmount > 0 && outstandingAmount > 0) {
            finalPaymentStatus = 'partial';
          } else if (paidAmount <= 0 && totalAmount > 0) {
            finalPaymentStatus = 'pending';
          } else {
            finalPaymentStatus = paymentStatus;
          }
          
          // Create installment data from API response if available
          List<Installment>? installments;
          if (installmentPlan != null && enrollmentData['has_installment_plan'] == true) {
            try {
              // Create installment objects from the plan data
              final totalInstallments = installmentPlan['total_installments'] ?? 1;
              final installmentAmount = installmentPlan['installment_amount']?.toDouble() ?? 0.0;
              final remainingInstallments = installmentPlan['remaining_installments'] ?? 0;
              final nextDueDate = installmentPlan['next_due_date'];
              
              installments = [];
              
              // Create paid installments
              final paidInstallments = totalInstallments - remainingInstallments;
              for (int i = 1; i <= paidInstallments; i++) {
                final daysDiff = ((paidInstallments - i + 1) * 30).toInt();
                installments.add(Installment(
                  id: i,
                  enrollmentId: enrollmentId,
                  amount: installmentAmount,
                  dueDate: DateTime.now().subtract(Duration(days: daysDiff)),
                  status: 'paid',
                  paidDate: DateTime.now().subtract(Duration(days: daysDiff)),
                  transactionId: null,
                ));
              }
              
              // Create remaining installments
              for (int i = paidInstallments + 1; i <= totalInstallments; i++) {
                final daysOffset = ((i - paidInstallments - 1) * 30).toInt();
                final futureDays = ((i - paidInstallments) * 30).toInt();
                final dueDate = nextDueDate != null 
                    ? DateTime.parse(nextDueDate).add(Duration(days: daysOffset))
                    : DateTime.now().add(Duration(days: futureDays));
                    
                installments.add(Installment(
                  id: i,
                  enrollmentId: enrollmentId,
                  amount: installmentAmount,
                  dueDate: dueDate,
                  status: 'pending',
                  transactionId: null,
                ));
              }
              
            } catch (e) {
            }
          }
          
          enrollments.add(Enrollment(
            id: enrollmentId,
            courseId: courseId,
            courseName: courseName,
            courseImage: courseImage,
            enrolledAt: enrollmentData['enrolled_on'] != null 
                ? DateTime.parse(enrollmentData['enrolled_on'])
                : DateTime.now(),
            status: enrollmentData['active'] == true ? 'active' : 'inactive',
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            remainingAmount: outstandingAmount,
            paymentStatus: finalPaymentStatus,
            payments: [], // Will be loaded separately if needed
            installments: installments,
            courseModules: null, // Not provided in payment API
          ));
        }
        
        return enrollments;
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch enrollments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching enrollments: $e');
    }
  }

  Future<List<PaymentRecord>> getEnrollmentPayments(int enrollmentId) async {
    try {
      final url = Uri.parse('${ApiConstants.paymentsBaseUrl}/enrollments/$enrollmentId/payments/');
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map && data.containsKey('payments')) {
          // Handle the actual API response format
          final paymentsList = data['payments'] as List;
          if (paymentsList.isEmpty) {
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
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 500) {
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
        throw Exception('Failed to fetch enrollment payments: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list instead of throwing error
      return [];
    }
  }

  Future<CoursePricing?> getCoursePricing(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.coursePricing(courseId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
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
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch course pricing: ${response.statusCode}');
      }
    } catch (e) {
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
      
      final body = jsonEncode({
        'course_id': courseId,
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
        if (paymentGatewayResponse != null) 'payment_gateway_response': paymentGatewayResponse,
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
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
        throw Exception('User not authenticated');
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['error'] ?? 'Failed to purchase course',
          'error': errorData,
        };
      }
    } catch (e) {
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
      return [];
    }
  }

  Future<Map<String, dynamic>> enrollInCourse(int courseId) async {
    try {
      final url = Uri.parse(ApiConstants.enrollCourse);
      
      final body = jsonEncode({
        'course_id': courseId,
        'payment_method': 'other', // Default payment method for free courses
      });
      
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Successfully enrolled in course',
          'data': data,
        };
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Enrollment failed';
        return {
          'success': false,
          'message': errorMessage,
          'data': errorData,
        };
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'This course is not available for public enrollment',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to enroll in course',
        };
      }
    } catch (e) {
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
      return {
        'eligible': false,
        'message': 'Unable to check enrollment eligibility',
      };
    }
  }
}