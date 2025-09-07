import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/widgets/security_wrapper.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedCategory = 'Technical Issue';

  final List<String> _categories = [
    'Technical Issue',
    'Account Problem',
    'Course Content',
    'Payment & Billing',
    'Feature Request',
    'Bug Report',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SecurityWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Help & Support',
            style: AppTextStyle.headline2,
          ),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildFAQSection(),
              const SizedBox(height: 24),
              _buildContactForm(),
              const SizedBox(height: 24),
              _buildContactInfo(),
              const SizedBox(height: 24),
              _buildSupportHours(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Help',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Live Chat',
                    Icons.chat,
                    Colors.green,
                    () => _showComingSoon('Live Chat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Call Support',
                    Icons.phone,
                    Colors.blue,
                    () => _launchPhone('+919895663498'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Email Support',
                    Icons.email,
                    Colors.orange,
                    () => _launchEmail(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Video Guide',
                    Icons.play_circle,
                    Colors.red,
                    () => _showComingSoon('Video Guides'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz,
                  color: AppColors.logoBrightBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'How do I reset my password?',
              'Go to the login screen and tap "Forgot Password". Enter your email address and we\'ll send you reset instructions.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              'Can I download course videos?',
              'For security reasons, course videos cannot be downloaded. However, you have unlimited access to stream them while your course is active.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              'Why can\'t I take screenshots?',
              'We prevent screenshots to protect course content and intellectual property. This ensures fair access for all learners.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              'How do I track my progress?',
              'Your progress is automatically saved as you complete lessons. Check the progress bar on each course and lesson page.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              'What if I encounter technical issues?',
              'Try restarting the app first. If the problem persists, contact our support team using the form below or email us directly.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
      iconColor: AppColors.logoBrightBlue,
      collapsedIconColor: Colors.grey[600],
    );
  }

  Widget _buildContactForm() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: Colors.green[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Subject',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Brief description of your issue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.logoBrightBlue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Message',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Please describe your issue in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.logoBrightBlue),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitSupportRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoBrightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_support,
                  color: Colors.purple[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'uptraillearnign@gmail.com', 'Email Support'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.phone, '+91 98956 63498', 'Phone Support'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.location_on, 'KIMS avenue, Perinthalmanna, Kerala', 'Office Location'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.web, 'https://uptrail.info/help', 'Online Help Center'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String info, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportHours() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.indigo[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Support Hours',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSupportHourItem('Monday - Friday', '9:00 AM - 6:00 PM PST'),
            const SizedBox(height: 8),
            _buildSupportHourItem('Saturday', '10:00 AM - 4:00 PM PST'),
            const SizedBox(height: 8),
            _buildSupportHourItem('Sunday', 'Closed (Emergency support only)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We aim to respond to all inquiries within 24 hours during business days.',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHourItem(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _submitSupportRequest() {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both subject and message fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would typically send the support request to your backend
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('Request Submitted'),
          ],
        ),
        content: const Text(
          'Your support request has been submitted successfully. We\'ll get back to you within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _subjectController.clear();
              _messageController.clear();
              setState(() {
                _selectedCategory = 'Technical Issue';
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.logoBrightBlue,
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'uptraillearnign@gmail.com',
      query: 'subject=Support Request&body=Please describe your issue here...',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app. Please email us at uptraillearnign@gmail.com'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call. Please dial $phoneNumber'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}