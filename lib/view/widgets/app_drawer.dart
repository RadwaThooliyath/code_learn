import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view/loginPage.dart';
import 'package:uptrail/view/profile_new.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view/dashboard_page.dart';
import 'package:uptrail/view/my_courses.dart';
import 'package:uptrail/view/enrolled_courses.dart';
import 'package:uptrail/view/my_teams.dart';
import 'package:uptrail/view/lead_status_page.dart';
import 'package:uptrail/view/change_password.dart';
import 'package:uptrail/services/user_profile_service.dart';
import 'package:uptrail/services/storage_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SingleChildScrollView(
        child: Column(
          children: [
          // Drawer Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.logoDarkTeal,
                  AppColors.brightPinkCrayola.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    // Get user data with multiple fallbacks
                    String userName = authViewModel.user?.name ?? 'Test User';
                    String userEmail = authViewModel.user?.email ?? 'test@example.com';
                    String userInitial = userName.isNotEmpty 
                        ? userName.substring(0, 1).toUpperCase() 
                        : 'T';
                    
                    print('DEBUG: AuthViewModel user: ${authViewModel.user}');
                    print('DEBUG: userName: $userName, userEmail: $userEmail');
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.brightPinkCrayola,
                                    AppColors.coral,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  userInitial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Hello,",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Drawer Items
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 120),
            child: Column(
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  subtitle: 'Success stories & stats',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.library_books,
                  title: 'My Courses',
                  subtitle: 'Your enrolled courses',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectedCoursesPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.monetization_on,
                  title: 'Enrollments',
                  subtitle: 'Payment & progress',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnrolledCoursesPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.group,
                  title: 'Teams',
                  subtitle: 'Collaborate & learn',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyTeamsPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.description,
                  title: 'My Applications',
                  subtitle: 'Track application status',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeadStatusPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: 'Account settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfilePage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.lock,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Colors.grey,
                  height: 20,
                  indent: 16,
                  endIndent: 16,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get assistance',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to help page
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : AppColors.brightPinkCrayola.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColors.brightPinkCrayola,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive 
              ? Colors.red.withValues(alpha: 0.7)
              : Colors.grey[400],
          fontSize: 11,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[400],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await Provider.of<AuthViewModel>(context, listen: false).logout();
                // Navigate to login page and clear all routes
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}