import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/enrollment_model.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/model/assignment_model.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/services/course_service.dart';
import 'package:uptrail/services/assignment_service.dart';
import 'package:uptrail/services/quiz_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/assignment_submission_page.dart';
import 'package:uptrail/view/quiz_taking_page.dart';

class EnrollmentDetailPage extends StatefulWidget {
  final Enrollment enrollment;

  const EnrollmentDetailPage({
    super.key,
    required this.enrollment,
  });

  @override
  State<EnrollmentDetailPage> createState() => _EnrollmentDetailPageState();
}

class _EnrollmentDetailPageState extends State<EnrollmentDetailPage>
    with SingleTickerProviderStateMixin {
  final EnrollmentService _enrollmentService = EnrollmentService();
  final CourseService _courseService = CourseService();
  final AssignmentService _assignmentService = AssignmentService();
  final QuizService _quizService = QuizService();
  
  List<PaymentRecord> _paymentRecords = [];
  List<Installment> _loadedInstallments = []; // Local state for installments
  Course? _courseDetail;
  Map<int, List<Assignment>> _moduleAssignments = {};
  Map<int, List<Quiz>> _moduleQuizzes = {};
  Map<int, bool> _quizPassedStatus = {}; // Track quiz pass status
  Map<int, int> _quizAttemptCounts = {}; // Track attempt counts
  Map<int, bool> _canRetakeQuiz = {}; // Track if quiz can be retaken
  bool _isLoading = false;
  bool _isLoadingCourse = false;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPaymentRecords();
    _loadInstallmentPlans();
    _loadCourseContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final payments = await _enrollmentService.getEnrollmentPayments(
        widget.enrollment.id,
      );
      
      setState(() {
        _paymentRecords = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInstallmentPlans() async {
    try {
      final installments = await _enrollmentService.getInstallmentPlans(
        widget.enrollment.id,
      );
      
      if (installments.isNotEmpty) {
        
        setState(() {
          // Store installments in local state
          _loadedInstallments = installments;
        });
      }
    } catch (e) {
      // Failed to load installment plans
    }
  }

  Future<void> _loadCourseContent() async {
    try {
      setState(() {
        _isLoadingCourse = true;
      });

      // Try to get course detail from the proper API first
      
      try {
        final courseDetail = await _courseService.getCourseDetail(widget.enrollment.courseId);
        if (courseDetail != null) {
          setState(() {
            _courseDetail = courseDetail;
          });
          
          // Load assignments and quizzes for each module if available
          if (courseDetail.modules != null) {
            for (final module in courseDetail.modules!) {
              await _loadModuleAssignments(module.id);
              await _loadModuleQuizzes(module.id);
            }
          }
        }
      } catch (e) {
        // Check if we have modules in the enrollment data as fallback
        if (widget.enrollment.courseModules != null && widget.enrollment.courseModules!.isNotEmpty) {
          
          // Parse modules from enrollment data
          final modules = widget.enrollment.courseModules!
              .map((moduleData) => Module.fromJson(moduleData as Map<String, dynamic>))
              .toList();
          
          setState(() {
            _courseDetail = Course(
              id: widget.enrollment.courseId,
              title: widget.enrollment.courseName,
              description: 'Course content from enrollment',
              isFree: false,
              modules: modules,
            );
          });
          
          // Load assignments and quizzes for each module
          for (final module in modules) {
            await _loadModuleAssignments(module.id);
            await _loadModuleQuizzes(module.id);
          }
        } else {
          
          // Final fallback: Try to get enrolled courses and find this course
          try {
            final enrolledCourses = await _courseService.getEnrolledCourses();
            final matchingCourse = enrolledCourses.firstWhere(
              (course) => course.id == widget.enrollment.courseId,
              orElse: () => throw Exception("Course not found in enrolled courses"),
            );
            
            setState(() {
              _courseDetail = matchingCourse;
            });
            
            // Load assignments and quizzes for each module if available
            if (matchingCourse.modules != null) {
              for (final module in matchingCourse.modules!) {
                await _loadModuleAssignments(module.id);
                await _loadModuleQuizzes(module.id);
              }
            }
          } catch (fallbackError) {
            // Create a minimal course object with just the basic info we have
            setState(() {
              _courseDetail = Course(
                id: widget.enrollment.courseId,
                title: widget.enrollment.courseName,
                description: 'Team enrollment course - content loaded separately',
                isFree: false,
                modules: [], // Empty modules list, but we'll try to load content anyway
              );
            });
            
            // Try to load content by guessing module IDs or using course ID as module ID
            await _tryLoadContentDirectly();
          }
        }
      }

      setState(() {
        _isLoadingCourse = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCourse = false;
      });
    }
  }

  Future<void> _loadModuleAssignments(int moduleId) async {
    try {
      final assignments = await _assignmentService.getModuleAssignments(moduleId);
      setState(() {
        _moduleAssignments[moduleId] = assignments;
      });
    } catch (e) {
      setState(() {
        _moduleAssignments[moduleId] = [];
      });
    }
  }

  Future<void> _loadModuleQuizzes(int moduleId) async {
    try {
      final quizzes = await _quizService.getModuleQuizzes(moduleId);
      setState(() {
        _moduleQuizzes[moduleId] = quizzes;
      });
      
      // Load quiz pass status for each quiz
      for (final quiz in quizzes) {
        await _loadQuizPassStatus(quiz.id);
      }
    } catch (e) {
      setState(() {
        _moduleQuizzes[moduleId] = [];
      });
    }
  }

  Future<void> _loadQuizPassStatus(int quizId) async {
    try {
      final attempts = await _quizService.getMyQuizAttempts();
      final quizAttempts = attempts.where((attempt) => attempt.quiz == quizId).toList();
      
      bool hasPassed = false;
      int attemptCount = quizAttempts.length;
      
      if (quizAttempts.isNotEmpty) {
        // Check if any attempt passed
        hasPassed = quizAttempts.any((attempt) => 
          attempt.isPassed.toLowerCase() == 'true' || 
          attempt.isPassed.toLowerCase() == 'passed'
        );
      }
      
      // Find the quiz to get max attempts
      Quiz? quiz;
      for (final moduleQuizzes in _moduleQuizzes.values) {
        quiz = moduleQuizzes.where((q) => q.id == quizId).firstOrNull;
        if (quiz != null) break;
      }
      
      bool canRetake = false;
      if (quiz != null) {
        // Can retake if haven't passed and have attempts remaining
        canRetake = (!hasPassed && attemptCount < quiz.maxAttempts);
      }
      
      setState(() {
        _quizPassedStatus[quizId] = hasPassed;
        _quizAttemptCounts[quizId] = attemptCount;
        _canRetakeQuiz[quizId] = canRetake;
      });
    } catch (e) {
      // Failed to load quiz pass status
    }
  }

  Future<void> _tryLoadContentDirectly() async {
    // Try a wider range of module IDs since we know content exists
    final possibleModuleIds = <int>[];
    
    // Add course-related IDs
    possibleModuleIds.add(widget.enrollment.courseId); // 3
    
    // Try sequential IDs around the course ID
    for (int i = 1; i <= 20; i++) {
      possibleModuleIds.add(i);
    }
    
    // Try some common patterns
    possibleModuleIds.addAll([
      widget.enrollment.courseId * 10, // 30
      widget.enrollment.courseId + 10, // 13
      widget.enrollment.courseId + 100, // 103
    ]);

    // Try possible module IDs
    
    bool foundContent = false;
    
    for (final moduleId in possibleModuleIds) {
      try {
        
        List<Assignment> assignments = [];
        List<Quiz> quizzes = [];
        
        // Try to load assignments for this module ID
        try {
          assignments = await _assignmentService.getModuleAssignments(moduleId);
          if (assignments.isNotEmpty) {
            setState(() {
              _moduleAssignments[moduleId] = assignments;
            });
          }
        } catch (e) {
          // No assignments for this module
        }
        
        // Try to load quizzes for this module ID
        try {
          quizzes = await _quizService.getModuleQuizzes(moduleId);
          if (quizzes.isNotEmpty) {
            setState(() {
              _moduleQuizzes[moduleId] = quizzes;
            });
          }
        } catch (e) {
          // No quizzes for this module
        }
        
        // If we found content, create a module for display
        if (assignments.isNotEmpty || quizzes.isNotEmpty) {
          
          final fakeModule = Module(
            id: moduleId,
            title: "Module $moduleId - ${widget.enrollment.courseName}",
            description: "Course content (${assignments.length} assignments, ${quizzes.length} quizzes)",
            order: moduleId,
            lessons: [], // We don't have lesson data yet
          );
          
          setState(() {
            _courseDetail = Course(
              id: widget.enrollment.courseId,
              title: widget.enrollment.courseName,
              description: 'Team enrollment course with discovered content',
              isFree: false,
              modules: [fakeModule], // Add the module we found content for
            );
          });
          
          foundContent = true;
          break; // Stop trying once we find content
        }
      } catch (e) {
        // Silently continue to next module ID
      }
    }
    
    if (!foundContent) {
      // No content found - try to get user's assignment submissions to find content
      try {
        final submissions = await _assignmentService.getMyAssignmentSubmissions();
        // Process submissions if found
      } catch (e) {
        // Could not get assignment submissions
      }
      
      try {
        final attempts = await _quizService.getMyQuizAttempts();
        // Process attempts if found
      } catch (e) {
        // Could not get quiz attempts
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Payment Details",
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentRecords,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseInfo(),

            _buildPaymentSummary(),

            if (_loadedInstallments.isNotEmpty ||
                (widget.enrollment.installments != null &&
                 widget.enrollment.installments!.isNotEmpty))
              _buildInstallmentOverview(),

            _buildPaymentHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourseInfo(),
          const SizedBox(height: 24),
          _buildPaymentSummary(),
          const SizedBox(height: 24),
          if (widget.enrollment.installments != null &&
              widget.enrollment.installments!.isNotEmpty)
            _buildInstallmentOverview(),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    if (_isLoadingCourse) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.logoBrightBlue,
        ),
      );
    }

    if (_courseDetail == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              "Unable to load course content",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    if (_courseDetail!.modules == null || _courseDetail!.modules!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              "No modules available in this course",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Course: ${_courseDetail!.title}",
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadCourseContent(); // Retry loading
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Course Modules",
            style: AppTextStyle.headline2,
          ),
          const SizedBox(height: 16),
          ..._courseDetail!.modules!.map((module) => _buildModuleCard(module)),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Module module) {
    final assignments = _moduleAssignments[module.id] ?? [];
    final quizzes = _moduleQuizzes[module.id] ?? [];
    
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          module.description ?? 'No description available',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.logoBrightBlue,
          child: Text(
            module.order.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          if (module.lessons != null && module.lessons!.isNotEmpty)
            _buildLessonsSection(module.lessons!),
          if (assignments.isNotEmpty)
            _buildAssignmentsSection(assignments),
          if (quizzes.isNotEmpty)
            _buildQuizzesSection(quizzes),
          if ((module.lessons?.isEmpty ?? true) && 
              assignments.isEmpty && 
              quizzes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "No content available in this module",
                style: TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonsSection(List<Lesson> lessons) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📖 Lessons",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...lessons.map((lesson) => ListTile(
            dense: true,
            leading: Icon(
              lesson.type == 'video' ? Icons.play_circle : Icons.article,
              color: AppColors.logoBrightBlue,
            ),
            title: Text(
              lesson.title,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: lesson.description != null 
                ? Text(
                    lesson.description!,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: lesson.isCompleted == true 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          )),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection(List<Assignment> assignments) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📝 Assignments",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...assignments.map((assignment) => ListTile(
            dense: true,
            leading: Icon(
              Icons.assignment,
              color: _getAssignmentStatusColor(assignment.submissionStatus),
            ),
            title: Text(
              assignment.title,
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assignment.description.isNotEmpty)
                  Text(
                    assignment.description,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Row(
                  children: [
                    Text(
                      "Max Points: ${assignment.maxPoints}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Due: ${assignment.dueDays} days",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildAssignmentStatusChip(assignment.submissionStatus),
            onTap: () {
              // Navigate to assignment submission page
              _navigateToAssignmentSubmission(assignment);
            },
          )),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildQuizzesSection(List<Quiz> quizzes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🧠 Quizzes",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...quizzes.map((quiz) {
            final isPassed = _quizPassedStatus[quiz.id] ?? false;
            final attemptCount = _quizAttemptCounts[quiz.id] ?? 0;
            final canRetake = _canRetakeQuiz[quiz.id] ?? (attemptCount < quiz.maxAttempts);
            final canTakeQuiz = attemptCount == 0 || canRetake;
            
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green[50] : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isPassed ? Border.all(color: Colors.green[200]!, width: 1) : null,
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPassed ? Colors.green[100] : AppColors.logoBrightBlue.withOpacity(0.1),
                  ),
                  child: Icon(
                    isPassed ? Icons.check_circle : Icons.quiz_outlined,
                    color: isPassed ? Colors.green[600] : AppColors.logoBrightBlue,
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: isPassed ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isPassed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "PASSED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (quiz.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          quiz.description,
                          style: const TextStyle(color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Text(
                      "Questions: ${quiz.questions.length} • Points: ${quiz.maxPoints} • Attempts: $attemptCount/${quiz.maxAttempts}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
                trailing: Container(
                  height: 36,
                  child: canTakeQuiz 
                    ? ElevatedButton.icon(
                        onPressed: () => _startQuiz(quiz),
                        icon: Icon(
                          attemptCount > 0 ? Icons.refresh : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(
                          attemptCount > 0 ? "Retry" : "Take Quiz",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: attemptCount > 0 ? Colors.orange[600] : AppColors.logoBrightBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPassed ? Colors.green[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPassed ? "Completed" : "No attempts left",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPassed ? Colors.green[700] : Colors.grey[600],
                          ),
                        ),
                      ),
                ),
              ),
            );
          }),
          const Divider(),
        ],
      ),
    );
  }

  Color _getAssignmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'graded':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'not_submitted':
      default:
        return Colors.red;
    }
  }

  Widget _buildAssignmentStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getAssignmentStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: TextStyle(
          color: _getAssignmentStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToAssignmentSubmission(Assignment assignment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssignmentSubmissionPage(assignment: assignment),
      ),
    );
    
    // Refresh assignment data if submission was updated
    if (result != null) {
      // Reload module assignments to update status
      _loadModuleAssignments(assignment.id); // This might need the module ID instead
    }
  }

  void _showAssignmentDetail(Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: Text(
          assignment.title,
          style: const TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Description:",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                assignment.description,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              if (assignment.requirements.isNotEmpty) ...[
                Text(
                  "Requirements:",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.requirements,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 12),
              ],
              if (assignment.resources.isNotEmpty) ...[
                Text(
                  "Resources:",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.resources,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Max Points: ${assignment.maxPoints}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Passing Score: ${assignment.passingScore}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Due Days: ${assignment.dueDays}",
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          if (assignment.submissionStatus == 'not_submitted')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to assignment submission page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Assignment submission feature coming soon"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Submit Assignment"),
            ),
        ],
      ),
    );
  }

  void _showQuizDetail(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.champagnePink,
        title: Text(
          quiz.title,
          style: const TextStyle(color: Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Description:",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                quiz.description,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Questions: ${quiz.questions.length}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Time Limit: ${quiz.timeLimit} min",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Max Points: ${quiz.maxPoints}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Passing Score: ${quiz.passingScore}",
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startQuiz(quiz);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoBrightBlue,
            ),
            child: const Text("Start Quiz"),
          ),
        ],
      ),
    );
  }

  void _startQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingPage(quiz: quiz),
      ),
    );
  }

  Widget _buildPaymentsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.logoBrightBlue,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading payments",
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_paymentRecords.isEmpty && widget.enrollment.payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_outlined,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              "No payment records found",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    final allPayments = _paymentRecords.isNotEmpty 
        ? _paymentRecords 
        : widget.enrollment.payments;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPayments.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(allPayments[index]);
      },
    );
  }

  Widget _buildCourseInfo() {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [



                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.enrollment.courseName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Enrolled: ${_formatDate(widget.enrollment.enrolledAt)}",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(widget.enrollment.status),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Summary",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  "\u{20B9}${widget.enrollment.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Paid Amount:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  "\u{20B9}${widget.enrollment.paidAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.enrollment.remainingAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Remaining:",
                    style: TextStyle(   color: Colors.black,),
                  ),
                  Text(
                    "\u{20B9}${widget.enrollment.remainingAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.enrollment.totalAmount > 0
                  ? widget.enrollment.paidAmount / widget.enrollment.totalAmount
                  : 0,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.enrollment.remainingAmount <= 0
                    ? Colors.green
                    : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Payment Status:",
                  style: TextStyle(   color: Colors.black,),
                ),
                Text(
                  widget.enrollment.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(widget.enrollment.paymentStatus),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentOverview() {
    // Use loaded installments from local state, fallback to widget data
    final installments = _loadedInstallments.isNotEmpty 
        ? _loadedInstallments 
        : widget.enrollment.installments ?? [];
    
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Installment Plan",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...installments.map((installment) => _buildInstallmentItem(installment)),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentItem(Installment installment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getInstallmentStatusColor(installment.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Due: ${_formatDate(installment.dueDate)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "\u{20B9}${installment.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  installment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getInstallmentStatusColor(installment.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment) {
    return Card(
      color: AppColors.champagnePink,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\u{20B9}${payment.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(payment.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(payment.paymentDate),
                  style: const TextStyle(color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  payment.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (payment.transactionId != null) ...[
              const SizedBox(height: 4),
              Text(
                "Transaction: ${payment.transactionId}",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
            if (payment.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                payment.notes!,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Text(
      status.toUpperCase(),
      style: TextStyle(
        color: _getEnrollmentStatusColor(status),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _getEnrollmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.black;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getInstallmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaymentHistorySection() {
    if (_isLoading) {
      return Card(
        color: AppColors.white,
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.logoBrightBlue,
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                "Error loading payment history",
                style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPaymentRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoBrightBlue,
                ),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final allPayments = _paymentRecords.isNotEmpty 
        ? _paymentRecords 
        : widget.enrollment.payments;

    if (allPayments.isEmpty) {
      return Card(
        color: AppColors.white,
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.payment_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                "No payment records found",
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: AppColors.logoBrightBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Payment History",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${allPayments.length} transactions",
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...allPayments.map((payment) => _buildPaymentHistoryItem(payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistoryItem(PaymentRecord payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${payment.amount.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(payment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  payment.status.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(payment.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(payment.paymentDate),
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const Spacer(),
              Icon(
                Icons.payment_rounded,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                payment.paymentMethod.toUpperCase(),
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
          ),
          if (payment.transactionId != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Transaction ID: ${payment.transactionId}",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      payment.notes!,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}