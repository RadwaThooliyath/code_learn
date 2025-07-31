import 'package:code_learn/app_constants/colors.dart';
import 'package:flutter/material.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key});

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  final courseTitle = "Flutter Development";
  final videoList = [
    "1. Course Introduction",
    "2. Installation & Setup",
    "3. Dart Basics",
    "4. Widgets Overview",
    "5. Navigation & Routes",
    "6. Building UI Components",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(courseTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Videos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            videoList[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
