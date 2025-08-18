class Assignment {
  final int id;
  final String title;
  final String description;
  final String requirements;
  final String resources;
  final int maxPoints;
  final int passingScore;
  final int dueDays;
  final bool isRequired;
  final int order;
  final String moduleTitle;
  final String courseTitle;
  final String submissionStatus;
  final Map<String, dynamic>? userSubmission;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.resources,
    required this.maxPoints,
    required this.passingScore,
    required this.dueDays,
    required this.isRequired,
    required this.order,
    required this.moduleTitle,
    required this.courseTitle,
    required this.submissionStatus,
    this.userSubmission,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      resources: json['resources'] ?? '',
      maxPoints: json['max_points'] ?? 0,
      passingScore: json['passing_score'] ?? 0,
      dueDays: json['due_days'] ?? 0,
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      moduleTitle: json['module_title'] ?? '',
      courseTitle: json['course_title'] ?? '',
      submissionStatus: json['submission_status'] ?? 'not_submitted',
      userSubmission: json['user_submission'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'resources': resources,
      'max_points': maxPoints,
      'passing_score': passingScore,
      'due_days': dueDays,
      'is_required': isRequired,
      'order': order,
      'module_title': moduleTitle,
      'course_title': courseTitle,
      'submission_status': submissionStatus,
      'user_submission': userSubmission,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AssignmentSubmission {
  final int id;
  final int assignment;
  final String assignmentTitle;
  final String studentName;
  final String githubUrl;
  final String submissionNotes;
  final String status;
  final int? score;
  final String? gradeComments;
  final int? gradedBy;
  final double scorePercentage;
  final bool isPassed;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final DateTime createdAt;

  AssignmentSubmission({
    required this.id,
    required this.assignment,
    required this.assignmentTitle,
    required this.studentName,
    required this.githubUrl,
    required this.submissionNotes,
    required this.status,
    this.score,
    this.gradeComments,
    this.gradedBy,
    required this.scorePercentage,
    required this.isPassed,
    this.submittedAt,
    this.gradedAt,
    required this.createdAt,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'],
      assignment: json['assignment'],
      assignmentTitle: json['assignment_title'] ?? '',
      studentName: json['student_name'] ?? '',
      githubUrl: json['github_url'] ?? '',
      submissionNotes: json['submission_notes'] ?? '',
      status: json['status'] ?? 'draft',
      score: json['score'],
      gradeComments: json['grade_comments'],
      gradedBy: json['graded_by'],
      scorePercentage: (json['score_percentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['is_passed'] ?? false,
      submittedAt: json['submitted_at'] != null 
          ? DateTime.parse(json['submitted_at']) 
          : null,
      gradedAt: json['graded_at'] != null 
          ? DateTime.parse(json['graded_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment': assignment,
      'assignment_title': assignmentTitle,
      'student_name': studentName,
      'github_url': githubUrl,
      'submission_notes': submissionNotes,
      'status': status,
      'score': score,
      'grade_comments': gradeComments,
      'graded_by': gradedBy,
      'score_percentage': scorePercentage,
      'is_passed': isPassed,
      'submitted_at': submittedAt?.toIso8601String(),
      'graded_at': gradedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}