import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/assignment_model.dart';
import 'package:uptrail/services/assignment_service.dart';
import 'package:uptrail/utils/app_text_style.dart';

class AssignmentSubmissionPage extends StatefulWidget {
  final Assignment assignment;

  const AssignmentSubmissionPage({
    super.key,
    required this.assignment,
  });

  @override
  State<AssignmentSubmissionPage> createState() => _AssignmentSubmissionPageState();
}

class _AssignmentSubmissionPageState extends State<AssignmentSubmissionPage> {
  final AssignmentService _assignmentService = AssignmentService();
  final TextEditingController _githubUrlController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isSubmitting = false;
  AssignmentSubmission? _existingSubmission;

  @override
  void initState() {
    super.initState();
    _loadExistingSubmission();
  }

  @override
  void dispose() {
    _githubUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSubmission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final submissions = await _assignmentService.getMyAssignmentSubmissions();
      final existingSubmission = submissions.where(
        (submission) => submission.assignment == widget.assignment.id,
      ).firstOrNull;

      if (existingSubmission != null) {
        setState(() {
          _existingSubmission = existingSubmission;
          _githubUrlController.text = existingSubmission.githubUrl ?? '';
          _notesController.text = existingSubmission.submissionNotes ?? '';
        });
      }
    } catch (e) {
      print("Failed to load existing submission: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_existingSubmission != null) {
        // Update existing submission
        await _assignmentService.updateAssignmentSubmission(
          submissionId: _existingSubmission!.id,
          githubUrl: _githubUrlController.text,
          submissionNotes: _notesController.text,
          status: 'draft',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Draft saved successfully")),
        );
      } else {
        // Create new submission
        final submission = await _assignmentService.createAssignmentSubmission(
          assignmentId: widget.assignment.id,
          githubUrl: _githubUrlController.text,
          submissionNotes: _notesController.text,
          status: 'draft',
        );
        setState(() {
          _existingSubmission = submission;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Draft saved successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving draft: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      AssignmentSubmission submission;
      
      if (_existingSubmission != null) {
        // Update and submit existing submission
        submission = await _assignmentService.updateAssignmentSubmission(
          submissionId: _existingSubmission!.id,
          githubUrl: _githubUrlController.text,
          submissionNotes: _notesController.text,
          status: 'submitted',
        );
      } else {
        // Create and submit new submission
        submission = await _assignmentService.createAssignmentSubmission(
          assignmentId: widget.assignment.id,
          githubUrl: _githubUrlController.text,
          submissionNotes: _notesController.text,
          status: 'submitted',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment submitted successfully!")),
      );
      
      Navigator.of(context).pop(submission);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting assignment: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Submit Assignment",
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAssignmentInfo(),
                    const SizedBox(height: 24),
                    _buildSubmissionForm(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAssignmentInfo() {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assignment.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.assignment.description,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.score, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  "Max Points: ${widget.assignment.maxPoints}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  "Due: ${widget.assignment.dueDays} days",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            if (_existingSubmission != null) ...[
              const SizedBox(height: 16),
              _buildDetailedStatusSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionForm() {
    final canEdit = _existingSubmission?.status != 'submitted' && 
                   _existingSubmission?.status != 'graded';

    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Submission Details",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubUrlController,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: "GitHub Repository URL *",
                hintText: "https://github.com/username/repository",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter GitHub URL';
                }
                if (!value.contains('github.com')) {
                  return 'Please enter a valid GitHub URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              enabled: canEdit,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Submission Notes (Optional)",
                hintText: "Add any additional notes about your submission...",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            if (!canEdit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This assignment has been submitted and cannot be edited.",
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final canEdit = _existingSubmission?.status != 'submitted' && 
                   _existingSubmission?.status != 'graded';

    if (!canEdit) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading || _isSubmitting ? null : _saveDraft,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.logoBrightBlue),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    "Save Draft",
                    style: TextStyle(color: AppColors.logoBrightBlue),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading || _isSubmitting ? null : _submitAssignment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoBrightBlue,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Submit Assignment",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStatusSection() {
    if (_existingSubmission == null) return const SizedBox.shrink();

    final submission = _existingSubmission!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(submission.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(submission.status),
                color: _getStatusColor(submission.status),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Submission Status",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusDetailRow("Status", submission.status.toUpperCase().replaceAll('_', ' ')),
          if (submission.submittedAt != null)
            _buildStatusDetailRow("Submitted At", _formatDateTime(submission.submittedAt!)),
          if (submission.score != null) ...[
            _buildStatusDetailRow("Score", "${submission.score}/${widget.assignment.maxPoints}"),
            _buildStatusDetailRow("Score %", "${submission.scorePercentage.toStringAsFixed(1)}%"),
            _buildStatusDetailRow("Passed", submission.isPassed ? "Yes" : "No"),
          ],
          if (submission.gradedAt != null)
            _buildStatusDetailRow("Graded At", _formatDateTime(submission.gradedAt!)),
          if (submission.gradeComments != null && submission.gradeComments!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              "Grade Comments:",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              submission.gradeComments!,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(submission.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getStatusMessage(submission.status),
              style: TextStyle(
                color: _getStatusColor(submission.status),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
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

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return "Submitted - Awaiting Review";
      case 'graded':
        return "Graded - Review Complete";
      case 'draft':
        return "Draft - Not Yet Submitted";
      default:
        return "Unknown Status";
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