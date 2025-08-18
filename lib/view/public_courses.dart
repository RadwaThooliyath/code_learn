import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/course_service.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/services/payment_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/course_detail_page.dart';

class PublicCoursesPage extends StatefulWidget {
  const PublicCoursesPage({super.key});

  @override
  State<PublicCoursesPage> createState() => _PublicCoursesPageState();
}

class _PublicCoursesPageState extends State<PublicCoursesPage> {
  final CourseService _courseService = CourseService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final PaymentService _paymentService = PaymentService();
  
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _paymentService.initialize();
    _loadCourses();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final courses = await _courseService.getCourses(
        search: _searchQuery,
      );
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading courses: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleEnrollment(Course course) async {
    try {
      Map<String, dynamic> result;
      
      if (course.isFree) {
        // Show loading dialog for free courses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Enrolling in course..."),
              ],
            ),
          ),
        );

        // Use direct enrollment for free courses
        result = await _enrollmentService.enrollInCourse(course.id);
        
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
      } else {
        // Use payment service for paid courses
        result = await _paymentService.initiateCoursePayment(
          context: context,
          course: course,
          userEmail: 'user@example.com', // TODO: Get from user profile
          userPhone: '+919876543210', // TODO: Get from user profile
        );
      }

      if (result['success'] == true) {
        // Show success message
        _showEnrollmentResult(
          success: true,
          title: "Enrollment Successful!",
          message: result['message'] ?? "You have successfully enrolled in this course.",
        );
        
        // Refresh course list to update enrollment status
        _loadCourses();
      } else {
        // Show error message
        _showEnrollmentResult(
          success: false,
          title: "Enrollment Failed",
          message: result['message'] ?? "Failed to enroll in course. Please try again.",
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open for free courses
      if (course.isFree && mounted) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      _showEnrollmentResult(
        success: false,
        title: "Error",
        message: "An error occurred: ${e.toString()}",
      );
    }
  }

  void _showEnrollmentResult({
    required bool success,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.champagnePink,
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "OK",
              style: TextStyle(color: AppColors.logoBrightBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Available Courses",
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.logoBrightBlue,
                    ),
                  )
                : _courses.isEmpty
                    ? _buildEmptyState()
                    : _buildCoursesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.isEmpty ? null : value;
          });
        },
        onSubmitted: (value) => _loadCourses(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search courses...",
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppColors.logoBrightBlue),
            onPressed: _loadCourses,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            "No courses available",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            "Check back later for new courses",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    final isEnrolled = course.isEnrolled == true;
    final canEnroll = course.allowPublicEnrollment == true && !isEnrolled;

    return Card(
      color: AppColors.champagnePink,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header
              Row(
                children: [
                  // Thumbnail or placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: course.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              course.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.school,
                                  size: 40,
                                  color: Colors.black54,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.school,
                            size: 40,
                            color: Colors.black54,
                          ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (course.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.logoBrightBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course.category!,
                              style: const TextStyle(
                                color: AppColors.logoBrightBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              course.isFree ? Icons.school : Icons.paid,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              course.isFree ? "Free" : (course.priceDisplay ?? "\$${course.price}"),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                course.description,
                style: const TextStyle(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  // Enrollment status or button
                  if (isEnrolled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            "ENROLLED",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (canEnroll)
                    ElevatedButton(
                      onPressed: () => _handleEnrollment(course),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoBrightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        course.isFree ? "Enroll for Free" : "Purchase Course",
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Not Available",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // View details button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(course: course),
                        ),
                      );
                    },
                    child: const Text(
                      "View Details",
                      style: TextStyle(color: AppColors.logoBrightBlue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}