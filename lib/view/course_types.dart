import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/view/course_detail_page.dart';
import 'package:uptrail/view/course_search.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/real_course_card.dart';

class CourseTypes extends StatefulWidget {
  const CourseTypes({super.key});

  @override
  State<CourseTypes> createState() => _CourseTypesState();
}

class _CourseTypesState extends State<CourseTypes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
      if (courseViewModel.courses.isEmpty) {
        courseViewModel.fetchCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'All Courses',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CourseSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CourseViewModel>(
        builder: (context, courseViewModel, child) {
          if (courseViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.robinEggBlue),
              ),
            );
          }

          if (courseViewModel.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading courses',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    courseViewModel.error,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      courseViewModel.clearError();
                      courseViewModel.fetchCourses();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.robinEggBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (courseViewModel.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses available',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courseViewModel.courses.length,
            itemBuilder: (context, index) {
              final course = courseViewModel.courses[index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RealCourseCard(
                  course: course,
                  index: index,
                  width: double.infinity,
                  onTap: () async {
                    await courseViewModel.fetchCourseDetail(course.id);
                    
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(course: course),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
