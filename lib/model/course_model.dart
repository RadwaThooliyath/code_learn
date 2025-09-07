class Course {
  final int id;
  final String title;
  final String description;
  final String? curriculum;
  final String? whatYouWillLearn;
  final String? thumbnail;
  final String? thumbnailUrl;
  final bool isFree;
  final double? price;
  final double? taxRate;
  final String? priceDisplay;
  final String? totalPriceDisplay;
  final String? category;
  final CourseCategory? categoryObject;
  final String? instructor;
  final String? createdByName;
  final int? duration;
  final String? level;
  final double? rating;
  final int? enrolledCount;
  final String? previewVideo;
  final String? previewVideoUrl;
  final bool? isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Module>? modules;
  final bool? isEnrolled;
  final EnrollmentInfo? enrollmentInfo;
  final int? moduleCount;
  final int? totalLessons;
  final bool? allowPublicEnrollment;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.curriculum,
    this.whatYouWillLearn,
    this.thumbnail,
    this.thumbnailUrl,
    required this.isFree,
    this.price,
    this.taxRate,
    this.priceDisplay,
    this.totalPriceDisplay,
    this.category,
    this.categoryObject,
    this.instructor,
    this.createdByName,
    this.duration,
    this.level,
    this.rating,
    this.enrolledCount,
    this.previewVideo,
    this.previewVideoUrl,
    this.isPublished,
    this.createdAt,
    this.updatedAt,
    this.modules,
    this.isEnrolled,
    this.enrollmentInfo,
    this.moduleCount,
    this.totalLessons,
    this.allowPublicEnrollment,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      curriculum: json['curriculum'],
      whatYouWillLearn: json['what_you_will_learn'],
      thumbnail: json['thumbnail'],
      thumbnailUrl: json['thumbnail_url'],
      isFree: json['is_free_course'] == 'true' || json['is_free_course'] == true || json['is_free'] == true,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      taxRate: json['tax_rate'] != null ? double.tryParse(json['tax_rate'].toString()) : null,
      priceDisplay: json['price_display'],
      totalPriceDisplay: json['total_price_display'],
      category: json['category_name'] ?? (json['category'] is Map ? json['category']['name'] : json['category']),
      categoryObject: json['category'] is Map ? CourseCategory.fromJson(json['category']) : null,
      instructor: json['instructor'],
      createdByName: json['created_by_name'],
      duration: json['duration'],
      level: json['level'],
      rating: json['rating']?.toDouble(),
      enrolledCount: json['enrolled_count'],
      previewVideo: json['preview_video'],
      previewVideoUrl: json['preview_video_url'],
      isPublished: json['is_published'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      modules: json['modules'] != null
          ? (json['modules'] as List)
              .map((module) => Module.fromJson(module))
              .toList()
          : null,
      isEnrolled: json['is_enrolled'],
      enrollmentInfo: json['enrollment_info'] != null 
          ? EnrollmentInfo.fromJson(json['enrollment_info'])
          : null,
      moduleCount: json['module_count'],
      totalLessons: json['total_lessons'],
      allowPublicEnrollment: json['allow_public_enrollment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'curriculum': curriculum,
      'what_you_will_learn': whatYouWillLearn,
      'thumbnail': thumbnail,
      'is_free': isFree,
      'price': price,
      'tax_rate': taxRate,
      'category': category,
      'instructor': instructor,
      'created_by_name': createdByName,
      'duration': duration,
      'level': level,
      'rating': rating,
      'enrolled_count': enrolledCount,
      'is_published': isPublished,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'modules': modules?.map((module) => module.toJson()).toList(),
      'is_enrolled': isEnrolled,
      'enrollment_info': enrollmentInfo?.toJson(),
      'module_count': moduleCount,
      'total_lessons': totalLessons,
      'allow_public_enrollment': allowPublicEnrollment,
    };
  }
}

class Module {
  final int id;
  final String title;
  final String? description;
  final int order;
  final int? lessonCount;
  final List<Lesson>? lessons;
  final List<dynamic>? videoLessons;
  final List<dynamic>? assignments;
  final List<dynamic>? quizzes;
  final ModuleProgress? progress;
  final String? learningObjectives;
  final int? durationMinutes;
  final String? difficultyLevel;
  final String? prerequisites;
  final String? resources;

