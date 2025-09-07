import 'dart:async';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:uptrail/app_constants/payment_constants.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/enrollment_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late Razorpay _razorpay;
  final EnrollmentService _enrollmentService = EnrollmentService();
  
  // Callbacks for payment events
  void Function(PaymentSuccessResponse)? _onPaymentSuccess;
  void Function(PaymentFailureResponse)? _onPaymentError;
  void Function(ExternalWalletResponse)? _onExternalWallet;

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<Map<String, dynamic>> initiateCoursePayment({
    required BuildContext context,
    required Course course,
    required String userEmail,
    required String userPhone,
  }) async {
    try {
      // Validate Razorpay key configuration
      if (!PaymentConstants.isKeyConfigured) {
        return {
          'success': false,
          'message': PaymentConstants.keyStatus,
        };
      }
      
      // First get course pricing
      final pricing = await _enrollmentService.getCoursePricing(course.id);
      if (pricing == null) {
        return {
          'success': false,
          'message': 'Unable to fetch course pricing',
        };
      }


      // Check if course is free
      if (pricing.isFree) {
        // Handle free enrollment directly
        return await _enrollmentService.enrollInCourse(course.id);
      }

      // Calculate amount in paise
      final amountInPaise = (pricing.totalAmountAsDouble * 100).toInt();

      // Setup payment options for Razorpay
      var options = <String, dynamic>{
        'key': PaymentConstants.razorpayKeyId,
        'amount': amountInPaise,
        'name': PaymentConstants.companyName,
        'description': 'Payment for ${course.title}',
        'currency': 'INR',
        'timeout': 300,
        'retry': <String, dynamic>{
          'enabled': true, 
          'max_count': 1
        },
        'send_sms_hash': true,
        'prefill': <String, dynamic>{
          'contact': userPhone,
          'email': userEmail,
        },
        'external': <String, dynamic>{
          'wallets': ['paytm', 'phonepe', 'googlepay']
        },
        'theme': <String, dynamic>{
          'color': '#3399cc'
        }
      };


      // Return a Future that completes when payment is done
      return await _processPayment(options, course.id);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to initiate payment: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> _processPayment(Map<String, dynamic> options, int courseId) async {
    // Create a completer to handle the async payment flow
    final completer = Completer<Map<String, dynamic>>();

    // Set up callbacks
    _onPaymentSuccess = (PaymentSuccessResponse response) async {
      
      try {
        // Complete the purchase on the backend
        final result = await _enrollmentService.purchaseCourse(
          courseId: courseId,
          paymentMethod: 'razorpay',
          transactionId: response.paymentId,
          paymentGatewayResponse: response.toString(),
        );
        
        completer.complete(result);
      } catch (e) {
        completer.complete({
          'success': false,
          'message': 'Payment successful but enrollment failed: ${e.toString()}',
        });
      }
    };

    _onPaymentError = (PaymentFailureResponse response) {
      completer.complete({
        'success': false,
        'message': 'Payment failed: ${response.message}',
        'error_code': response.code,
      });
    };

    _onExternalWallet = (ExternalWalletResponse response) {
      // Handle external wallet if needed
    };

    // Open Razorpay checkout
    try {
      _razorpay.open(options);
    } catch (e) {
      completer.complete({
        'success': false,
        'message': 'Failed to open payment gateway: ${e.toString()}',
      });
    }

    return completer.future;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onPaymentSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onPaymentError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onExternalWallet?.call(response);
  }

  // Helper method to format amount for display
  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Method to get payment methods supported
  List<String> getSupportedPaymentMethods() {
    return [
      'Credit Card',
      'Debit Card',
      'Net Banking',
      'UPI',
      'Wallets (Paytm, PhonePe, etc.)',
    ];
  }
}

