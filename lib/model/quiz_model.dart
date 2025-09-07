class Quiz {
  final int id;
  final String title;
  final String description;
  final int maxPoints;
  final int passingScore;
  final int timeLimit; // in minutes
  final bool isRequired;
  final int order;
  final String moduleTitle;
  final String courseTitle;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final int maxAttempts;
  final bool showResultsImmediately;
  final bool randomizeQuestions;
  final int totalQuestions;
  final int userAttempts;
  final bool canAttempt;
  final int? bestScore;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.maxPoints,
    required this.passingScore,
    required this.timeLimit,
    required this.isRequired,
    required this.order,
    required this.moduleTitle,
    required this.courseTitle,
    required this.questions,
    required this.createdAt,
    required this.maxAttempts,
    required this.showResultsImmediately,
    required this.randomizeQuestions,
    required this.totalQuestions,
    required this.userAttempts,
    required this.canAttempt,
    this.bestScore,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: _parseIntSafe(json['id']) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      maxPoints: _parseIntSafe(json['total_points']) ?? 0,
      passingScore: _parseIntSafe(json['passing_score']) ?? 0,
      timeLimit: _parseIntSafe(json['time_limit']) ?? 0,
      isRequired: json['is_required'] ?? false,
      order: _parseIntSafe(json['order']) ?? 0,
      moduleTitle: json['module_title'] ?? '',
      courseTitle: json['course_title'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      maxAttempts: _parseIntSafe(json['max_attempts']) ?? 1,
      showResultsImmediately: json['show_results_immediately'] ?? true,
      randomizeQuestions: json['randomize_questions'] ?? false,
      totalQuestions: _parseIntSafe(json['total_questions']) ?? 0,
      userAttempts: _parseIntSafe(json['user_attempts']) ?? 0,
      canAttempt: json['can_attempt'] ?? true,
      bestScore: _parseIntSafe(json['best_score']),
    );
  }

  // Helper method to safely parse integers from various numeric types
  static int? _parseIntSafe(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'max_points': maxPoints,
      'passing_score': passingScore,
      'time_limit': timeLimit,
      'is_required': isRequired,
      'order': order,
      'module_title': moduleTitle,
      'course_title': courseTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'max_attempts': maxAttempts,
      'show_results_immediately': showResultsImmediately,
      'randomize_questions': randomizeQuestions,
      'total_questions': totalQuestions,
      'user_attempts': userAttempts,
      'can_attempt': canAttempt,
      'best_score': bestScore,
    };
  }
}

class QuizQuestion {
  final int id;
  final String questionText;
  final String questionType; // multiple_choice, true_false, short_answer
  final int points;
  final List<QuizChoice> choices;
  final int order;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.choices,
    required this.order,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: Quiz._parseIntSafe(json['id']) ?? 0,
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'multiple_choice',
      points: Quiz._parseIntSafe(json['points']) ?? 1,
      choices: json['choices'] != null
          ? (json['choices'] as List)
              .map((c) => QuizChoice.fromJson(c))
              .toList()
          : [],
      order: Quiz._parseIntSafe(json['order']) ?? 0,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'question_type': questionType,
      'points': points,
      'choices': choices.map((c) => c.toJson()).toList(),
      'order': order,
      'explanation': explanation,
    };
  }
}

class QuizChoice {
  final int id;
  final String choiceText;
  final bool isCorrect;
  final int order;

  QuizChoice({
    required this.id,
    required this.choiceText,
    required this.isCorrect,
    required this.order,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: Quiz._parseIntSafe(json['id']) ?? 0,
      choiceText: json['choice_text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      order: Quiz._parseIntSafe(json['order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'choice_text': choiceText,
      'is_correct': isCorrect,
      'order': order,
    };
  }
}

class QuizAttempt {
  final int id;
  final int quiz;
  final String quizTitle;
  final String studentName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? score;
  final String scorePercentage;
  final String status; // in_progress, completed, expired
  final String isPassed;
  final int timeSpent; // in seconds
  final DateTime createdAt;
  final int attemptNumber;

  QuizAttempt({
    required this.id,
    required this.quiz,
    required this.quizTitle,
    required this.studentName,
    required this.startedAt,
    this.completedAt,
    this.score,
    required this.scorePercentage,
    required this.status,
    required this.isPassed,
    required this.timeSpent,
    required this.createdAt,
    required this.attemptNumber,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: Quiz._parseIntSafe(json['id']) ?? 0,
      quiz: Quiz._parseIntSafe(json['quiz']) ?? 0,
      quizTitle: json['quiz_title'] ?? '',
      studentName: json['student_name'] ?? '',
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      score: Quiz._parseIntSafe(json['score']),
      scorePercentage: json['score_percentage']?.toString() ?? '0',
      status: json['completed'] == true ? 'completed' : 'in_progress',
      isPassed: json['is_passed']?.toString() ?? 'false',
      timeSpent: Quiz._parseIntSafe(json['time_taken']) ?? 0,
      createdAt: DateTime.tryParse(json['started_at']?.toString() ?? '') ?? DateTime.now(),
      attemptNumber: Quiz._parseIntSafe(json['attempt_number']) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz': quiz,
      'quiz_title': quizTitle,
      'student_name': studentName,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'score': score,
      'score_percentage': scorePercentage,
      'status': status,
      'is_passed': isPassed,
      'time_spent': timeSpent,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class QuizAnswer {
  final int question;
  final int? selectedChoice;
  final String? textAnswer;

  QuizAnswer({
    required this.question,
    this.selectedChoice,
    this.textAnswer,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'selected_choice': selectedChoice,
      'text_answer': textAnswer,
    };
  }
}