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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        actions: const [
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 10),
          CircleAvatar(radius: 20),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Choose your course",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CourseHorizontalList(
                title: "Categories",
                cardColorBuilder: (i) =>
                i.isEven ? AppColors.card1 : AppColors.card2,
                textColorBuilder: (i) =>
                i.isEven ? Colors.black : Colors.white,
                onDetailsTap: (i) => () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseTypes(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CourseHorizontalList(
                title: "Categories",
                cardColorBuilder: (i) =>
                i.isEven ? AppColors.card2 : AppColors.card1,
                textColorBuilder: (i) =>
                i.isEven ? Colors.white : Colors.black,
                onDetailsTap: (i) => () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CourseTypes(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              CourseHorizontalList(
                title: "Categories",
                cardColorBuilder: (i) =>
                i.isEven ? AppColors.card1 : AppColors.card2,
                textColorBuilder: (i) =>
                i.isEven ? Colors.black : Colors.white,
                onDetailsTap: (i) => () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseTypes(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
