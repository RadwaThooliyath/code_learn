class ApiConstants {
  static const String baseUrl = "https://uptrail.info/api";
  static const String authBaseUrl = "$baseUrl/users/auth";
  static const String coursesBaseUrl = "$baseUrl/courses";
  static const String usersBaseUrl = "$baseUrl/users";
  
  // Auth endpoints
  static const String loginEndpoint = "/login/";
  static const String registerEndpoint = "/register/";
  static const String refreshEndpoint = "/refresh/";
  static const String passwordResetEndpoint = "/password-reset/";
  static const String passwordResetConfirmEndpoint = "/password-reset-confirm/";
  
  // Profile endpoints
  static const String profileEndpoint = "/profile/";
  static const String changePasswordEndpoint = "/profile/change-password/";
  static const String deleteAccountEndpoint = "/profile/delete-account/";
  
  // Course endpoints
  static const String coursesEndpoint = "/";
  static const String courseSearchEndpoint = "/search/";
  static const String courseCategoriesEndpoint = "/categories/";
  static const String enrolledCoursesEndpoint = "/enrolled/";
  static const String enrollCourseEndpoint = "/purchase-course/";
  
  // Payment endpoints
  static const String paymentsBaseUrl = "$baseUrl/payments";
  static const String myEnrollmentsEndpoint = "/my-enrollments/";
  static const String purchaseCourseEndpoint = "/purchase-course/";
  
  // Team endpoints
  static const String myTeamsEndpoint = "/my-teams/";
  static const String teamsEndpoint = "/teams/";
  
  // Auth URLs
  static String get login => "$authBaseUrl$loginEndpoint";
  static String get register => "$authBaseUrl$registerEndpoint";
  static String get refresh => "$authBaseUrl$refreshEndpoint";
  static String get passwordReset => "$authBaseUrl$passwordResetEndpoint";
  static String passwordResetConfirm(String token) => "$authBaseUrl$passwordResetConfirmEndpoint$token/";
  
  // Course URLs
  static String get courses => "$coursesBaseUrl$coursesEndpoint";
  static String get courseSearch => "$coursesBaseUrl$courseSearchEndpoint";
  static String get courseCategories => "$coursesBaseUrl$courseCategoriesEndpoint";
  static String get enrolledCourses => "$coursesBaseUrl$enrolledCoursesEndpoint";
  static String get enrollCourse => "$paymentsBaseUrl$enrollCourseEndpoint";
  
  // Profile URLs
  static String get userProfile => "$usersBaseUrl$profileEndpoint";
  static String get changePassword => "$usersBaseUrl$changePasswordEndpoint";
  static String get deleteAccount => "$usersBaseUrl$deleteAccountEndpoint";
  
  // Payment URLs
  static String get myEnrollments => "$paymentsBaseUrl$myEnrollmentsEndpoint";
  static String get purchaseCourse => "$paymentsBaseUrl$purchaseCourseEndpoint";
  
  // Team URLs
  static String get myTeams => "$usersBaseUrl$myTeamsEndpoint";
  static String get teams => "$usersBaseUrl$teamsEndpoint";
  
  // Course detail URL (requires course ID)
  static String courseDetail(int courseId) => "$coursesBaseUrl/$courseId/";

  // Assignment URLs
  static String moduleAssignments(int moduleId) => "$coursesBaseUrl/modules/$moduleId/assignments/";
  static String assignmentDetail(int assignmentId) => "$coursesBaseUrl/assignments/$assignmentId/";
  static String get assignmentSubmissions => "$coursesBaseUrl/assignment-submissions/";
  static String assignmentSubmissionDetail(int submissionId) => "$coursesBaseUrl/assignment-submissions/$submissionId/";

  // Quiz URLs
  static String moduleQuizzes(int moduleId) => "$coursesBaseUrl/modules/$moduleId/quizzes/";
  static String quizDetail(int quizId) => "$coursesBaseUrl/quizzes/$quizId/";
  static String startQuizAttempt(int quizId) => "$coursesBaseUrl/quizzes/$quizId/start/";
  static String get quizAttempts => "$coursesBaseUrl/quiz-attempts/";
  static String submitQuizAttempt(int attemptId) => "$coursesBaseUrl/quiz-attempts/$attemptId/submit/";
  
  // Progress URLs
  static String get progress => "$coursesBaseUrl/progress/";
  static String get moduleProgress => "$coursesBaseUrl/module-progress/";
  
  // Payment-specific URLs with parameters
  static String coursePricing(int courseId) => "$paymentsBaseUrl/course/$courseId/pricing/";
  static String enrollmentPayments(int enrollmentId) => "$paymentsBaseUrl/enrollments/$enrollmentId/payments/";
  
  // Team-specific URLs with parameters
  static String teamDetail(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/";
  static String joinTeam(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/join/";
  static String leaveTeam(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/leave/";
  
  // Rating URLs
  static String courseRatings(int courseId) => "$baseUrl/ratings/course/$courseId/ratings/";
  static String userCourseRating(int courseId) => "$baseUrl/ratings/course/$courseId/my-rating/";
  static String courseRatingStats(int courseId) => "$baseUrl/ratings/course/$courseId/rating-stats/";
  static String userRatingStatus(int courseId) => "$baseUrl/ratings/course/$courseId/rating-status/";
  static String courseReviews(int courseId) => "$baseUrl/ratings/course/$courseId/reviews/";
  static String toggleReviewHelpful(int reviewId) => "$baseUrl/ratings/review/$reviewId/helpful/";
}