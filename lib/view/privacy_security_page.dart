import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/widgets/security_wrapper.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SecurityWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Privacy & Security',
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
              _buildSecurityStatus(),
              const SizedBox(height: 24),
              _buildPrivacySection(),
              const SizedBox(height: 24),
              _buildSecuritySection(),
              const SizedBox(height: 24),
              _buildDataProtectionSection(),
              const SizedBox(height: 24),
              _buildComplianceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
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
                  Icons.security,
                  color: Colors.green[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Security Status',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSecurityStatusItem(
              'Screenshot Prevention',
              'Active',
              Icons.screenshot_monitor,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSecurityStatusItem(
              'Screen Recording Protection',
              'Active',
              Icons.videocam_off,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSecurityStatusItem(
              'Data Encryption',
              'Enabled',
              Icons.lock,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildSecurityStatusItem(
              'Secure Authentication',
              'Active',
              Icons.verified_user,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusItem(String title, String status, IconData icon, Color statusColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
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
                  Icons.privacy_tip,
                  color: AppColors.logoBrightBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Privacy Matters',
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
              'Data Collection',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• We collect only essential data needed for course delivery and progress tracking\n'
              '• Personal information is encrypted and securely stored\n'
              '• No data is shared with third parties without your consent\n'
              '• Course progress and learning analytics remain private to you',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Rights',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Access your personal data anytime\n'
              '• Request data correction or deletion\n'
              '• Opt-out of non-essential communications\n'
              '• Export your learning data and progress',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
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
                  Icons.shield,
                  color: Colors.amber[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Security Measures',
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
              'Content Protection',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Screenshots are automatically prevented on all course content\n'
              '• Screen recording detection and blocking technology\n'
              '• PDF resources are view-only with download restrictions\n'
              '• Video content includes anti-piracy watermarking',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Account Security',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Secure authentication with token-based sessions\n'
              '• Automatic session timeout for inactive accounts\n'
              '• Password encryption using industry standards\n'
              '• Login attempt monitoring and protection',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataProtectionSection() {
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
                  Icons.data_usage,
                  color: Colors.purple[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Data Protection',
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
              'Storage & Encryption',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• All data is encrypted both in transit and at rest\n'
              '• Regular security audits and penetration testing\n'
              '• Automated backups with encryption\n'
              '• Secure cloud infrastructure with 99.9% uptime',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Data Retention',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Course progress data retained for 3 years after completion\n'
              '• Personal data deleted within 30 days of account closure\n'
              '• Temporary files automatically cleaned\n'
              '• Log data retained for security purposes only',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceSection() {
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
                  Icons.gavel,
                  color: Colors.indigo[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Compliance & Standards',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildComplianceItem('GDPR Compliant', 'European data protection standards'),
            const SizedBox(height: 12),
            _buildComplianceItem('ISO 27001', 'Information security management'),
            const SizedBox(height: 12),
            _buildComplianceItem('SOC 2 Type II', 'Security and availability controls'),
            const SizedBox(height: 12),
            _buildComplianceItem('COPPA Compliant', 'Children\'s online privacy protection'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Concerns?',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If you have any security concerns or privacy questions, please contact our security team immediately.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to support or show contact info
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Contact Security Team',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildComplianceItem(String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.green[600],
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
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
}