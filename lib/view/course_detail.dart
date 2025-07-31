import 'package:code_learn/app_constants/colors.dart';
import 'package:flutter/material.dart';

class CourseDetailPage extends StatelessWidget {
  const CourseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Course Detail",style: TextStyle(fontSize: 30,color: Colors.white),),
            SizedBox(height: 20,),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade800,
                child: const Icon(
                  Icons.image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter Full Course',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Modules
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.assignment, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '12 Modules',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                // Chapters
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.menu_book, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '48 Chapters',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Category: Mobile Development',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This course covers everything you need to know about Flutter. Learn how to build high-performance, beautiful apps for iOS and Android from a single codebase.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sample Video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.grey,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹999',
                style: TextStyle(
                  color: AppColors.card1,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 50,)
          ],
        ),
      ),
    );
  }
}