  Module({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.lessonCount,
    this.lessons,
    this.videoLessons,
    this.assignments,
    this.quizzes,
    this.progress,
    this.learningObjectives,
    this.durationMinutes,
    this.difficultyLevel,
    this.prerequisites,
    this.resources,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    // Parse lessons from both 'lessons' and 'video_lessons' fields
    List<Lesson> allLessons = [];
    
    // Add regular lessons if they exist
    if (json['lessons'] != null) {
      allLessons.addAll(
        (json['lessons'] as List)
            .map((lesson) => Lesson.fromJson(lesson))
            .toList()
      );
    }
    
    // Add video lessons if they exist, converting them to Lesson objects
    if (json['video_lessons'] != null) {
      allLessons.addAll(
        (json['video_lessons'] as List)
            .map((videoLesson) => Lesson.fromVideoLessonJson(videoLesson))
            .toList()
      );
    }
    
    return Module(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      order: json['order'] ?? 0,
      lessonCount: json['lesson_count'],
      lessons: allLessons.isNotEmpty ? allLessons : null,
      videoLessons: json['video_lessons'], // Keep raw data for backward compatibility
      assignments: json['assignments'],
      quizzes: json['quizzes'],
      progress: json['progress'] != null ? ModuleProgress.fromJson(json['progress']) : null,
      learningObjectives: json['learning_objectives'],
      durationMinutes: json['duration_minutes'],
      difficultyLevel: json['difficulty_level'],
      prerequisites: json['prerequisites'],
      resources: json['resources'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons?.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

class Lesson {
  final int id;
  final String title;
  final String? description;
  final String type;
  final String? content;
  final String? videoUrl;
  final int order;
  final int? duration;
  final bool? isCompleted;
  final double? completedPercentage;
  final DateTime? lastWatchedAt;
  final StudentProgress? progress;
  final String? resourceFileUrl;

  Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.content,
    this.videoUrl,
    required this.order,
    this.duration,
    this.isCompleted,
    this.completedPercentage,
    this.lastWatchedAt,
    this.progress,
    this.resourceFileUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'text',
      content: json['content'],
      videoUrl: json['video_url'],
      order: json['order'] ?? 0,
      duration: json['duration'],
      isCompleted: json['is_completed'],
      completedPercentage: json['completed_percentage']?.toDouble(),
      lastWatchedAt: json['last_watched_at'] != null ? DateTime.parse(json['last_watched_at']) : null,
      progress: json['progress'] != null ? StudentProgress.fromJson(json['progress']) : null,
      resourceFileUrl: json['resource_file_url'],
    );
  }

  factory Lesson.fromVideoLessonJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      type: 'video', // Video lessons are always video type
      content: json['description'], // Use description as content
      videoUrl: json['youtube_url'] ?? json['video_url'], // API uses youtube_url
      order: json['order'] ?? 0,
      duration: json['duration'],
      isCompleted: json['is_completed'] ?? false,
      completedPercentage: json['completed_percentage']?.toDouble(),
      lastWatchedAt: json['last_watched_at'] != null ? DateTime.parse(json['last_watched_at']) : null,
      progress: json['progress'] != null ? StudentProgress.fromJson(json['progress']) : null,
      resourceFileUrl: json['resource_file_url'], // Django API provides resource_file_url
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'content': content,
      'video_url': videoUrl,
      'order': order,
      'duration': duration,
      'is_completed': isCompleted,
      'completed_percentage': completedPercentage,
      'last_watched_at': lastWatchedAt?.toIso8601String(),
      'progress': progress?.toJson(),
    };
  }
}

class CourseCategory {
  final int id;
  final String name;
  final String? description;
  final int courseCount;

  CourseCategory({
    required this.id,
    required this.name,
    this.description,
    required this.courseCount,
  });

  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      courseCount: json['course_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'course_count': courseCount,
    };
  }
}

class EnrollmentInfo {
  final DateTime? enrolledOn;
  final String? paymentStatus;
  final double? totalAmount;
  final double? outstandingAmount;

  EnrollmentInfo({
    this.enrolledOn,
    this.paymentStatus,
    this.totalAmount,
    this.outstandingAmount,
  });

  factory EnrollmentInfo.fromJson(Map<String, dynamic> json) {
    return EnrollmentInfo(
      enrolledOn: json['enrolled_on'] != null
          ? DateTime.parse(json['enrolled_on'])
          : null,
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : null,
      outstandingAmount: json['outstanding_amount'] != null
          ? double.tryParse(json['outstanding_amount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrolled_on': enrolledOn?.toIso8601String(),
      'payment_status': paymentStatus,
      'total_amount': totalAmount,
      'outstanding_amount': outstandingAmount,
    };
  }
}

class ModuleProgress {
  final bool? isUnlocked;
  final bool? isCompleted;
  final double? completionPercentage;
  final int? videosCompleted;
  final int? assignmentsCompleted;
  final int? quizzesPassed;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;

  ModuleProgress({
    this.isUnlocked,
    this.isCompleted,
    this.completionPercentage,
    this.videosCompleted,
    this.assignmentsCompleted,
    this.quizzesPassed,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory ModuleProgress.fromJson(Map<String, dynamic> json) {
    return ModuleProgress(
      isUnlocked: json['is_unlocked'],
      isCompleted: json['is_completed'],
      completionPercentage: json['completion_percentage']?.toDouble(),
      videosCompleted: json['videos_completed'],
      assignmentsCompleted: json['assignments_completed'],
      quizzesPassed: json['quizzes_passed'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_unlocked': isUnlocked,
      'is_completed': isCompleted,
      'completion_percentage': completionPercentage,
      'videos_completed': videosCompleted,
      'assignments_completed': assignmentsCompleted,
      'quizzes_passed': quizzesPassed,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'status': status,
    };
  }
}

class StudentProgress {
  final int id;
  final int userId;
  final int courseId;
  final int videoLessonId;
  final double completedPercentage;
  final DateTime lastWatchedAt;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentProgress({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.videoLessonId,
    required this.completedPercentage,
    required this.lastWatchedAt,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      id: json['id'],
      userId: json['user'] ?? json['user_id'],
      courseId: json['course'] ?? json['course_id'],
      videoLessonId: json['video_lesson'] ?? json['video_lesson_id'],
      completedPercentage: json['completed_percentage']?.toDouble() ?? 0.0,
      lastWatchedAt: DateTime.parse(json['last_watched_at']),
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'video_lesson_id': videoLessonId,
      'completed_percentage': completedPercentage,
      'last_watched_at': lastWatchedAt.toIso8601String(),
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}