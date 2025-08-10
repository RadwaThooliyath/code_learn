import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_text_style.dart' show AppTextStyle;
import 'package:uptrail/view/github.dart';
import 'package:uptrail/view/video_viewer.dart';
import 'package:flutter/material.dart';

class MycourseDetail extends StatefulWidget {
  const MycourseDetail({super.key});

  @override
  State<MycourseDetail> createState() => _MycourseDetailState();
}

class _MycourseDetailState extends State<MycourseDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Course Detail",
              style: AppTextStyle.headline1,
            ),
            const SizedBox(height: 20),
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
              style: AppTextStyle.headline2
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
              'Category : Mobile Development',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Fee : ₹999',
              style: TextStyle(
                color: AppColors.card1,
                fontSize: 18,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Colors.white12),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoViewer(),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.play_circle, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'View Videos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssignmentSubmissionPage(),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: const [
                        Icon(Icons.upload_file, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'Submit Assignment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.white12),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
