import 'package:code_learn/view/course_detail.dart';
import 'package:code_learn/view/myCourse_detail.dart';
import 'package:flutter/material.dart';
import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/view/widgets/course_card.dart';

class SelectedCoursesPage extends StatelessWidget {
  const SelectedCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCourses = [
      "Flutter Basics",
      "Python for Beginners",
      "React Native Essentials",
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Selected Courses", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedCourses.isEmpty
            ? const Center(
          child: Text(
            "No courses selected.",
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: selectedCourses.length,
          itemBuilder: (context, index) {
            final color = index.isEven ? AppColors.card1 : AppColors.card2;
            final textColor = index.isEven ? Colors.black : Colors.white;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CourseCard(
                index: index,
                cardColor: color,
                textColor: textColor,
                width: MediaQuery.of(context).size.width * 0.95,
                onDetailsTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MycourseDetail(),));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
