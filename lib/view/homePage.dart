import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/responsive_helper.dart';
import 'package:uptrail/view/course_types.dart';
import 'package:uptrail/view/course_search.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/course_model.dart';
import 'widgets/real_course_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
      courseViewModel.fetchCourses();
      courseViewModel.fetchCategories();
      courseViewModel.fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                pinned: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                flexibleSpace: Container(
                  color: AppColors.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo/Brand section
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:  AppColors.logoDarkTeal,

                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: SvgPicture.asset(
                                  'assets/logo/logo.svg',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Uptrail",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        
                        // Right side icons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CourseSearchPage(),
                                  ),
                                );
                              },
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Stack(
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.coral,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onPressed: () {},
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () async {
                                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                                
                                // Show confirmation dialog
                                final shouldLogout = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Logout'),
                                    content: const Text('Are you sure you want to logout?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Logout'),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldLogout == true) {
                                  await authViewModel.logout();
                                  // Navigation will be handled automatically by AuthWrapper
                                }
                              },
                              padding: const EdgeInsets.all(8),
                            ),
                            const SizedBox(width: 4),
                            Consumer<AuthViewModel>(
                              builder: (context, authViewModel, child) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.brightPinkCrayola, AppColors.coral],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        authViewModel.user?.name?.substring(0, 1).toUpperCase() ?? "U",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Welcome section
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${authViewModel.user?.name ?? 'User'}! 👋",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "What would you like to learn today?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  child: Padding(
                    padding: ResponsiveHelper.getScreenPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Quick Stats Section
                      Consumer<CourseViewModel>(
                        builder: (context, courseViewModel, child) {
                          final totalCourses = courseViewModel.courses.length;
                          final enrolledCourses = courseViewModel.enrolledCourses.length;
                          
                          // Calculate total hours from available courses
                          final totalHours = courseViewModel.courses.fold<int>(0, (sum, course) {
                            return sum + (course.duration ?? 0);
                          });
                          
                          // Calculate progress percentage
                          final progressPercentage = totalCourses > 0 
                              ? ((enrolledCourses / totalCourses) * 100).round()
                              : 0;
                          
                          return Container(
                            padding: AppSpacing.paddingL,
                            decoration: AppDecoration.cardDecoration,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  totalCourses.toString(), 
                                  "Courses", 
                                  Icons.book_outlined
                                ),
                                _buildStatDivider(),
                                _buildStatItem(
                                  totalHours > 0 ? "${totalHours}h" : "0h", 
                                  "Hours", 
                                  Icons.access_time_outlined
                                ),
                                _buildStatDivider(),
                                _buildStatItem(
                                  "$progressPercentage%", 
                                  "Progress", 
                                  Icons.trending_up_outlined
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      AppSpacing.large,
                      // All Courses
                      Consumer<CourseViewModel>(
                        builder: (context, courseViewModel, child) {
                          return RealCourseList(
                            title: "📚 Available Courses",
                            courses: courseViewModel.courses,
                            isLoading: courseViewModel.isLoading,
                            onSeeAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CourseTypes(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      AppSpacing.medium,
                      // Categories Section
                      Consumer<CourseViewModel>(
                        builder: (context, courseViewModel, child) {
                          if (courseViewModel.isLoadingCategories) {
                            return Container(
                              padding: AppSpacing.paddingL,
                              decoration: AppDecoration.cardDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "🏷️ Course Categories",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.background,
                                    ),
                                  ),
                                  AppSpacing.medium,
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  AppSpacing.medium,
                                ],
                              ),
                            );
                          }
                          
                          if (courseViewModel.categories.isNotEmpty) {
                            return Container(
                              padding: AppSpacing.paddingL,
                              decoration: AppDecoration.cardDecoration,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "🏷️ Course Categories",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.background,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const CourseTypes(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "See All",
                                          style: TextStyle(
                                            color: AppColors.coral,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.medium,
                                  SizedBox(
                                    height: 130,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: courseViewModel.categories.take(6).length,
                                      itemBuilder: (context, index) {
                                        final category = courseViewModel.categories[index];
                                        return Container(
                                          width: 140,
                                          margin: EdgeInsets.only(right: index < courseViewModel.categories.take(6).length - 1 ? 12 : 0),
                                          child: _buildCategoryCard(context, category, index),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          
                          return const SizedBox.shrink();
                        },
                      ),
                      AppSpacing.medium,
                      // Free Courses
                      Consumer<CourseViewModel>(
                        builder: (context, courseViewModel, child) {
                          final freeCourses = courseViewModel.courses.where((course) => course.isFree).toList();
                          return RealCourseList(
                            title: "🆓 Free Courses",
                            courses: freeCourses,
                            isLoading: courseViewModel.isLoading,
                            onSeeAll: () async {
                              await courseViewModel.loadFreeCourses();
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CourseTypes(),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                      AppSpacing.veryLarge,
                    ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.robinEggBlue, AppColors.coral],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        AppSpacing.verySmall,
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      [AppColors.robinEggBlue, AppColors.coral],
      [AppColors.coral, AppColors.brightPinkCrayola],
      [AppColors.brightPinkCrayola, AppColors.robinEggBlue],
      [AppColors.champagnePink, AppColors.coral],
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildCategoryCard(BuildContext context, CourseCategory category, int index) {
    final gradientColors = _getGradientColors(index);
    
    return GestureDetector(
      onTap: () async {
        final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
        await courseViewModel.loadCoursesByCategory(category.id.toString());
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CourseTypes(),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getCategoryIcon(category.name),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                "${category.courseCount} courses",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('web') || name.contains('frontend') || name.contains('javascript') || name.contains('react')) {
      return Icons.web;
    } else if (name.contains('mobile') || name.contains('flutter') || name.contains('android') || name.contains('ios')) {
      return Icons.phone_android;
    } else if (name.contains('backend') || name.contains('server') || name.contains('api')) {
      return Icons.dns;
    } else if (name.contains('data') || name.contains('analysis') || name.contains('science')) {
      return Icons.analytics;
    } else if (name.contains('design') || name.contains('ui') || name.contains('ux')) {
      return Icons.palette;
    } else if (name.contains('ai') || name.contains('machine') || name.contains('learning')) {
      return Icons.psychology;
    } else if (name.contains('security') || name.contains('cyber')) {
      return Icons.security;
    } else if (name.contains('database') || name.contains('sql')) {
      return Icons.storage;
    } else if (name.contains('devops') || name.contains('cloud')) {
      return Icons.cloud;
    } else if (name.contains('game') || name.contains('unity')) {
      return Icons.sports_esports;
    } else {
      return Icons.school;
    }
  }
}
