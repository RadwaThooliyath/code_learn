import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/enrollment_model.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/utils/app_text_style.dart';

class EnrollmentDetailPage extends StatefulWidget {
  final Enrollment enrollment;

  const EnrollmentDetailPage({
    super.key,
    required this.enrollment,
  });

  @override
  State<EnrollmentDetailPage> createState() => _EnrollmentDetailPageState();
}

class _EnrollmentDetailPageState extends State<EnrollmentDetailPage>
    with SingleTickerProviderStateMixin {
  final EnrollmentService _enrollmentService = EnrollmentService();
  List<PaymentRecord> _paymentRecords = [];
  bool _isLoading = false;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPaymentRecords();
    _loadInstallmentPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final payments = await _enrollmentService.getEnrollmentPayments(
        widget.enrollment.id,
      );

      setState(() {
        _paymentRecords = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInstallmentPlans() async {
    try {
      final installments = await _enrollmentService.getInstallmentPlans(
        widget.enrollment.id,
      );
      
      if (installments.isNotEmpty) {
        setState(() {
          // Update the enrollment object with the loaded installments
          widget.enrollment.installments?.clear();
          widget.enrollment.installments?.addAll(installments);
        });
      }
    } catch (e) {
      print("⚠️ Failed to load installment plans: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.enrollment.courseName,
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentRecords,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.logoBrightBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline),
              text: "Overview",
            ),
            Tab(
              icon: Icon(Icons.payment),
              text: "Payments",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPaymentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseInfo(),
          const SizedBox(height: 24),
          _buildPaymentSummary(),
          const SizedBox(height: 24),
          if (widget.enrollment.installments != null &&
              widget.enrollment.installments!.isNotEmpty)
            _buildInstallmentOverview(),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
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
              "Error loading payments",
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
              onPressed: _loadPaymentRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_paymentRecords.isEmpty && widget.enrollment.payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              "No payment records found",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    final allPayments = _paymentRecords.isNotEmpty 
        ? _paymentRecords 
        : widget.enrollment.payments;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPayments.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(allPayments[index]);
      },
    );
  }

  Widget _buildCourseInfo() {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.enrollment.courseImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.enrollment.courseImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.book,
                            size: 40,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.book,
                      size: 40,
                      color: Colors.black54,
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.enrollment.courseName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Enrolled: ${_formatDate(widget.enrollment.enrolledAt)}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(widget.enrollment.status),
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

  Widget _buildPaymentSummary() {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Summary",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  "\$${widget.enrollment.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Paid Amount:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  "\$${widget.enrollment.paidAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.enrollment.remainingAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Remaining:",
                    style: TextStyle(   color: Colors.black,),
                  ),
                  Text(
                    "\$${widget.enrollment.remainingAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.enrollment.totalAmount > 0
                  ? widget.enrollment.paidAmount / widget.enrollment.totalAmount
                  : 0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.enrollment.remainingAmount <= 0
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Payment Status:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  widget.enrollment.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(widget.enrollment.paymentStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentOverview() {
    final installments = widget.enrollment.installments!;
    
    return Card(
      color: AppColors.card1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Installment Plan",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...installments.map((installment) => _buildInstallmentItem(installment)),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentItem(Installment installment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getInstallmentStatusColor(installment.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Due: ${_formatDate(installment.dueDate)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "\$${installment.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  installment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getInstallmentStatusColor(installment.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment) {
    return Card(
      color: AppColors.champagnePink,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${payment.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(payment.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(payment.paymentDate),
                  style: const TextStyle(color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  payment.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 4),
              Text(
                "Transaction: ${payment.transactionId}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
            if (payment.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                payment.notes!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Text(
      status.toUpperCase(),
      style: TextStyle(
        color: _getEnrollmentStatusColor(status),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getEnrollmentStatusColor(String status) {

    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.black;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.black;
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

  Color _getInstallmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}