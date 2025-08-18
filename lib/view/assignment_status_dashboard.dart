import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/assignment_model.dart';
import 'package:uptrail/services/assignment_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/view/assignment_submission_page.dart';

class AssignmentStatusDashboard extends StatefulWidget {
  const AssignmentStatusDashboard({super.key});

  @override
  State<AssignmentStatusDashboard> createState() => _AssignmentStatusDashboardState();
}

class _AssignmentStatusDashboardState extends State<AssignmentStatusDashboard> {
  final AssignmentService _assignmentService = AssignmentService();
  List<AssignmentSubmission> _submissions = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAssignmentStatuses();
  }

  Future<void> _loadAssignmentStatuses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final submissions = await _assignmentService.getMyAssignmentSubmissions();
      setState(() {
        _submissions = submissions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading assignments: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AssignmentSubmission> get _filteredSubmissions {
    if (_selectedFilter == 'all') return _submissions;
    return _submissions.where((submission) => 
      submission.status.toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Assignment Status",
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.logoBrightBlue,
              ),
            )
          : Column(
              children: [
                _buildFilterChips(),
                _buildStatusSummary(),
                Expanded(
                  child: _submissions.isEmpty
                      ? _buildEmptyState()
                      : _buildAssignmentsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('draft', 'Drafts'),
            const SizedBox(width: 8),
            _buildFilterChip('submitted', 'Submitted'),
            const SizedBox(width: 8),
            _buildFilterChip('graded', 'Graded'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: AppColors.champagnePink,
      selectedColor: AppColors.logoBrightBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusSummary() {
    final totalAssignments = _submissions.length;
    final draftCount = _submissions.where((s) => s.status == 'draft').length;
    final submittedCount = _submissions.where((s) => s.status == 'submitted').length;
    final gradedCount = _submissions.where((s) => s.status == 'graded').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Assignment Summary",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSummaryItem("Total", totalAssignments, Colors.grey)),
              Expanded(child: _buildSummaryItem("Drafts", draftCount, Colors.orange)),
              Expanded(child: _buildSummaryItem("Submitted", submittedCount, Colors.blue)),
              Expanded(child: _buildSummaryItem("Graded", gradedCount, Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            "No assignments found",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            "Complete some course assignments to see them here",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsList() {
    final filteredSubmissions = _filteredSubmissions;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSubmissions.length,
      itemBuilder: (context, index) {
        final submission = filteredSubmissions[index];
        return _buildAssignmentCard(submission);
      },
    );
  }

  Widget _buildAssignmentCard(AssignmentSubmission submission) {
    return Card(
      color: AppColors.champagnePink,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToAssignmentDetail(submission),
        borderRadius: BorderRadius.circular(8),
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
                          submission.assignmentTitle,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Course: ${submission.studentName}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(submission.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(submission.status),
                          size: 16,
                          color: _getStatusColor(submission.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          submission.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(submission.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (submission.score != null) ...[
                    Icon(Icons.grade, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      "Score: ${submission.score}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (submission.submittedAt != null) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      "Submitted: ${_formatDate(submission.submittedAt!)}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ],
              ),
              if (submission.gradeComments != null && submission.gradeComments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Comment: ${submission.gradeComments!}",
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAssignmentDetail(AssignmentSubmission submission) {
    // For now, show a simple dialog. In a real app, you might navigate to a detailed assignment page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.champagnePink,
        title: Text(
          submission.assignmentTitle,
          style: const TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${submission.status}"),
            if (submission.score != null)
              Text("Score: ${submission.score}/${submission.scorePercentage}%"),
            if (submission.submittedAt != null)
              Text("Submitted: ${_formatDateTime(submission.submittedAt!)}"),
            if (submission.gradedAt != null)
              Text("Graded: ${_formatDateTime(submission.gradedAt!)}"),
            if (submission.gradeComments != null && submission.gradeComments!.isNotEmpty)
              Text("Comments: ${submission.gradeComments!}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.check_circle;
      case 'graded':
        return Icons.grade;
      case 'draft':
        return Icons.edit;
      default:
        return Icons.assignment;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Colors.blue;
      case 'graded':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}