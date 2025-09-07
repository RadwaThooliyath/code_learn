import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/model/enrollment_model.dart';
import 'package:uptrail/services/payment_service.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/view/widgets/authenticated_image.dart';

class CheckoutSummaryPage extends StatefulWidget {
  final Course course;
  final CoursePricing pricing;
  final String userEmail;
  final String userPhone;

  const CheckoutSummaryPage({
    super.key,
    required this.course,
    required this.pricing,
    required this.userEmail,
    required this.userPhone,
  });

  @override
  State<CheckoutSummaryPage> createState() => _CheckoutSummaryPageState();
}

class _CheckoutSummaryPageState extends State<CheckoutSummaryPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessingPayment = false;
  String? _selectedPaymentMethod = 'UPI';
  
  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'UPI', 'name': 'UPI (GPay, PhonePe, Paytm)', 'icon': Icons.payment, 'recommended': true},
    {'id': 'CARD', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card, 'recommended': false},
    {'id': 'NETBANKING', 'name': 'Net Banking', 'icon': Icons.account_balance, 'recommended': false},
    {'id': 'WALLET', 'name': 'Digital Wallets', 'icon': Icons.account_balance_wallet, 'recommended': false},
  ];

  @override
  void initState() {
    super.initState();
    _paymentService.initialize();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _proceedToPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final result = await _paymentService.initiateCoursePayment(
        context: context,
        course: widget.course,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
      );

      if (result['success']) {
        // Payment successful, navigate back with success
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else {
        // Payment failed, show error
        _showPaymentResult(false, result['message'] ?? 'Payment failed');
      }
    } catch (e) {
      _showPaymentResult(false, 'An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showPaymentResult(bool success, String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: TextStyle(
                color: success ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(success ? {'success': true, 'message': message} : null); // Close checkout
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
       backgroundColor: AppColors.background,
        elevation: 1,
        leading: IconButton(
          onPressed: _isProcessingPayment ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Checkout Summary',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Details Card
              _buildCourseDetailsCard(),
              
              AppSpacing.large,
              
              // Price Breakdown Card
              _buildPriceBreakdownCard(),
              
              AppSpacing.large,
              
              // Payment Methods Card
              _buildPaymentMethodsCard(),
              
              AppSpacing.large,
              
              // Security Info
              _buildSecurityInfo(),
              
              AppSpacing.veryLarge,
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPaymentBar(),
    );
  }

  Widget _buildCourseDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.school,
                  color: AppColors.logoBrightBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Course Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            
            AppSpacing.small,
            
            Row(
              children: [
                // Course thumbnail
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: widget.course.thumbnailUrl != null && widget.course.thumbnailUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AuthenticatedImage(
                            imageUrl: widget.course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            loadingWidget: (context) => Container(
                              color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                              child: const Icon(Icons.school, color: AppColors.logoBrightBlue),
                            ),
                            errorWidget: (context, error) => Container(
                              color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                              child: const Icon(Icons.school, color: AppColors.logoBrightBlue),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.logoBrightBlue.withValues(alpha: 0.2),
                                AppColors.logoBrightBlue.withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: const Icon(Icons.school, color: AppColors.logoBrightBlue),
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      if (widget.course.instructor != null)
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.course.instructor!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          if (widget.course.rating != null) ...[
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.course.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Icon(Icons.people, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.course.enrolledCount ?? 0} students',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppColors.logoBrightBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Price Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            
            AppSpacing.small,
            
            // Course Price
            _buildPriceRow(
              'Course Fee',
              '₹${widget.pricing.baseAmountAsDouble.toStringAsFixed(2)}',
              false,
            ),
            
            AppSpacing.verySmall,
            
            // Tax
            _buildPriceRow(
              'Tax (${widget.pricing.taxRate}%)',
              '₹${widget.pricing.taxAmountAsDouble.toStringAsFixed(2)}',
              false,
            ),
            
            AppSpacing.small,
            
            const Divider(),
            
            AppSpacing.verySmall,
            
            // Total
            _buildPriceRow(
              'Total Amount',
              '₹${widget.pricing.totalAmountAsDouble.toStringAsFixed(2)}',
              true,
            ),
            
            AppSpacing.small,
            
            // Savings badge (if applicable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Lifetime Access Included',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.black54,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.logoBrightBlue : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.payment,
                  color: AppColors.logoBrightBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            
            AppSpacing.small,
            
            ...(_paymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method['id'];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: _isProcessingPayment ? null : () {
                    setState(() {
                      _selectedPaymentMethod = method['id'];
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.logoBrightBlue : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected ? AppColors.logoBrightBlue.withValues(alpha: 0.05) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          method['icon'],
                          color: isSelected ? AppColors.logoBrightBlue : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            method['name'],
                            style: TextStyle(
                              color: isSelected ? AppColors.logoBrightBlue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (method['recommended']) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Radio<String>(
                          value: method['id'],
                          groupValue: _selectedPaymentMethod,
                          onChanged: _isProcessingPayment ? null : (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          activeColor: AppColors.logoBrightBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your payment is secured by Razorpay with bank-level security',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaymentBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${widget.pricing.totalAmountAsDouble.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.logoBrightBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isProcessingPayment ? null : _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoBrightBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isProcessingPayment
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Processing...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.security, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              'Pay Securely',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}