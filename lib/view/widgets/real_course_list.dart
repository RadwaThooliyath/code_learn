import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/view/course_detail_page.dart';
import 'package:uptrail/view_model/course_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_constants/colors.dart';
import '../../utils/app_spacing.dart';
import 'real_course_card.dart';

class RealCourseList extends StatelessWidget {
  final String title;
  final List<Course> courses;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const RealCourseList({
    super.key,
    required this.title,
    required this.courses,
    required this.isLoading,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppColors.robinEggBlue.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.robinEggBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.small,
        if (isLoading)
          SizedBox(
            height: 260,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.robinEggBlue),
              ),
            ),
          )
        else if (courses.isEmpty)
          SizedBox(
            height: 260,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses available',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: courses.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final course = courses[index];
                return RealCourseCard(
                  course: course,
                  index: index,
                  onTap: () async {
                    final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
                    await courseViewModel.fetchCourseDetail(course.id);
                    
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailPage(course: course),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}