import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/services/enrollment_service.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';

class WhatsAppSupportDialog extends StatefulWidget {
  const WhatsAppSupportDialog({super.key});

  @override
  State<WhatsAppSupportDialog> createState() => _WhatsAppSupportDialogState();
}

class _WhatsAppSupportDialogState extends State<WhatsAppSupportDialog> {
  final TextEditingController _queryController = TextEditingController();
  final EnrollmentService _enrollmentService = EnrollmentService();
  bool _isLoading = false;
  List<String> _enrolledCourses = [];

  @override
  void initState() {
    super.initState();
    _loadEnrolledCourses();
  }

  Future<void> _loadEnrolledCourses() async {
    setState(() => _isLoading = true);
    try {
      final enrollments = await _enrollmentService.getMyEnrollments();
      if (enrollments != null) {
        setState(() {
          _enrolledCourses = enrollments
              .map((enrollment) => enrollment.courseName ?? 'Course')
              .toList();
        });
      }
    } catch (e) {
      print('Error loading enrolled courses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openWhatsApp(String userQuery, AuthViewModel authViewModel) async {
    final user = authViewModel.user;
    if (user == null) return;

    // Format the message
    final message = '''
Hello Uptrail Support! 👋

*User Details:*
• Name: ${user.name ?? 'Not provided'}
• Email: ${user.email ?? 'Not provided'}
• User ID: ${user.id ?? 'Not provided'}

*Enrolled Courses:*
${_enrolledCourses.isEmpty ? '• No courses enrolled yet' : _enrolledCourses.map((course) => '• $course').join('\\n')}

*Query:*
$userQuery

Please assist me with this matter. Thank you!
''';

    // WhatsApp support number - replace with your actual support number
    const supportNumber = '+919895663498'; // Replace with actual WhatsApp support number
    
    final whatsappUrl = 'https://wa.me/$supportNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Navigator.of(context).pop(); // Close the dialog
      } else {
        _showErrorSnackBar('WhatsApp is not installed on this device');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open WhatsApp: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDecoration.borderRadiusL,
      ),
      child: Container(
        padding: AppSpacing.paddingL,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDecoration.borderRadiusL,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366), // WhatsApp green
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                AppSpacing.hMedium,
                const Expanded(
                  child: Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            AppSpacing.medium,
            
            // Description
            Text(
              'Describe your issue or question below. We\'ll include your profile and course details automatically.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            AppSpacing.medium,
            
            // Query input
            TextField(
              controller: _queryController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your question or describe the issue...',
                border: OutlineInputBorder(
                  borderRadius: AppDecoration.borderRadiusM,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppDecoration.borderRadiusM,
                  borderSide: const BorderSide(color: AppColors.robinEggBlue),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            AppSpacing.medium,
            
            // Enrolled courses preview
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Container(
                padding: AppSpacing.paddingM,
                decoration: BoxDecoration(
                  color: AppColors.green1.withValues(alpha: 0.1),
                  borderRadius: AppDecoration.borderRadiusM,
                  border: Border.all(color: AppColors.green1.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Enrolled Courses:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_enrolledCourses.isEmpty)
                      Text(
                        'No courses enrolled yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      ...(_enrolledCourses.take(3).map(
                        (course) => Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '• $course',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )),
                    if (_enrolledCourses.length > 3)
                      Text(
                        '+${_enrolledCourses.length - 3} more courses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            AppSpacing.large,
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDecoration.borderRadiusM,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)], // WhatsApp gradient
                      ),
                      borderRadius: AppDecoration.borderRadiusM,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_queryController.text.trim().isEmpty) {
                          _showErrorSnackBar('Please enter your question or issue');
                          return;
                        }
                        
                        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                        _openWhatsApp(_queryController.text.trim(), authViewModel);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDecoration.borderRadiusM,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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