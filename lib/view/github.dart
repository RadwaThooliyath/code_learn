import 'package:uptrail/app_constants/button.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:flutter/material.dart';

class AssignmentSubmissionPage extends StatefulWidget {
  const AssignmentSubmissionPage({super.key});

  @override
  State<AssignmentSubmissionPage> createState() => _AssignmentSubmissionPageState();
}

class _AssignmentSubmissionPageState extends State<AssignmentSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _validateGitHubLink(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the GitHub link';
    }

    // Basic validation for GitHub URL
    final pattern = r'^https:\/\/github\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$';
    final regex = RegExp(pattern);

    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid GitHub repo link';
    }

    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Perform submit logic here
      final githubLink = _linkController.text.trim();
      final notes = _noteController.text.trim();

      // Show success or move to next screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Submit Assignment',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assignment Title',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Submit your assignment using a GitHub repository link or similar.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // GitHub Link Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _linkController,
                  style: const TextStyle(color: Colors.white),
                  validator: _validateGitHubLink,
                  decoration: const InputDecoration(
                    hintText: 'Enter GitHub repository link',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    icon: Icon(Icons.link, color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a note or comment...',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              Center(
                child: Button(
                  text: "Submit",
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
