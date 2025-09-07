import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/course_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/course_detail_page.dart';

class SelectedCoursesPage extends StatefulWidget {
  const SelectedCoursesPage({super.key});

  @override
  State<SelectedCoursesPage> createState() => _SelectedCoursesPageState();
}

class _SelectedCoursesPageState extends State<SelectedCoursesPage> {
  final CourseService _courseService = CourseService();
  List<Course> _enrolledCourses = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrolledCourses();
  }

  Future<void> _loadEnrolledCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courses = await _courseService.getEnrolledCourses();
      setState(() {
        _enrolledCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Courses", style: AppTextStyle.headline2),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadEnrolledCourses,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.champagnePink,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppColors.logoBrightBlue,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Loading your courses...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.red[600],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Oops! Something went wrong",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadEnrolledCourses,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoBrightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_enrolledCourses.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.champagnePink,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.logoBrightBlue.withValues(alpha: 0.2), AppColors.logoBrightBlue.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 50,
                  color: AppColors.logoBrightBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "No Courses Yet!",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Start your learning journey by exploring available courses",
                style: TextStyle(color: Colors.black54, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to course catalog or browse page
                  Navigator.pop(context); // Go back to main page to browse courses
                },
                icon: const Icon(Icons.explore_rounded),
                label: const Text("Explore Courses"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoBrightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEnrolledCourses,
      color: AppColors.logoBrightBlue,
      backgroundColor: AppColors.champagnePink,
      child: CustomScrollView(
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.logoBrightBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Continue Learning",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_enrolledCourses.length} course${_enrolledCourses.length != 1 ? 's' : ''} enrolled",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Courses grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildModernCourseCard(_enrolledCourses[index], index),
                childCount: _enrolledCourses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCourseCard(Course course, int index) {
    final progress = _calculateCourseProgress(course);
    final progressPercentage = (progress * 100).toInt();
    final totalModules = _getTotalModuleCount(course);
    final totalLessons = _getTotalLessonCount(course);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailPage(course: course),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Course Thumbnail/Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                  ),
                  child: course.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            course.thumbnailUrl!,
                            fit: BoxFit.cover,
                            width: 64,
                            height: 64,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.school_outlined,
                              color: AppColors.logoBrightBlue,
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.school_outlined,
                          color: AppColors.logoBrightBlue,
                          size: 32,
                        ),
                ),
                
                const SizedBox(width: 16),
                
                // Course Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Course Title
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Course Stats
                      Text(
                        "$totalModules modules • $totalLessons lessons",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.logoBrightBlue,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$progressPercentage%",
                            style: TextStyle(
                              color: AppColors.logoBrightBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Action Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    progressPercentage == 0 
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                    color: AppColors.logoBrightBlue,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Compact Hero Image Section
  Widget _buildCompactHeroSection(Course course, int progressPercentage) {
    return Container(
      height: 120,
      width: double.infinity,
      child: Stack(
        children: [
          // Main Image/Gradient Background
          if (course.thumbnailUrl != null)
            Container(
              height: 120,
              width: double.infinity,
              child: Image.network(
                course.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildCompactGradientBg(),
              ),
            )
          else
            _buildCompactGradientBg(),
          
          // Subtle Overlay
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          
          // Play Button
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.logoBrightBlue,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactGradientBg() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.logoBrightBlue.withValues(alpha: 0.9),
            AppColors.logoBrightBlue,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.school_outlined,
          color: Colors.white.withValues(alpha: 0.8),
          size: 40,
        ),
      ),
    );
  }
  
  Widget _buildCompactStat(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Professional Hero Image Section
  Widget _buildHeroImageSection(Course course, int progressPercentage) {
    return Container(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Main Image/Gradient Background
          if (course.thumbnailUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              child: Image.network(
                course.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPremiumGradientBg(),
              ),
            )
          else
            _buildPremiumGradientBg(),
          
          // Professional Gradient Overlay
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          // Progress Badge (Top Right)
          if (progressPercentage > 0)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: progressPercentage == 100 ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$progressPercentage%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Play Button Overlay
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                progressPercentage > 0 ? Icons.play_arrow : Icons.play_arrow,
                color: AppColors.logoBrightBlue,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumGradientBg() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.logoBrightBlue.withValues(alpha: 0.9),
            AppColors.logoBrightBlue,
            AppColors.logoBrightBlue.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              color: Colors.white.withValues(alpha: 0.9),
              size: 56,
            ),
            const SizedBox(height: 12),
            Text(
              "Course Content",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Professional Header Row with Category and Status
  Widget _buildCourseHeaderRow(Course course, int progressPercentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (course.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.logoBrightBlue.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              course.category!.toUpperCase(),
              style: TextStyle(
                color: AppColors.logoBrightBlue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          )
        else
          const SizedBox(),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: progressPercentage == 100 
                ? Colors.green.withValues(alpha: 0.1) 
                : progressPercentage > 0 
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            progressPercentage == 100 
                ? "COMPLETED" 
                : progressPercentage > 0 
                    ? "IN PROGRESS"
                    : "NOT STARTED",
            style: TextStyle(
              color: progressPercentage == 100 
                  ? Colors.green[700]
                  : progressPercentage > 0 
                      ? Colors.orange[700]
                      : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
  
  // Professional Stats Section
  Widget _buildStatsSection(int totalModules, int totalLessons, Course course) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.library_books_outlined,
              totalModules.toString(),
              "Modules",
              const Color(0xFF3B82F6),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.play_circle_outline,
              totalLessons.toString(),
              "Lessons",
              const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.schedule_outlined,
              "${totalLessons * 8}m",
              "Duration",
              const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  // Advanced Progress Section
  Widget _buildAdvancedProgressSection(double progress, int progressPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Learning Progress",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$progressPercentage%",
              style: TextStyle(
                color: AppColors.logoBrightBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.logoBrightBlue,
                      AppColors.logoBrightBlue.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.logoBrightBlue.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Premium Action Button
  Widget _buildPremiumActionButton(int progressPercentage, Course course) {
    return Container(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailPage(course: course),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.logoBrightBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AppColors.logoBrightBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              progressPercentage == 0 
                  ? Icons.play_arrow 
                  : progressPercentage == 100
                      ? Icons.refresh
                      : Icons.arrow_forward,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              progressPercentage == 0 
                  ? "Start Learning" 
                  : progressPercentage == 100
                      ? "Review Course"
                      : "Continue Learning",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.logoBrightBlue.withValues(alpha: 0.8),
            AppColors.logoBrightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.school_rounded,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  double _calculateCourseProgress(Course course) {
    if (course.modules == null || course.modules!.isEmpty) {
      return 0.0; // No modules, no progress
    }

    int totalLessons = 0;
    int completedLessons = 0;

    // Count total and completed lessons across all modules
    for (final module in course.modules!) {
      if (module.lessons != null) {
        totalLessons += module.lessons!.length;
        for (final lesson in module.lessons!) {
          if (lesson.isCompleted == true) {
            completedLessons++;
          }
        }
      }
    }

    // Calculate progress based on completed lessons
    if (totalLessons == 0) {
      // If no lessons, check module progress instead
      int totalModules = course.modules!.length;
      int completedModules = 0;
      
      for (final module in course.modules!) {
        if (module.progress?.isCompleted == true) {
          completedModules++;
        }
      }
      
      return totalModules > 0 ? completedModules / totalModules : 0.0;
    }

    return completedLessons / totalLessons;
  }

  int _getTotalModuleCount(Course course) {
    return course.moduleCount ?? course.modules?.length ?? 0;
  }

  int _getTotalLessonCount(Course course) {
    if (course.totalLessons != null && course.totalLessons! > 0) {
      return course.totalLessons!;
    }
    
    // Calculate from modules if not available
    int count = 0;
    if (course.modules != null) {
      for (final module in course.modules!) {
        if (module.lessons != null) {
          count += module.lessons!.length;
        }
      }
    }
    return count;
  }
}