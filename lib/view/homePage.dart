import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/view/course_types.dart';
import 'package:uptrail/view/course_search.dart';
import 'package:uptrail/view/navigPage.dart';
import 'package:uptrail/view_model/auth_viewModel.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/course_model.dart';
import 'widgets/real_course_list.dart';
import 'widgets/whatsapp_support_button.dart';
import 'widgets/app_drawer.dart';
import 'dashboard_page.dart';
import 'lead_submission_page.dart';

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
      final courseViewModel = Provider.of<CourseViewModel>(
        context,
        listen: false,
      );
      courseViewModel.fetchCourses();
      courseViewModel.fetchCategories();
      courseViewModel.fetchEnrolledCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          drawer: const AppDrawer(),
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
                    automaticallyImplyLeading: false,
                    flexibleSpace: Container(
                      color: AppColors.background,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Menu button and Logo/Brand section
                            Row(
                              children: [
                                Builder(
                                  builder: (context) => IconButton(
                                    icon: const Icon(
                                      Icons.menu,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.champagnePink,
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
                                    fontSize: 22,
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
                                        builder:
                                            (_) => const CourseSearchPage(),
                                      ),
                                    );
                                  },
                                  padding: const EdgeInsets.all(8),
                                ),
                                const SizedBox(width: 4),
                                Consumer<AuthViewModel>(
                                  builder: (context, authViewModel, child) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to profile tab (index 4) while maintaining bottom nav
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const Navigpage(
                                                  initialIndex: 4,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.brightPinkCrayola,
                                              AppColors.coral,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            authViewModel.user?.name
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                "U",
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
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 20,
                      ),
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
                              const SizedBox(height: 16),
                              // Action Buttons Row
                              Row(
                                children: [
                                  // Dashboard Quick Access Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DashboardPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.brightPinkCrayola,
                                              AppColors.logoBrightBlue,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.brightPinkCrayola.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.dashboard,
                                              color: AppColors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Dashboard",
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Lead Submission Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const LeadSubmissionPage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.logoBrightBlue,
                                              AppColors.robinEggBlue,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.logoDarkTeal.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.rocket_launch,
                                              color: AppColors.logoDarkTeal,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "Live Sessions",
                                              style: TextStyle(
                                                color: AppColors.logoDarkTeal,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
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
                          );
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.background,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // All Courses
                            Consumer<CourseViewModel>(
                              builder: (context, courseViewModel, child) {
                                return RealCourseList(
                                  title: "Available Courses",
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
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(
                                          "Course Categories",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      AppSpacing.medium,
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        padding: AppSpacing.paddingL,
                                        decoration:
                                            AppDecoration.cardDecoration,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                if (courseViewModel.categories.isNotEmpty) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Course Categories",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                          const CourseTypes(),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8,
                                                  ),
                                              backgroundColor: AppColors
                                                  .brightPinkCrayola
                                                 ,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              "View All",
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      AppSpacing.medium,
                                      SizedBox(
                                        height: 140,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          padding: EdgeInsets.zero,
                                          itemCount:
                                              courseViewModel.categories
                                                  .take(6)
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final category =
                                                courseViewModel
                                                    .categories[index];
                                            return Container(
                                              width: 150,
                                              margin: EdgeInsets.only(
                                                left: index == 0 ? 0 : 0,
                                                right:
                                                    index <
                                                            courseViewModel
                                                                    .categories
                                                                    .take(6)
                                                                    .length -
                                                                1
                                                        ? 14
                                                        : 20,
                                              ),
                                              child: _buildCategoryCard(
                                                context,
                                                category,
                                                index,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                            AppSpacing.medium,
                            // Free Courses
                            Consumer<CourseViewModel>(
                              builder: (context, courseViewModel, child) {
                                final freeCourses =
                                    courseViewModel.courses
                                        .where((course) => course.isFree)
                                        .toList();
                                return RealCourseList(
                                  title: "Free Courses",
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
        ),
        // WhatsApp Support Button
        const WhatsAppSupportButton(),
      ],
    );
  }

  List<Color> _getGradientColors(int index) {
    final gradients = [
      // Modern Blue to Purple
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      // Orange to Pink
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      // Green to Blue
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      // Purple to Pink
      [const Color(0xFF8360c3), const Color(0xFF2ebf91)],
      // Warm Orange to Red
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
      // Deep Blue to Light Blue
      [const Color(0xFF2196f3), const Color(0xFF21cbf3)],
      // Purple to Blue
      [const Color(0xFF9c27b0), const Color(0xFF673ab7)],
      // Teal to Green
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildCategoryCard(
    BuildContext context,
    CourseCategory category,
    int index,
  ) {
    final gradientColors = _getGradientColors(index);

    return GestureDetector(
      onTap: () async {
        final courseViewModel = Provider.of<CourseViewModel>(
          context,
          listen: false,
        );
        await courseViewModel.loadCoursesByCategory(category.id.toString());
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseTypes()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getCategoryDisplayName(category.name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${category.courseCount}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    category.courseCount == 1 ? "course" : "courses",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    // Web Development
    if (name.contains('web') ||
        name.contains('frontend') ||
        name.contains('javascript') ||
        name.contains('react') ||
        name.contains('html') ||
        name.contains('css')) {
      return Icons.web;
    }
    // Mobile Development
    else if (name.contains('mobile') ||
        name.contains('flutter') ||
        name.contains('android') ||
        name.contains('ios') ||
        name.contains('app development')) {
      return Icons.phone_android;
    }
    // Backend Development
    else if (name.contains('backend') ||
        name.contains('server') ||
        name.contains('api') ||
        name.contains('fullstack')) {
      return Icons.dns;
    }
    // Data Science & Analytics
    else if (name.contains('data') ||
        name.contains('analysis') ||
        name.contains('science') ||
        name.contains('analytics') ||
        name.contains('statistics')) {
      return Icons.analytics;
    }
    // UI/UX Design
    else if (name.contains('design') ||
        name.contains('ui') ||
        name.contains('ux') ||
        name.contains('graphic') ||
        name.contains('creative')) {
      return Icons.palette;
    }
    // AI & Machine Learning
    else if (name.contains('ai') ||
        name.contains('machine') ||
        name.contains('learning') ||
        name.contains('neural') ||
        name.contains('deep learning')) {
      return Icons.psychology;
    }
    // Cybersecurity
    else if (name.contains('security') ||
        name.contains('cyber') ||
        name.contains('ethical hacking')) {
      return Icons.security;
    }
    // Database
    else if (name.contains('database') ||
        name.contains('sql') ||
        name.contains('mongodb') ||
        name.contains('mysql') ||
        name.contains('postgresql')) {
      return Icons.storage;
    }
    // DevOps & Cloud
    else if (name.contains('devops') ||
        name.contains('cloud') ||
        name.contains('aws') ||
        name.contains('docker') ||
        name.contains('kubernetes')) {
      return Icons.cloud;
    }
    // Game Development
    else if (name.contains('game') ||
        name.contains('unity') ||
        name.contains('unreal')) {
      return Icons.sports_esports;
    }
    // Digital Marketing
    else if (name.contains('marketing') ||
        name.contains('seo') ||
        name.contains('social media')) {
      return Icons.campaign;
    }
    // Business & Management
    else if (name.contains('business') ||
        name.contains('management') ||
        name.contains('entrepreneurship')) {
      return Icons.business_center;
    }
    // Finance & Accounting
    else if (name.contains('finance') ||
        name.contains('accounting') ||
        name.contains('investment')) {
      return Icons.account_balance;
    }
    // Photography & Video
    else if (name.contains('photography') ||
        name.contains('video') ||
        name.contains('editing')) {
      return Icons.camera_alt;
    }
    // Music & Audio
    else if (name.contains('music') ||
        name.contains('audio') ||
        name.contains('sound')) {
      return Icons.music_note;
    }
    // Language Learning
    else if (name.contains('language') ||
        name.contains('english') ||
        name.contains('communication')) {
      return Icons.translate;
    }
    // Health & Fitness
    else if (name.contains('health') ||
        name.contains('fitness') ||
        name.contains('wellness')) {
      return Icons.fitness_center;
    }
    // Cooking & Food
    else if (name.contains('cooking') ||
        name.contains('food') ||
        name.contains('culinary')) {
      return Icons.restaurant;
    }
    // UGC NET & Competitive Exams
    else if (name.contains('ugc') ||
        name.contains('net') ||
        name.contains('competitive') ||
        name.contains('exam') ||
        name.contains('entrance')) {
      return Icons.quiz;
    }
    // Tuition & Academic Support
    else if (name.contains('tuition') ||
        name.contains('academic') ||
        name.contains('homework') ||
        name.contains('coaching')) {
      return Icons.school;
    }
    // Personal Development
    else if (name.contains('personal') ||
        name.contains('self') ||
        name.contains('motivation')) {
      return Icons.person;
    }
    // Default
    else {
      return Icons.book;
    }
  }

  String _getCategoryDisplayName(String categoryName) {
    final name = categoryName.toLowerCase();

    // Return short, recognizable names for long categories
    if (name.contains('ugc') && name.contains('net')) return 'UGC NET';
    if (name.contains('app development') || name.contains('mobile development'))
      return 'App Dev';
    if (name.contains('web development') || name.contains('frontend'))
      return 'Web Dev';
    if (name.contains('fullstack') || name.contains('full stack'))
      return 'Full Stack';
    if (name.contains('machine learning') || name.contains('ml')) return 'ML';
    if (name.contains('artificial intelligence') || name.contains('ai'))
      return 'AI';
    if (name.contains('data science')) return 'Data Science';
    if (name.contains('digital marketing')) return 'Marketing';
    if (name.contains('ui/ux') || name.contains('user experience'))
      return 'UI/UX';
    if (name.contains('cybersecurity') || name.contains('ethical hacking'))
      return 'Security';
    if (name.contains('competitive exam')) return 'Comp Exams';
    if (name.contains('personal development')) return 'Personal Dev';

    // If category name is too long, truncate intelligently
    if (categoryName.length > 12) {
      final words = categoryName.split(' ');
      if (words.length > 1) {
        return words.take(2).join(' ');
      }
      return '${categoryName.substring(0, 10)}...';
    }

    return categoryName;
  }
}
