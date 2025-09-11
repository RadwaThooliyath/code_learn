import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:uptrail/view/edit_profile.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/app_spacing.dart';
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
        title: Text(
          'Profile',
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          // Edit Profile Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: 'Edit Profile',
          ),
          // Logout Button

        ],
      ),
      body: Consumer2<AuthViewModel, CourseViewModel>(
        builder: (context, authViewModel, courseViewModel, child) {
          final user = authViewModel.user;
          final enrolledCourses = courseViewModel.enrolledCourses;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.robinEggBlue,
              ),
            );
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                // Profile Header Card
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingXL,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.logoDarkTeal,
                        AppColors.brightPinkCrayola.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppDecoration.borderRadiusXL,
                    boxShadow: AppDecoration.mediumShadow,
                  ),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.brightPinkCrayola,
                              AppColors.coral,
                            ],
                          ),
                          boxShadow: AppDecoration.softShadow,
                        ),
                        child: Center(
                          child: Text(
                            _getUserInitials(user.name ?? "U"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      
                      AppSpacing.medium,
                      
                      // Name
                      Text(
                        user.name ?? "Unknown User",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      AppSpacing.small,
                      
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppDecoration.borderRadiusXL,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatRole(user.role ?? "student"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                AppSpacing.large,
                
                // Personal Information Card
                _buildInfoCard(
                  title: "Personal Information",
                  icon: Icons.person,
                  children: [
                    _buildInfoTile(
                      icon: Icons.email,
                      title: "Email",
                      subtitle: user.email ?? "Not provided",
                    ),
                    if ((user.phoneNumber ?? user.phone) != null && (user.phoneNumber ?? user.phone)!.isNotEmpty)
                      _buildInfoTile(
                        icon: Icons.phone,
                        title: "Phone",
                        subtitle: (user.phoneNumber ?? user.phone)!,
                      ),
                    if (user.address != null && user.address!.isNotEmpty)
                      _buildInfoTile(
                        icon: Icons.location_on,
                        title: "Address",
                        subtitle: user.address!,
                        maxLines: 2,
                      ),
                  ],
                ),
                
                AppSpacing.medium,
                
                // Account Information Card
                _buildInfoCard(
                  title: "Account Information",
                  icon: Icons.badge,
                  children: [
                    _buildInfoTile(
                      icon: Icons.tag,
                      title: "User ID",
                      subtitle: "#${user.id ?? "N/A"}",
                    ),
                    if (user.dateJoined != null)
                      _buildInfoTile(
                        icon: Icons.calendar_today,
                        title: "Member Since",
                        subtitle: _formatDate(user.dateJoined!),
                      ),
                    if (user.lastLogin != null)
                      _buildInfoTile(
                        icon: Icons.access_time,
                        title: "Last Active",
                        subtitle: _formatDate(user.lastLogin!),
                      ),
                  ],
                ),
                
                AppSpacing.medium,
                
                // Learning Progress Card
                _buildStatsCard(enrolledCourses),
                
                // Add bottom padding to ensure content is above navigation bar
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
          borderRadius: AppDecoration.borderRadiusS,
        color: AppColors.champagnePink
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingS,
                decoration: BoxDecoration(
                  color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                  borderRadius: AppDecoration.borderRadiusS,
                ),
                child: Icon(
                  icon,
                  color: AppColors.logoBrightBlue,
                  size: 20,
                ),
              ),
              AppSpacing.hSmall,
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          AppSpacing.medium,
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.robinEggBlue.withValues(alpha: 0.1),
              borderRadius: AppDecoration.borderRadiusS,
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.robinEggBlue,
            ),
          ),
          AppSpacing.hSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List enrolledCourses) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingL,
      decoration: BoxDecoration(
        borderRadius: AppDecoration.borderRadiusS,
        color: AppColors.champagnePink,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingS,
                decoration: BoxDecoration(
                  color: AppColors.green1.withValues(alpha: 0.1),
                  borderRadius: AppDecoration.borderRadiusS,
                ),
                child: Icon(
                  Icons.school,
                  color: AppColors.green1,
                  size: 20,
                ),
              ),
              AppSpacing.hSmall,
              const Text(
                "Learning Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          AppSpacing.medium,
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Enrolled",
                  "${enrolledCourses.length}",
                  AppColors.logoBrightBlue,
                  Icons.book,
                ),
              ),
              AppSpacing.hSmall,
              Expanded(
                child: _buildStatItem(
                  "Completed",
                  "0",
                  AppColors.green1,
                  Icons.check_circle,
                ),
              ),
              AppSpacing.hSmall,
              Expanded(
                child: _buildStatItem(
                  "In Progress",
                  "${enrolledCourses.length}",
                  AppColors.coral,
                  Icons.play_circle,
                ),
              ),
            ],
          ),
          
          if (enrolledCourses.isNotEmpty) ...[
            AppSpacing.medium,
            const Divider(),
            AppSpacing.small,
            Text(
              "Current Courses",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            AppSpacing.small,
            ...enrolledCourses.take(3).map((course) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.logoBrightBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.hSmall,
                    Expanded(
                      child: Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (enrolledCourses.length > 3)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  "+${enrolledCourses.length - 3} more courses",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Container(
      padding: AppSpacing.paddingM,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppDecoration.borderRadiusM,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          AppSpacing.verySmall,
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          AppSpacing.verySmall,
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecoration.borderRadiusL,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                await authViewModel.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDecoration.borderRadiusM,
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
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
}