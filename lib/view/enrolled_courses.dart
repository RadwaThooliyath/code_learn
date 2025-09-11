import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/enrollment_model.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/enrollment_detail.dart';

class EnrolledCoursesPage extends StatefulWidget {
  const EnrolledCoursesPage({super.key});

  @override
  State<EnrolledCoursesPage> createState() => _EnrolledCoursesPageState();
}

class _EnrolledCoursesPageState extends State<EnrolledCoursesPage> {
  final EnrollmentService _enrollmentService = EnrollmentService();
  List<Enrollment> _enrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final enrollments = await _enrollmentService.getMyEnrollments(
        ordering: '-enrolled_at',
      );

      setState(() {
        _enrollments = enrollments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Payment Overview", style: AppTextStyle.headline2),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEnrollments,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEnrollments,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.logoBrightBlue,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading enrollments",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEnrollments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              "No enrolled courses yet",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Start learning by enrolling in a course!",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _enrollments.length,
      itemBuilder: (context, index) {
        return _buildEnrollmentCard(_enrollments[index], index);
      },
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment, int index) {
    final paymentPercentage = enrollment.totalAmount > 0 
        ? (enrollment.paidAmount / enrollment.totalAmount * 100).toInt()
        : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnrollmentDetailPage(enrollment: enrollment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header with Payment Badge
              Row(
                children: [

                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          enrollment.courseName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Enrolled: ${_formatDate(enrollment.enrolledAt)}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusBgColor(enrollment.paymentStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${paymentPercentage}% Paid",
                      style: TextStyle(
                        color: _getPaymentStatusColor(enrollment.paymentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Payment Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentSummaryCard(
                      "Total Amount",
                      "₹${enrollment.totalAmount.toStringAsFixed(0)}",
                      Icons.account_balance_wallet_outlined,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentSummaryCard(
                      "Amount Paid",
                      "₹${enrollment.paidAmount.toStringAsFixed(0)}",
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              
              if (enrollment.remainingAmount > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPaymentSummaryCard(
                        "Remaining",
                        "₹${enrollment.remainingAmount.toStringAsFixed(0)}",
                        Icons.schedule_outlined,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPaymentSummaryCard(
                        "Status",
                        enrollment.paymentStatus.toUpperCase(),
                        Icons.info_outline,
                        _getPaymentStatusColor(enrollment.paymentStatus),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Payment Progress",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${paymentPercentage}% Complete",
                        style: TextStyle(
                          color: AppColors.green1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: enrollment.totalAmount > 0 
                              ? enrollment.paidAmount / enrollment.totalAmount 
                              : 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.green1,
                                  AppColors.green1.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color textColor) {
    Color chipColor;
    Color chipTextColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        chipColor =AppColors.brightPinkCrayola;
        chipTextColor = Colors.white;
        break;
      case 'completed':
        chipColor = Colors.blue.withOpacity(0.2);
        chipTextColor = Colors.blue;
        break;
      case 'suspended':
        chipColor = Colors.orange.withOpacity(0.2);
        chipTextColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.2);
        chipTextColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: chipTextColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPaymentStatusBgColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green.withValues(alpha: 0.1);
      case 'pending':
        return Colors.orange.withValues(alpha: 0.1);
      case 'failed':
        return Colors.red.withValues(alpha: 0.1);
      case 'partial':
        return Colors.blue.withValues(alpha: 0.1);
      default:
        return Colors.grey.withValues(alpha: 0.1);
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}