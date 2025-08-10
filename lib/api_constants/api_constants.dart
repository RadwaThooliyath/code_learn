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
  
  // Course detail URL (requires course ID)
  static String courseDetail(int courseId) => "$coursesBaseUrl/$courseId/";
}