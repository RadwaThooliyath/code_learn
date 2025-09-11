import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/view_model/content_viewmodel.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:uptrail/view/lead_status_page.dart';

class LeadSubmissionPage extends StatefulWidget {
  const LeadSubmissionPage({super.key});

  @override
  State<LeadSubmissionPage> createState() => _LeadSubmissionPageState();
}

class _LeadSubmissionPageState extends State<LeadSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherInterestController = TextEditingController();
  final _careerGoalsController = TextEditingController();
  final _learningTimelineController = TextEditingController();
  final _specificTopicsController = TextEditingController();
  
  String _selectedAreaOfInterest = 'web_development';
  String _selectedCurrentExperience = 'beginner';
  String _selectedBudgetRange = '5000-10000';
  String _selectedPreferredTime = 'weekdays_evening';
  String _selectedContactMethod = 'email';
  bool _isSubmitting = false;

  final List<Map<String, String>> _areasOfInterest = [
    {'value': 'web_development', 'label': 'Web Development'},
    {'value': 'mobile_development', 'label': 'Mobile Development'},
    {'value': 'data_science', 'label': 'Data Science'},
    {'value': 'machine_learning', 'label': 'Machine Learning'},
    {'value': 'cloud_computing', 'label': 'Cloud Computing'},
    {'value': 'cybersecurity', 'label': 'Cybersecurity'},
    {'value': 'devops', 'label': 'DevOps'},
    {'value': 'ui_ux_design', 'label': 'UI/UX Design'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> _experienceLevels = [
    {'value': 'beginner', 'label': 'Beginner (0-1 years)'},
    {'value': 'intermediate', 'label': 'Intermediate (2-3 years)'},
    {'value': 'advanced', 'label': 'Advanced (4+ years)'},
    {'value': 'expert', 'label': 'Expert (10+ years)'},
  ];

  final List<Map<String, String>> _budgetRanges = [
    {'value': '0-5000', 'label': '₹0 - ₹5,000'},
    {'value': '5000-10000', 'label': '₹5,000 - ₹10,000'},
    {'value': '10000-25000', 'label': '₹10,000 - ₹25,000'},
    {'value': '25000-50000', 'label': '₹25,000 - ₹50,000'},
    {'value': '50000+', 'label': '₹50,000+'},
  ];

  final List<Map<String, String>> _timePreferences = [
    {'value': 'weekdays_morning', 'label': 'Weekdays Morning (9 AM - 12 PM)'},
    {'value': 'weekdays_afternoon', 'label': 'Weekdays Afternoon (1 PM - 5 PM)'},
    {'value': 'weekdays_evening', 'label': 'Weekdays Evening (6 PM - 9 PM)'},
    {'value': 'weekend_morning', 'label': 'Weekend Morning (9 AM - 12 PM)'},
    {'value': 'weekend_afternoon', 'label': 'Weekend Afternoon (1 PM - 5 PM)'},
    {'value': 'flexible', 'label': 'Flexible'},
  ];

  final List<Map<String, String>> _contactMethods = [
    {'value': 'email', 'label': 'Email'},
    {'value': 'phone', 'label': 'Phone'},
    {'value': 'whatsapp', 'label': 'WhatsApp'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Try to refresh user profile to get complete data including email and phone
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAndLoadProfile();
    });
  }

  void _loadUserProfile() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.user;
    
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? user.phoneNumber ?? '';
    }
  }

  Future<void> _refreshAndLoadProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    try {
      await authViewModel.refreshUserProfile();
      _loadUserProfile();
    } catch (e) {
      // Profile refresh failed, but continue with existing data
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otherInterestController.dispose();
    _careerGoalsController.dispose();
    _learningTimelineController.dispose();
    _specificTopicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.logoDarkTeal.withValues(alpha: 0.8),
                        AppColors.robinEggBlue.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Start Your Journey',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.small,
                      Text(
                        'Tell us about yourself and we\'ll help you find the perfect course for your career goals.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                AppSpacing.large,
                
                // Form Fields
                _buildFormCard(),
                
                AppSpacing.large,
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brightPinkCrayola,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Submitting...'),
                            ],
                          )
                        : const Text(
                            'Submit Application',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                
                AppSpacing.medium,
                
                // Disclaimer
                Text(
                  'By submitting this form, you agree to be contacted by our team about suitable courses and career opportunities.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card2.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          const Text(
            'Personal Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          AppSpacing.medium,
          
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          AppSpacing.medium,
          
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
          
          AppSpacing.large,
          
          // Course Interest
          const Text(
            'Course Interest',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          
          _buildDropdown(
            value: _selectedAreaOfInterest,
            label: 'Area of Interest',
            items: _areasOfInterest,
            onChanged: (value) {
              setState(() {
                _selectedAreaOfInterest = value!;
              });
            },
          ),
          
          AppSpacing.medium,
          
          // Show other interest field if "Other" is selected
          if (_selectedAreaOfInterest == 'other') ...[
            _buildTextField(
              controller: _otherInterestController,
              label: 'Please specify your area of interest',
              hint: 'Enter your specific area of interest',
              prefixIcon: Icons.info_outline,
              validator: _selectedAreaOfInterest == 'other'
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please specify your area of interest';
                      }
                      return null;
                    }
                  : null,
            ),
            AppSpacing.medium,
          ],
          
          AppSpacing.large,
          
          // Experience & Learning
          const Text(
            'Experience & Learning',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          
          _buildDropdown(
            value: _selectedCurrentExperience,
            label: 'Current Experience Level',
            items: _experienceLevels,
            onChanged: (value) {
              setState(() {
                _selectedCurrentExperience = value!;
              });
            },
          ),
          
          AppSpacing.medium,
          
          _buildTextField(
            controller: _careerGoalsController,
            label: 'Career Goals',
            hint: 'Tell us about your career aspirations',
            prefixIcon: Icons.flag,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please tell us about your career goals';
              }
              return null;
            },
          ),
          
          AppSpacing.medium,
          
          _buildTextField(
            controller: _learningTimelineController,
            label: 'Learning Timeline',
            hint: 'When do you plan to start? (e.g., Immediately, Next month, etc.)',
            prefixIcon: Icons.schedule,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please tell us when you plan to start learning';
              }
              return null;
            },
          ),
          
          AppSpacing.medium,
          
          _buildTextField(
            controller: _specificTopicsController,
            label: 'Specific Topics of Interest (Optional)',
            hint: 'Any specific technologies or topics you want to focus on?',
            prefixIcon: Icons.topic,
            maxLines: 2,
          ),
          
          AppSpacing.large,
          
          // Budget & Timing
          const Text(
            'Budget & Timing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          
          _buildDropdown(
            value: _selectedBudgetRange,
            label: 'Budget Range',
            items: _budgetRanges,
            onChanged: (value) {
              setState(() {
                _selectedBudgetRange = value!;
              });
            },
          ),
          
          AppSpacing.medium,
          
          _buildDropdown(
            value: _selectedPreferredTime,
            label: 'Preferred Class Timing',
            items: _timePreferences,
            onChanged: (value) {
              setState(() {
                _selectedPreferredTime = value!;
              });
            },
          ),
          
          AppSpacing.large,
          
          // Contact Preference
          const Text(
            'Contact Preference',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          
          _buildDropdown(
            value: _selectedContactMethod,
            label: 'Preferred Contact Method',
            items: _contactMethods,
            onChanged: (value) {
              setState(() {
                _selectedContactMethod = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(prefixIcon, color: AppColors.brightPinkCrayola),
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.brightPinkCrayola),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          dropdownColor: AppColors.background,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.brightPinkCrayola),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(
                item['label']!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final lead = LeadSubmission(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        areaOfInterest: _selectedAreaOfInterest,
        otherInterest: _selectedAreaOfInterest == 'other' ? _otherInterestController.text.trim() : null,
        currentExperience: _selectedCurrentExperience,
        careerGoals: _careerGoalsController.text.trim(),
        learningTimeline: _learningTimelineController.text.trim(),
        budgetRange: _selectedBudgetRange,
        preferredTime: _selectedPreferredTime,
        specificTopics: _specificTopicsController.text.trim().isEmpty 
            ? null 
            : _specificTopicsController.text.trim(),
        preferredContactMethod: _selectedContactMethod,
        source: 'mobile_app',
      );

      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
      final response = await contentViewModel.submitLead(lead);

      // Save lead locally for tracking
      print('💾 Saving successful lead submission locally');
      await StorageService.saveSubmittedLead(
        referenceNumber: response.referenceNumber,
        name: lead.name,
        email: lead.email,
        phone: lead.phone,
        areaOfInterest: lead.areaOfInterest,
        estimatedContactTime: response.estimatedContactTime,
        nextSteps: response.nextSteps,
        submittedAt: DateTime.now(),
      );
      print('💾 Lead saved successfully');

      if (mounted) {
        _showSuccessDialog(response);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(LeadSubmissionResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Application Submitted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you for your interest! Your application has been successfully submitted.',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
            AppSpacing.medium,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brightPinkCrayola.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brightPinkCrayola.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference: ${response.referenceNumber}',
                    style: TextStyle(
                      color: AppColors.brightPinkCrayola,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expected Contact: ${response.estimatedContactTime}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (response.nextSteps.isNotEmpty) ...[
              AppSpacing.medium,
              const Text(
                'Next Steps:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.small,
              ...response.nextSteps.map((step) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(color: AppColors.brightPinkCrayola),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous page
            },
            child: Text(
              'Done',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeadStatusPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brightPinkCrayola,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Applications'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Submission Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          error,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Try Again',
              style: TextStyle(color: AppColors.brightPinkCrayola),
            ),
          ),
        ],
      ),
    );
  }
}