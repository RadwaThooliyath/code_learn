import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/model/assignment_model.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/services/assignment_service.dart';
import 'package:uptrail/services/quiz_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/assignment_submission_page.dart';
import 'package:uptrail/view/assignment_status_dashboard.dart';
import 'package:uptrail/view/video_lesson_player.dart';
import 'package:uptrail/view/quiz_taking_page.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/services/payment_service.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  final AssignmentService _assignmentService = AssignmentService();
  final QuizService _quizService = QuizService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final PaymentService _paymentService = PaymentService();
  
  Map<int, List<Assignment>> _moduleAssignments = {};
  Map<int, List<Quiz>> _moduleQuizzes = {};
  Map<int, bool> _quizPassedStatus = {}; // Track quiz pass status
  Map<int, int> _quizAttemptCounts = {}; // Track attempt counts
  Map<int, bool> _canRetakeQuiz = {}; // Track if quiz can be retaken
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _paymentService.initialize();
    _loadCourseContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadCourseContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load assignments and quizzes for each module
      if (widget.course.modules != null) {
        for (final module in widget.course.modules!) {
          await _loadModuleAssignments(module.id);
          await _loadModuleQuizzes(module.id);
        }
      }
    } catch (e) {
      print("Error loading course content: $e");
    } finally {
      setState(() {
        _isLoading = false;
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
      print("Failed to load assignments for module $moduleId: $e");
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
      print("Failed to load quizzes for module $moduleId: $e");
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
        // Can retake if:
        // 1. Haven't passed and have attempts remaining, OR
        // 2. Have passed but quiz allows retakes (some quizzes might allow this)
        canRetake = (!hasPassed && attemptCount < quiz.maxAttempts);
      }
      
      setState(() {
        _quizPassedStatus[quizId] = hasPassed;
        _quizAttemptCounts[quizId] = attemptCount;
        _canRetakeQuiz[quizId] = canRetake;
      });
    } catch (e) {
      print("Failed to load quiz pass status for quiz $quizId: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.course.title,
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.logoBrightBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline),
              text: "Overview",
            ),
            Tab(
              icon: Icon(Icons.school),
              text: "Content",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildContentTab(),
        ],
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
          _buildEnrollmentSection(),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.course.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.course.thumbnailUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.book,
                            size: 50,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.course.category != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.course.category!,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (widget.course.isEnrolled == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "ENROLLED",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.course.description,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildElegantStatItem(
                          Icons.library_books,
                          widget.course.modules?.length.toString() ?? "0",
                          "Modules",
                        ),
                      ),
                      Expanded(
                        child: _buildElegantStatItem(
                          Icons.play_circle,
                          _getTotalLessons().toString(),
                          "Lessons",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildElegantStatItem(
                          Icons.assignment,
                          _getTotalAssignments().toString(),
                          "Assignments",
                        ),
                      ),
                      Expanded(
                        child: _buildElegantStatItem(
                          Icons.quiz,
                          _getTotalQuizzes().toString(),
                          "Quizzes",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildElegantStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.logoBrightBlue),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 20,
      width: 1,
      color: Colors.black26,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildContentTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.logoBrightBlue,
        ),
      );
    }

    if (widget.course.modules == null || widget.course.modules!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              "No modules available",
              style: TextStyle(color: Colors.white70, fontSize: 18),
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
          ...widget.course.modules!.map((module) => _buildModuleCard(module)),
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
            "Lessons",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...lessons.map((lesson) => Card(
            color: Colors.white,
            child: ListTile(
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
              onTap: lesson.type == 'video' && lesson.videoUrl != null
                  ? () => _openVideoLesson(lesson)
                  : null,
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Assignments",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AssignmentStatusDashboard(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard, size: 16, color: AppColors.logoBrightBlue),
                    SizedBox(width: 4),
                    Text(
                      "View All",
                      style: TextStyle(
                        color: AppColors.logoBrightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                Text(
                  "Max Points: ${assignment.maxPoints} • Due: ${assignment.dueDays} days",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getAssignmentStatusIcon(assignment.submissionStatus),
                      size: 14,
                      color: _getAssignmentStatusColor(assignment.submissionStatus),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getAssignmentStatusMessage(assignment.submissionStatus),
                      style: TextStyle(
                        color: _getAssignmentStatusColor(assignment.submissionStatus),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _buildAssignmentStatusChip(assignment.submissionStatus),
            onTap: () => _showAssignmentDetail(assignment),
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
            "Quizzes",
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
                    color: isPassed ? Colors.green[100] : AppColors.logoBrightBlue.withValues(alpha: 0.1),
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
                subtitle: Text(
                  "Questions: ${quiz.questions.length} • Points: ${quiz.maxPoints} • Attempts: $attemptCount/${quiz.maxAttempts}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
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

  void _openVideoLesson(Lesson lesson) async {
    if (lesson.videoUrl != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoLessonPlayer(
            lesson: lesson,
            courseId: widget.course.id,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No video URL available")),
      );
    }
  }

  void _showAssignmentDetail(Assignment assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.champagnePink,
          title: Text(
            assignment.title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  assignment.description,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                _buildAssignmentDetailRow("Max Points", assignment.maxPoints.toString()),
                _buildAssignmentDetailRow("Passing Score", assignment.passingScore.toString()),
                _buildAssignmentDetailRow("Due Days", "${assignment.dueDays} days"),
                _buildAssignmentDetailRow("Required", assignment.isRequired ? "Yes" : "No"),
                _buildAssignmentDetailRow("Status", assignment.submissionStatus.replaceAll('_', ' ').toUpperCase()),
                if (assignment.requirements.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Requirements:",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.requirements,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
                if (assignment.resources.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Resources:",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.resources,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close", style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAssignmentSubmission(assignment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text("Submit Assignment", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignmentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAssignmentSubmission(Assignment assignment) async {
    try {
      print("🎯 Navigating to assignment submission for: ${assignment.title}");
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssignmentSubmissionPage(assignment: assignment),
        ),
      );
      print("✅ Returned from assignment submission page");
      // Refresh assignments after returning
      _loadCourseContent();
    } catch (e) {
      print("❌ Error navigating to assignment submission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error opening assignment: $e")),
      );
    }
  }

  void _startQuiz(Quiz quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingPage(quiz: quiz),
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
        color: _getAssignmentStatusColor(status).withValues(alpha: 0.2),
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

  int _getTotalAssignments() {
    return _moduleAssignments.values
        .fold(0, (total, assignments) => total + assignments.length);
  }

  int _getTotalQuizzes() {
    return _moduleQuizzes.values
        .fold(0, (total, quizzes) => total + quizzes.length);
  }

  int _getTotalLessons() {
    if (widget.course.modules == null) return 0;
    
    return widget.course.modules!
        .fold(0, (total, module) => total + (module.lessons?.length ?? 0));
  }

  IconData _getAssignmentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.check_circle;
      case 'graded':
        return Icons.grade;
      case 'draft':
        return Icons.edit;
      case 'not_submitted':
      default:
        return Icons.assignment;
    }
  }

  String _getAssignmentStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return "Submitted - Awaiting Review";
      case 'graded':
        return "Graded - Review Complete";
      case 'draft':
        return "Draft Saved";
      case 'not_submitted':
      default:
        return "Not Started";
    }
  }

  Widget _buildEnrollmentSection() {
    // Show enrollment button only if:
    // 1. Course allows public enrollment
    // 2. User is not already enrolled
    // 3. Course is free (for now - can extend to paid courses later)
    
    final canEnroll = widget.course.allowPublicEnrollment == true && 
                     widget.course.isEnrolled != true;
    
    if (!canEnroll) {
      return const SizedBox.shrink();
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
                  widget.course.isFree ? Icons.school : Icons.paid,
                  color: AppColors.logoBrightBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.course.isFree ? "Free Course" : "Paid Course",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!widget.course.isFree && widget.course.price != null)
                  Text(
                    widget.course.priceDisplay ?? "\$${widget.course.price}",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.course.isFree 
                  ? "Enroll for free and start learning immediately!"
                  : "Purchase this course to get lifetime access to all content.",
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleEnrollment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoBrightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  widget.course.isFree ? "Enroll for Free" : "Purchase Course",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEnrollment() async {
    try {
      Map<String, dynamic> result;
      
      if (widget.course.isFree) {
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
        result = await _enrollmentService.enrollInCourse(widget.course.id);
        
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
      } else {
        // Use payment service for paid courses
        result = await _paymentService.initiateCoursePayment(
          context: context,
          course: widget.course,
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
        
        // Update the course state to reflect enrollment
        setState(() {
          // This would ideally come from a proper state management solution
          // For now, we'll refresh the page or navigate back
        });
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
      if (widget.course.isFree && mounted) {
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
              if (success) {
                // Refresh the page or navigate to enrolled courses
                Navigator.of(context).pop(); // Go back to course list
              }
            },
            child: Text(
              success ? "Continue" : "OK",
              style: const TextStyle(color: AppColors.logoBrightBlue),
            ),
          ),
        ],
      ),
    );
  }
}