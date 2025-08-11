class ApiConstants {
  static const String baseUrl = "https://uptrail.info/api";
  static const String authBaseUrl = "$baseUrl/users/auth";
  static const String coursesBaseUrl = "$baseUrl/courses";
  static const String usersBaseUrl = "$baseUrl/users";
  
  // Auth endpoints
  static const String loginEndpoint = "/login/";
  static const String registerEndpoint = "/register/";
  static const String refreshEndpoint = "/refresh/";
  
  // Profile endpoints
  static const String profileEndpoint = "/profile/";
  static const String changePasswordEndpoint = "/profile/change-password/";
  
  // Course endpoints
  static const String coursesEndpoint = "/";
  static const String courseSearchEndpoint = "/search/";
  static const String courseCategoriesEndpoint = "/categories/";
  static const String enrolledCoursesEndpoint = "/enrolled/";
  
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
  
  // Course URLs
  static String get courses => "$coursesBaseUrl$coursesEndpoint";
  static String get courseSearch => "$coursesBaseUrl$courseSearchEndpoint";
  static String get courseCategories => "$coursesBaseUrl$courseCategoriesEndpoint";
  static String get enrolledCourses => "$coursesBaseUrl$enrolledCoursesEndpoint";
  
  // Profile URLs
  static String get userProfile => "$usersBaseUrl$profileEndpoint";
  static String get changePassword => "$usersBaseUrl$changePasswordEndpoint";
  
  // Payment URLs
  static String get myEnrollments => "$paymentsBaseUrl$myEnrollmentsEndpoint";
  static String get purchaseCourse => "$paymentsBaseUrl$purchaseCourseEndpoint";
  
  // Team URLs
  static String get myTeams => "$usersBaseUrl$myTeamsEndpoint";
  static String get teams => "$usersBaseUrl$teamsEndpoint";
  
  // Course detail URL (requires course ID)
  static String courseDetail(int courseId) => "$coursesBaseUrl/$courseId/";
  
  // Payment-specific URLs with parameters
  static String coursePricing(int courseId) => "$paymentsBaseUrl/course/$courseId/pricing/";
  static String enrollmentPayments(int enrollmentId) => "$paymentsBaseUrl/enrollments/$enrollmentId/payments/";
  
  // Team-specific URLs with parameters
  static String teamDetail(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/";
  static String joinTeam(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/join/";
  static String leaveTeam(int teamId) => "$usersBaseUrl$teamsEndpoint$teamId/leave/";
}