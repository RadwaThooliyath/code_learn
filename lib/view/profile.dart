import 'package:uptrail/app_constants/button.dart';
import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
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
              // TODO: Navigate to edit profile page
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Avatar with user initials
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.logoBrightBlue, AppColors.logoGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.logoBrightBlue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getUserInitials(user.name ?? "U"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // User Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildProfileRow("Name", user.name ?? "Not provided", Icons.person),
                      _buildProfileRow("Email", user.email ?? "Not provided", Icons.email),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        _buildProfileRow("Phone", user.phone!, Icons.phone),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        _buildProfileRow("Bio", user.bio!, Icons.info_outline),
                      _buildProfileRow("User ID", "#${user.id ?? "N/A"}", Icons.badge),
                      _buildProfileRow("Role", _formatRole(user.role ?? "student"), Icons.work),
                      if (user.dateJoined != null)
                        _buildProfileRow("Joined", _formatDate(user.dateJoined!), Icons.calendar_today),
                      if (user.lastLogin != null)
                        _buildProfileRow("Last Login", _formatDate(user.lastLogin!), Icons.access_time),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Course Statistics Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "📚 Course Statistics",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow("Enrolled Courses", "${enrolledCourses.length}", Icons.school),
                      _buildStatRow("Completed", "0", Icons.check_circle), // TODO: Add completion tracking
                      _buildStatRow("In Progress", "${enrolledCourses.length}", Icons.play_circle),
                      if (enrolledCourses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "Current Courses:",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...enrolledCourses.take(3).map((course) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              "• ${course.title}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        if (enrolledCourses.length > 3)
                          Text(
                            "• +${enrolledCourses.length - 3} more courses",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                Button(
                  text: "Edit Profile", 
                  onPressed: () {
                    // TODO: Navigate to edit profile page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile feature coming soon!'),
                      ),
                    );
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.logoBrightBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.logoBrightBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(
                color: Colors.white54, 
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.logoGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.logoGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.logoGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
}
