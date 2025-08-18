class Course {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;
  final String? thumbnailUrl;
  final bool isFree;
  final double? price;
  final String? priceDisplay;
  final String? totalPriceDisplay;
  final String? category;
  final CourseCategory? categoryObject;
  final String? instructor;
  final int? duration;
  final String? level;
  final double? rating;
  final int? enrolledCount;
  final String? previewVideo;
  final String? previewVideoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Module>? modules;
  final bool? isEnrolled;
  final int? moduleCount;
  final int? totalLessons;
  final bool? allowPublicEnrollment;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.thumbnailUrl,
    required this.isFree,
    this.price,
    this.priceDisplay,
    this.totalPriceDisplay,
    this.category,
    this.categoryObject,
    this.instructor,
    this.duration,
    this.level,
    this.rating,
    this.enrolledCount,
    this.previewVideo,
    this.previewVideoUrl,
    this.createdAt,
    this.updatedAt,
    this.modules,
    this.isEnrolled,
    this.moduleCount,
    this.totalLessons,
    this.allowPublicEnrollment,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'],
      thumbnailUrl: () {
        final url = json['thumbnail_url'];
        print("🔍 Course ${json['title']}: thumbnail_url = $url");
        return url;
      }(),
      isFree: json['is_free_course'] == 'true' || json['is_free_course'] == true || json['is_free'] == true,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      priceDisplay: json['price_display'],
      totalPriceDisplay: json['total_price_display'],
      category: json['category_name'] ?? (json['category'] is Map ? json['category']['name'] : json['category']),
      categoryObject: json['category'] is Map ? CourseCategory.fromJson(json['category']) : null,
      instructor: json['instructor'],
      duration: json['duration'],
      level: json['level'],
      rating: json['rating']?.toDouble(),
      enrolledCount: json['enrolled_count'],
      previewVideo: json['preview_video'],
      previewVideoUrl: json['preview_video_url'],
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
      'thumbnail': thumbnail,
      'is_free': isFree,
      'price': price,
      'category': category,
      'instructor': instructor,
      'duration': duration,
      'level': level,
      'rating': rating,
      'enrolled_count': enrolledCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'modules': modules?.map((module) => module.toJson()).toList(),
      'is_enrolled': isEnrolled,
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

  Module({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.lessonCount,
    this.lessons,
    this.videoLessons,
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
      isCompleted: false, // Default to not completed
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