class Enrollment {
  final int id;
  final int courseId;
  final String courseName;
  final String? courseImage;
  final DateTime enrolledAt;
  final String status;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final List<PaymentRecord> payments;
  final List<Installment>? installments;
  final List<dynamic>? courseModules; // Store raw module data from API

  Enrollment({
    required this.id,
    required this.courseId,
    required this.courseName,
    this.courseImage,
    required this.enrolledAt,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.payments,
    this.installments,
    this.courseModules,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      courseId: json['course_id'] ?? json['course']?['id'],
      courseName: json['course_name'] ?? json['course']?['title'] ?? json['title'] ?? '',
      courseImage: json['course_image'] ?? json['course']?['image'] ?? json['thumbnail_url'] ?? json['thumbnail'],
      enrolledAt: DateTime.parse(json['enrolled_at'] ?? json['created_at']),
      status: json['status'] ?? 'active',
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      paidAmount: double.parse(json['paid_amount']?.toString() ?? '0'),
      remainingAmount: double.parse(json['remaining_amount']?.toString() ?? '0'),
      paymentStatus: json['payment_status'] ?? 'pending',
      payments: (json['payments'] as List<dynamic>? ?? [])
          .map((payment) => PaymentRecord.fromJson(payment))
          .toList(),
      installments: json['installments'] != null
          ? (json['installments'] as List<dynamic>)
              .map((installment) => Installment.fromJson(installment))
              .toList()
          : null,
      courseModules: json['modules'] ?? json['course']?['modules'], // Extract modules if present
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'course_image': courseImage,
      'enrolled_at': enrolledAt.toIso8601String(),
      'status': status,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'payment_status': paymentStatus,
      'payments': payments.map((p) => p.toJson()).toList(),
      'installments': installments?.map((i) => i.toJson()).toList(),
      'course_modules': courseModules,
    };
  }
}

class PaymentRecord {
  final int id;
  final int enrollmentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final String? notes;

  PaymentRecord({
    required this.id,
    required this.enrollmentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.notes,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'],
      enrollmentId: json['enrollment_id'] ?? json['enrollment'],
      amount: double.parse(json['amount']?.toString() ?? '0'),
      paymentDate: DateTime.parse(json['payment_date'] ?? json['created_at']),
      paymentMethod: json['payment_method'] ?? 'unknown',
      status: json['status'] ?? 'pending',
      transactionId: json['transaction_id'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_id': enrollmentId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'notes': notes,
    };
  }
}

class Installment {
  final int id;
  final int enrollmentId;
  final double amount;
  final DateTime dueDate;
  final String status;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? transactionId;

  Installment({
    required this.id,
    required this.enrollmentId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: json['id'] ?? 0,
      enrollmentId: json['enrollment_id'] ?? json['enrollment'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      dueDate: json['due_date'] != null 
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      status: json['status'] ?? 'pending',
      paidDate: json['status']?.toString().toLowerCase() == 'completed' && json['payment_date'] != null
          ? DateTime.parse(json['payment_date']) 
          : (json['paid_date'] != null 
              ? DateTime.parse(json['paid_date'])
              : null),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enrollment_id': enrollmentId,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'paid_date': paidDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
    };
  }
}

class CoursePricing {
  final int id;
  final String title;
  final String basePrice;
  final String taxRate;
  final String taxAmount;
  final String totalAmount;
  final bool isFree;
  final bool allowPublicEnrollment;

  CoursePricing({
    required this.id,
    required this.title,
    required this.basePrice,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.isFree,
    required this.allowPublicEnrollment,
  });

  factory CoursePricing.fromJson(Map<String, dynamic> json) {
    return CoursePricing(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      basePrice: json['base_price']?.toString() ?? '0',
      taxRate: json['tax_rate']?.toString() ?? '0',
      taxAmount: json['tax_amount']?.toString() ?? '0',
      totalAmount: json['total_amount']?.toString() ?? '0',
      isFree: json['is_free'] ?? false,
      allowPublicEnrollment: json['allow_public_enrollment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'base_price': basePrice,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'is_free': isFree,
      'allow_public_enrollment': allowPublicEnrollment,
    };
  }

  // Helper methods
  double get totalAmountAsDouble {
    return double.tryParse(totalAmount) ?? 0.0;
  }

  double get baseAmountAsDouble {
    return double.tryParse(basePrice) ?? 0.0;
  }

  double get taxAmountAsDouble {
    return double.tryParse(taxAmount) ?? 0.0;
  }
}

class InstallmentPlan {
  final int id;
  final String name;
  final int numberOfInstallments;
  final double installmentAmount;
  final int intervalDays;

  InstallmentPlan({
    required this.id,
    required this.name,
    required this.numberOfInstallments,
    required this.installmentAmount,
    required this.intervalDays,
  });

  factory InstallmentPlan.fromJson(Map<String, dynamic> json) {
    return InstallmentPlan(
      id: json['id'],
      name: json['name'],
      numberOfInstallments: json['number_of_installments'],
      installmentAmount: double.parse(json['installment_amount']?.toString() ?? '0'),
      intervalDays: json['interval_days'],
    );
  }
}