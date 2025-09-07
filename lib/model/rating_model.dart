class CourseRating {
  final int id;
  final int course;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userUsername;
  final String starDisplay;

  CourseRating({
    required this.id,
    required this.course,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userUsername,
    required this.starDisplay,
  });

  factory CourseRating.fromJson(Map<String, dynamic> json) {
    return CourseRating(
      id: json['id'],
      course: json['course'],
      rating: json['rating'],
      reviewText: json['review_text'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user_name'] ?? '',
      userUsername: json['user_username'] ?? '',
      starDisplay: json['star_display'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'rating': rating,
      'review_text': reviewText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_username': userUsername,
      'star_display': starDisplay,
    };
  }
}

class CourseReview {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userName;
  final String userUsername;
  final int ratingValue;
  final int helpfulCount;
  final bool isHelpfulByUser;

  CourseReview({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.userUsername,
    required this.ratingValue,
    required this.helpfulCount,
    required this.isHelpfulByUser,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userName: json['user_name'] ?? '',
      userUsername: json['user_username'] ?? '',
      ratingValue: json['rating_value'] ?? 0,
      helpfulCount: json['helpful_count'] ?? 0,
      isHelpfulByUser: json['is_helpful_by_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_username': userUsername,
      'rating_value': ratingValue,
      'helpful_count': helpfulCount,
      'is_helpful_by_user': isHelpfulByUser,
    };
  }
}

class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> ratingDistribution;
  final List<CourseRating> recentRatings;

  RatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentRatings,
  });

  factory RatingStats.fromJson(Map<String, dynamic> json) {
    return RatingStats(
      averageRating: json['average_rating']?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] ?? 0,
      ratingDistribution: Map<String, int>.from(json['rating_distribution'] ?? {}),
      recentRatings: json['recent_ratings'] != null
          ? (json['recent_ratings'] as List)
              .map((r) => CourseRating.fromJson(r))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'rating_distribution': ratingDistribution,
      'recent_ratings': recentRatings.map((r) => r.toJson()).toList(),
    };
  }
}

class UserRatingStatus {
  final bool canRate;
  final String? reason;
  final bool hasRated;
  final bool hasReviewed;
  final CourseRating? userRating;
  final CourseReview? userReview;

  UserRatingStatus({
    required this.canRate,
    this.reason,
    required this.hasRated,
    required this.hasReviewed,
    this.userRating,
    this.userReview,
  });

  factory UserRatingStatus.fromJson(Map<String, dynamic> json) {
    return UserRatingStatus(
      canRate: json['can_rate'] ?? false,
      reason: json['reason'],
      hasRated: json['has_rated'] ?? false,
      hasReviewed: json['has_reviewed'] ?? false,
      userRating: json['user_rating'] != null
          ? CourseRating.fromJson(json['user_rating'])
          : null,
      userReview: json['user_review'] != null
          ? CourseReview.fromJson(json['user_review'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_rate': canRate,
      'reason': reason,
      'has_rated': hasRated,
      'has_reviewed': hasReviewed,
      'user_rating': userRating?.toJson(),
      'user_review': userReview?.toJson(),
    };
  }
}