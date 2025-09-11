class NewsArticle {
  final int id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String category;
  final String categoryDisplay;
  final String? featuredImage;
  final String? thumbnail;
  final bool isFeatured;
  final int viewCount;
  final DateTime publishedAt;
  final String createdBy;
  final String? tags;
  final String? metaTitle;
  final String? metaDescription;

  NewsArticle({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.categoryDisplay,
    this.featuredImage,
    this.thumbnail,
    required this.isFeatured,
    required this.viewCount,
    required this.publishedAt,
    required this.createdBy,
    this.tags,
    this.metaTitle,
    this.metaDescription,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      excerpt: json['excerpt'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      categoryDisplay: json['category_display'] ?? json['category'] ?? '',
      featuredImage: json['featured_image'],
      thumbnail: json['thumbnail'],
      isFeatured: json['is_featured'] ?? false,
      viewCount: json['view_count'] ?? 0,
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
      createdBy: json['created_by'] ?? '',
      tags: json['tags'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'category': category,
      'category_display': categoryDisplay,
      'featured_image': featuredImage,
      'thumbnail': thumbnail,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'published_at': publishedAt.toIso8601String(),
      'created_by': createdBy,
      'tags': tags,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
    };
  }
}

class Placement {
  final int id;
  final String studentName;
  final String companyName;
  final String? companyLogo;
  final String jobTitle;
  final String? location;
  final String courseCompleted;
  final String? batchYear;
  final String placementType;
  final String placementTypeDisplay;
  final double? packageAmount;
  final String? packageCurrency;
  final bool canShowPackage;
  final String? studentPhoto;
  final String? successStory;
  final String? keySkillsGained;
  final bool isFeatured;
  final DateTime? placementDate;
  final DateTime publishedAt;

  Placement({
    required this.id,
    required this.studentName,
    required this.companyName,
    this.companyLogo,
    required this.jobTitle,
    this.location,
    required this.courseCompleted,
    this.batchYear,
    required this.placementType,
    required this.placementTypeDisplay,
    this.packageAmount,
    this.packageCurrency,
    required this.canShowPackage,
    this.studentPhoto,
    this.successStory,
    this.keySkillsGained,
    required this.isFeatured,
    this.placementDate,
    required this.publishedAt,
  });

  factory Placement.fromJson(Map<String, dynamic> json) {
    return Placement(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      companyName: json['company_name'] ?? '',
      companyLogo: json['company_logo'],
      jobTitle: json['job_title'] ?? '',
      location: json['location'],
      courseCompleted: json['course_completed'] ?? '',
      batchYear: json['batch_year'],
      placementType: json['placement_type'] ?? '',
      placementTypeDisplay: json['placement_type_display'] ?? json['placement_type'] ?? '',
      packageAmount: json['package_amount']?.toDouble(),
      packageCurrency: json['package_currency'],
      canShowPackage: json['can_show_package'] ?? false,
      studentPhoto: json['student_photo'],
      successStory: json['success_story'],
      keySkillsGained: json['key_skills_gained'],
      isFeatured: json['is_featured'] ?? false,
      placementDate: json['placement_date'] != null ? DateTime.parse(json['placement_date']) : null,
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'company_name': companyName,
      'company_logo': companyLogo,
      'job_title': jobTitle,
      'location': location,
      'course_completed': courseCompleted,
      'batch_year': batchYear,
      'placement_type': placementType,
      'placement_type_display': placementTypeDisplay,
      'package_amount': packageAmount,
      'package_currency': packageCurrency,
      'can_show_package': canShowPackage,
      'student_photo': studentPhoto,
      'success_story': successStory,
      'key_skills_gained': keySkillsGained,
      'is_featured': isFeatured,
      'placement_date': placementDate?.toIso8601String(),
      'published_at': publishedAt.toIso8601String(),
    };
  }
}

class Testimonial {
  final int id;
  final String studentName;
  final String courseName;
  final String? batchYear;
  final String testimonialType;
  final String testimonialTypeDisplay;
  final String testimonialText;
  final String? youtubeVideoId;
  final String? youtubeThumbnailUrl;
  final String? uploadedVideo;
  final String? audioFile;
  final String? videoThumbnail;
  final String? studentPhoto;
  final int overallRating;
  final int courseRating;
  final int instructorRating;
  final String? keyLearnings;
  final String? careerImpact;
  final String? recommendation;
  final String? currentPosition;
  final String? currentCompany;
  final bool isFeatured;
  final DateTime publishedAt;

  Testimonial({
    required this.id,
    required this.studentName,
    required this.courseName,
    this.batchYear,
    required this.testimonialType,
    required this.testimonialTypeDisplay,
    required this.testimonialText,
    this.youtubeVideoId,
    this.youtubeThumbnailUrl,
    this.uploadedVideo,
    this.audioFile,
    this.videoThumbnail,
    this.studentPhoto,
    required this.overallRating,
    required this.courseRating,
    required this.instructorRating,
    this.keyLearnings,
    this.careerImpact,
    this.recommendation,
    this.currentPosition,
    this.currentCompany,
    required this.isFeatured,
    required this.publishedAt,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      courseName: json['course_name'] ?? '',
      batchYear: json['batch_year'],
      testimonialType: json['testimonial_type'] ?? '',
      testimonialTypeDisplay: json['testimonial_type_display'] ?? json['testimonial_type'] ?? '',
      testimonialText: json['testimonial_text'] ?? '',
      youtubeVideoId: json['youtube_video_id'],
      youtubeThumbnailUrl: json['youtube_thumbnail_url'],
      uploadedVideo: json['uploaded_video'],
      audioFile: json['audio_file'],
      videoThumbnail: json['video_thumbnail'],
      studentPhoto: json['student_photo'],
      overallRating: json['overall_rating'] ?? 0,
      courseRating: json['course_rating'] ?? 0,
      instructorRating: json['instructor_rating'] ?? 0,
      keyLearnings: json['key_learnings'],
      careerImpact: json['career_impact'],
      recommendation: json['recommendation'],
      currentPosition: json['current_position'],
      currentCompany: json['current_company'],
      isFeatured: json['is_featured'] ?? false,
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'course_name': courseName,
      'batch_year': batchYear,
      'testimonial_type': testimonialType,
      'testimonial_type_display': testimonialTypeDisplay,
      'testimonial_text': testimonialText,
      'youtube_video_id': youtubeVideoId,
      'youtube_thumbnail_url': youtubeThumbnailUrl,
      'uploaded_video': uploadedVideo,
      'audio_file': audioFile,
      'video_thumbnail': videoThumbnail,
      'student_photo': studentPhoto,
      'overall_rating': overallRating,
      'course_rating': courseRating,
      'instructor_rating': instructorRating,
      'key_learnings': keyLearnings,
      'career_impact': careerImpact,
      'recommendation': recommendation,
      'current_position': currentPosition,
      'current_company': currentCompany,
      'is_featured': isFeatured,
      'published_at': publishedAt.toIso8601String(),
    };
  }
}

class DashboardStats {
  final int totalStudents;
  final int totalPlacements;
  final double averagePackage;
  final int coursesAvailable;

  DashboardStats({
    required this.totalStudents,
    required this.totalPlacements,
    required this.averagePackage,
    required this.coursesAvailable,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['total_students'] ?? 0,
      totalPlacements: json['total_placements'] ?? 0,
      averagePackage: (json['average_package'] ?? 0.0).toDouble(),
      coursesAvailable: json['courses_available'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_placements': totalPlacements,
      'average_package': averagePackage,
      'courses_available': coursesAvailable,
    };
  }
}

class DashboardData {
  final List<NewsArticle> latestNews;
  final List<Placement> featuredPlacements;
  final List<Testimonial> featuredTestimonials;
  final DashboardStats stats;

  DashboardData({
    required this.latestNews,
    required this.featuredPlacements,
    required this.featuredTestimonials,
    required this.stats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return DashboardData(
      latestNews: (data['latest_news'] as List<dynamic>?)
          ?.map((item) => NewsArticle.fromJson(item))
          .toList() ?? [],
      featuredPlacements: (data['featured_placements'] as List<dynamic>?)
          ?.map((item) => Placement.fromJson(item))
          .toList() ?? [],
      featuredTestimonials: (data['featured_testimonials'] as List<dynamic>?)
          ?.map((item) => Testimonial.fromJson(item))
          .toList() ?? [],
      stats: DashboardStats.fromJson(data['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_news': latestNews.map((item) => item.toJson()).toList(),
      'featured_placements': featuredPlacements.map((item) => item.toJson()).toList(),
      'featured_testimonials': featuredTestimonials.map((item) => item.toJson()).toList(),
      'stats': stats.toJson(),
    };
  }
}

class LeadSubmission {
  final String name;
  final String email;
  final String phone;
  final String areaOfInterest;
  final String? otherInterest;
  final String? currentExperience;
  final String? careerGoals;
  final String? learningTimeline;
  final String? budgetRange;
  final String? preferredTime;
  final String? specificTopics;
  final String? preferredContactMethod;
  final String? source;
  final String? utmSource;
  final String? utmMedium;
  final String? utmCampaign;

  LeadSubmission({
    required this.name,
    required this.email,
    required this.phone,
    required this.areaOfInterest,
    this.otherInterest,
    this.currentExperience,
    this.careerGoals,
    this.learningTimeline,
    this.budgetRange,
    this.preferredTime,
    this.specificTopics,
    this.preferredContactMethod,
    this.source,
    this.utmSource,
    this.utmMedium,
    this.utmCampaign,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'area_of_interest': areaOfInterest,
      'other_interest': otherInterest,
      'current_experience': currentExperience,
      'career_goals': careerGoals,
      'learning_timeline': learningTimeline,
      'budget_range': budgetRange,
      'preferred_time': preferredTime,
      'specific_topics': specificTopics,
      'preferred_contact_method': preferredContactMethod,
      'source': source ?? 'mobile_app',
      'utm_source': utmSource,
      'utm_medium': utmMedium,
      'utm_campaign': utmCampaign,
    };
  }
}

class LeadSubmissionResponse {
  final int leadId;
  final String referenceNumber;
  final String estimatedContactTime;
  final List<String> nextSteps;
  final String message;
  final bool canTrack;

  LeadSubmissionResponse({
    required this.leadId,
    required this.referenceNumber,
    required this.estimatedContactTime,
    required this.nextSteps,
    required this.message,
    required this.canTrack,
  });

  factory LeadSubmissionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return LeadSubmissionResponse(
      leadId: data['lead_id'] ?? 0,
      referenceNumber: data['reference_number'] ?? 'LD${data['lead_id'] ?? 0}',
      estimatedContactTime: data['estimated_contact_time'] ?? 'within 24 hours',
      nextSteps: List<String>.from(data['next_steps'] ?? [
        'Our team will review your application',
        'We will contact you via your preferred method',
        'We will discuss suitable course options based on your goals'
      ]),
      message: data['message'] ?? 'Thank you for your interest!',
      canTrack: data['can_track'] ?? false,
    );
  }
}

class UserLead {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String areaOfInterest;
  final String? otherInterest;
  final String currentExperience;
  final String careerGoals;
  final String learningTimeline;
  final String budgetRange;
  final String preferredTime;
  final String? specificTopics;
  final String preferredContactMethod;
  final String source;
  final String status;
  final DateTime submittedAt;
  final DateTime? contactedAt;
  final DateTime? lastUpdated;
  final String? notes;
  final String? assignedTo;

  UserLead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.areaOfInterest,
    this.otherInterest,
    required this.currentExperience,
    required this.careerGoals,
    required this.learningTimeline,
    required this.budgetRange,
    required this.preferredTime,
    this.specificTopics,
    required this.preferredContactMethod,
    required this.source,
    required this.status,
    required this.submittedAt,
    this.contactedAt,
    this.lastUpdated,
    this.notes,
    this.assignedTo,
  });

  factory UserLead.fromJson(Map<String, dynamic> json) {
    return UserLead(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      phone: json['phone'] ?? 'N/A',
      areaOfInterest: json['area_of_interest'] ?? 'unknown',
      otherInterest: json['other_interest'],
      currentExperience: json['current_experience'] ?? 'beginner',
      careerGoals: json['career_goals'] ?? 'Not specified',
      learningTimeline: json['learning_timeline'] ?? 'Not specified',
      budgetRange: json['budget_range'] ?? 'Not specified',
      preferredTime: json['preferred_time'] ?? 'Not specified',
      specificTopics: json['specific_topics'],
      preferredContactMethod: json['preferred_contact_method'] ?? 'email',
      source: json['source'] ?? 'mobile_app',
      status: json['status'] ?? 'submitted',
      submittedAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      contactedAt: json['contacted_at'] != null ? DateTime.parse(json['contacted_at']) : null,
      lastUpdated: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      notes: json['notes'],
      assignedTo: json['assigned_to'],
    );
  }

  // Convert to local storage format for backward compatibility
  Map<String, dynamic> toLocalStorageFormat() {
    return {
      'referenceNumber': 'LD$id',
      'name': name,
      'email': email,
      'phone': phone,
      'areaOfInterest': areaOfInterest,
      'estimatedContactTime': contactedAt != null ? 'Contacted' : 'within 24 hours',
      'nextSteps': _getNextStepsForStatus(),
      'submittedAt': submittedAt.toIso8601String(),
      'status': status,
    };
  }

  List<String> _getNextStepsForStatus() {
    switch (status.toLowerCase()) {
      case 'submitted':
        return [
          'Our team will review your application',
          'We will contact you via your preferred method',
          'We will discuss suitable course options based on your goals'
        ];
      case 'contacted':
        return [
          'Follow up on our previous conversation',
          'Review course recommendations',
          'Complete enrollment if interested'
        ];
      case 'in_progress':
        return [
          'Complete remaining enrollment steps',
          'Prepare for course start date',
          'Set up learning environment'
        ];
      case 'enrolled':
        return [
          'Access your course materials',
          'Join the student community',
          'Begin your learning journey'
        ];
      case 'rejected':
        return [
          'Consider alternative courses',
          'Improve qualifications and reapply',
          'Contact support for guidance'
        ];
      default:
        return ['Contact support for updates'];
    }
  }
}

class ContentCategories {
  final List<ContentCategory> newsCategories;
  final List<ContentCategory> placementTypes;
  final List<ContentCategory> testimonialTypes;
  final List<String> courses;

  ContentCategories({
    required this.newsCategories,
    required this.placementTypes,
    required this.testimonialTypes,
    required this.courses,
  });

  factory ContentCategories.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return ContentCategories(
      newsCategories: (data['news_categories'] as List<dynamic>?)
          ?.map((item) => ContentCategory.fromJson(item))
          .toList() ?? [],
      placementTypes: (data['placement_types'] as List<dynamic>?)
          ?.map((item) => ContentCategory.fromJson(item))
          .toList() ?? [],
      testimonialTypes: (data['testimonial_types'] as List<dynamic>?)
          ?.map((item) => ContentCategory.fromJson(item))
          .toList() ?? [],
      courses: List<String>.from(data['courses'] ?? []),
    );
  }
}

class ContentCategory {
  final String code;
  final String name;

  ContentCategory({
    required this.code,
    required this.name,
  });

  factory ContentCategory.fromJson(Map<String, dynamic> json) {
    return ContentCategory(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;
  final int currentPage;
  final int totalPages;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Handle both custom API format and Django REST framework format
    final data = json['data'] ?? json;
    final pagination = data['pagination'] ?? data;
    
    return PaginatedResponse<T>(
      results: (data['results'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item))
          .toList() ?? [],
      count: pagination['count'] ?? data['count'] ?? 0,
      next: pagination['next'] ?? data['next'],
      previous: pagination['previous'] ?? data['previous'],
      currentPage: pagination['current_page'] ?? _calculateCurrentPage(data['next'], data['previous']),
      totalPages: pagination['total_pages'] ?? _calculateTotalPages(pagination['count'] ?? data['count'] ?? 0, 10),
    );
  }
  
  static int _calculateCurrentPage(String? next, String? previous) {
    if (previous == null) return 1;
    // Extract page number from URL parameter
    final uri = Uri.tryParse(previous);
    final page = uri?.queryParameters['page'];
    return page != null ? int.tryParse(page) ?? 1 : 1;
  }
  
  static int _calculateTotalPages(int count, int perPage) {
    return (count / perPage).ceil();
  }
}