import 'package:uptrail/app_constants/button.dart';
import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:uptrail/view/edit_profile.dart';
import 'package:uptrail/view/privacy_security_page.dart';
import 'package:uptrail/view/help_support_page.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile data and enrolled courses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
      
      authViewModel.refreshUserProfile();
      courseViewModel.fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return IconButton(
                icon: authViewModel.isLoadingProfile 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
                onPressed: authViewModel.isLoadingProfile 
                  ? null 
                  : () {
                      authViewModel.refreshUserProfile();
                    },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthViewModel, CourseViewModel>(
        builder: (context, authViewModel, courseViewModel, child) {
          final user = authViewModel.user;
          final enrolledCourses = courseViewModel.enrolledCourses;
          
          if (user == null) {
            return const Center(
              child: Text(
                'No user data available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              children: [
                // Compact Profile Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.logoBrightBlue, AppColors.logoGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getUserInitials(user.name ?? "U"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? "User",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? "No email",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatRole(user.role ?? "student"),
                                style: TextStyle(
                                  color: AppColors.logoBrightBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat("Courses", "${enrolledCourses.length}", Icons.school, Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStat("Completed", "0", Icons.check_circle, Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStat("Progress", "${enrolledCourses.length}", Icons.trending_up, Colors.orange),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Account Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Account Details",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if ((user.phoneNumber ?? user.phone) != null)
                        _buildDetailRow(Icons.phone, "Phone", (user.phoneNumber ?? user.phone)!),
                      if (user.dateJoined != null)
                        _buildDetailRow(Icons.calendar_today, "Member since", _formatDate(user.dateJoined!)),
                      _buildDetailRow(Icons.badge, "User ID", "#${user.id ?? "N/A"}"),
                      if (user.lastLogin != null)
                        _buildDetailRow(Icons.access_time, "Last active", _formatDate(user.lastLogin!)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Settings/Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildActionRow(Icons.edit, "Edit Profile", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfilePage()),
                        );
                      }),
                      _buildActionRow(Icons.security, "Privacy & Security", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacySecurityPage()),
                        );
                      }),
                      _buildActionRow(Icons.help_outline, "Help & Support", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                        );
                      }),
                      _buildActionRow(Icons.delete_forever, "Delete Account", () {
                        _showDeleteAccountConfirmDialog();
                      }, isDestructive: true),
                      _buildActionRow(Icons.logout, "Sign Out", () async {
                        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                        await authViewModel.logout();
                      }, isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isDestructive ? Colors.red : Colors.black54, 
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive ? Colors.red : Colors.black26,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getUserInitials(String name) {
    if (name.isEmpty) return "U";
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatRole(String role) {
    return role.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else if (difference < 7) {
      return "$difference days ago";
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? "1 week ago" : "$weeks weeks ago";
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return months == 1 ? "1 month ago" : "$months months ago";
    } else {
      final years = (difference / 365).floor();
      return years == 1 ? "1 year ago" : "$years years ago";
    }
  }

  void _showDeleteAccountConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Delete Account',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This action will permanently:',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Delete your account and profile',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                '• Remove all enrollment details',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                '• Clear all learning progress',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              Text(
                '• Cancel active subscriptions',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Payment records will be preserved for tax purposes.',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Deleting account...',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        );
      },
    );

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final result = await authViewModel.deleteAccount();

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        // Show success message and logout
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Wait a moment then logout (which will navigate to login)
        await Future.delayed(const Duration(seconds: 1));
        await authViewModel.logout();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}