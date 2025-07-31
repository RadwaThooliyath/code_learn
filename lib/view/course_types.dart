import 'package:code_learn/app_constants/colors.dart';
import 'package:code_learn/view/course_detail.dart';
import 'package:flutter/material.dart';

import 'widgets/course_card.dart';

class CourseTypes extends StatefulWidget {
  const CourseTypes({super.key});

  @override
  State<CourseTypes> createState() => _CourseTypesState();
}

class _CourseTypesState extends State<CourseTypes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Expanded(
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            final cardColor =
                index.isEven ? AppColors.card1 : AppColors.card2;
            final textColor = index.isEven ? Colors.black : Colors.white;

            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Sub Category ${index + 1}", // Optional: make it dynamic
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CourseCard(
                    index: index,
                    cardColor: cardColor,
                    textColor: textColor,
                    width: MediaQuery.of(context).size.width * 0.95,
                    onDetailsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CourseDetailPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );

          },
        ),
      ),
    );
  }
}
