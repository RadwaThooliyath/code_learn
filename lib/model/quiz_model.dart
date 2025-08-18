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
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      maxPoints: json['total_points'] != null ? int.tryParse(json['total_points'].toString()) ?? 0 : 0,
      passingScore: json['passing_score'] ?? 0,
      timeLimit: json['time_limit'] ?? 0,
      isRequired: json['is_required'] ?? false,
      order: json['order'] ?? 0,
      moduleTitle: json['module_title'] ?? '',
      courseTitle: json['course_title'] ?? '',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
      maxAttempts: json['max_attempts'] ?? 1,
      showResultsImmediately: json['show_results_immediately'] ?? true,
    );
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

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.points,
    required this.choices,
    required this.order,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      questionText: json['question_text'] ?? '',
      questionType: json['question_type'] ?? 'multiple_choice',
      points: json['points'] ?? 1,
      choices: json['choices'] != null
          ? (json['choices'] as List)
              .map((c) => QuizChoice.fromJson(c))
              .toList()
          : [],
      order: json['order'] ?? 0,
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
    };
  }
}

class QuizChoice {
  final int id;
  final String choiceText;
  final bool isCorrect;

  QuizChoice({
    required this.id,
    required this.choiceText,
    required this.isCorrect,
  });

  factory QuizChoice.fromJson(Map<String, dynamic> json) {
    return QuizChoice(
      id: json['id'],
      choiceText: json['choice_text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'choice_text': choiceText,
      'is_correct': isCorrect,
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
      id: json['id'],
      quiz: json['quiz'],
      quizTitle: json['quiz_title'] ?? '',
      studentName: json['student_name'] ?? '',
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      score: json['score'],
      scorePercentage: json['score_percentage']?.toString() ?? '0',
      status: json['completed'] == true ? 'completed' : 'in_progress',
      isPassed: json['is_passed']?.toString() ?? 'false',
      timeSpent: json['time_taken'] ?? 0,
      createdAt: DateTime.parse(json['started_at']),
      attemptNumber: json['attempt_number'] ?? 1,
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