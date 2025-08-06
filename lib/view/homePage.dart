import 'package:code_learn/utils/app_text_style.dart';
import 'package:code_learn/utils/app_spacing.dart';
import 'package:code_learn/utils/app_decoration.dart';
import 'package:code_learn/utils/responsive_helper.dart';
import 'package:code_learn/view/course_types.dart';
import 'package:flutter/material.dart';
import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/view/course_detail.dart';

import 'widgets/card_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
                                gradient: LinearGradient(
                                  colors: [AppColors.robinEggBlue, AppColors.coral],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "CodeLearn",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
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
                              onPressed: () {},
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
                            const SizedBox(width: 12),
                            GestureDetector(
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
                                child: const Center(
                                  child: Text(
                                    "J",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              ),
              
              // Welcome section
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, John! 👋",
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
                      Container(
                        padding: AppSpacing.paddingL,
                        decoration: AppDecoration.cardDecoration,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("12", "Courses", Icons.book_outlined),
                            _buildStatDivider(),
                            _buildStatItem("45h", "Hours", Icons.access_time_outlined),
                            _buildStatDivider(),
                            _buildStatItem("87%", "Progress", Icons.trending_up_outlined),
                          ],
                        ),
                      ),
                      AppSpacing.large,
                      // Popular Categories
                      CourseHorizontalList(
                        title: "🔥 Popular Categories",
                        cardColorBuilder: (i) => _getGradientColors(i)[0],
                        textColorBuilder: (i) => Colors.white,
                        onDetailsTap: (i) => () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CourseTypes(),
                            ),
                          );
                        },
                      ),
                      AppSpacing.medium,
                      // Recommended for You
                      CourseHorizontalList(
                        title: "📚 Recommended for You",
                        cardColorBuilder: (i) => _getGradientColors(i)[1],
                        textColorBuilder: (i) => Colors.white,
                        onDetailsTap: (i) => () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CourseTypes(),
                            ),
                          );
                        },
                      ),
                      AppSpacing.medium,
                      // Continue Learning
                      CourseHorizontalList(
                        title: "⚡ Continue Learning",
                        cardColorBuilder: (i) => _getGradientColors(i + 2)[0],
                        textColorBuilder: (i) => Colors.white,
                        onDetailsTap: (i) => () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CourseTypes(),
                            ),
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
}
