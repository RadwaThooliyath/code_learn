import 'package:code_learn/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'course_card.dart'; // import the CourseCard widget

class CourseHorizontalList extends StatelessWidget {
  final String title;
  final int itemCount;
  final Color Function(int) cardColorBuilder;
  final Color Function(int) textColorBuilder;
  final VoidCallback Function(int)? onDetailsTap;

  const CourseHorizontalList({
    super.key,
    required this.title,
    this.itemCount = 6,
    required this.cardColorBuilder,
    required this.textColorBuilder,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: AppTextStyle.headline2
            //TextStyle(
              // color: Colors.white,
              // fontWeight: FontWeight.w600,
              // fontSize: 22,
            //),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              return CourseCard(
                index: index,
                cardColor: cardColorBuilder(index),
                textColor: textColorBuilder(index),
                onDetailsTap: onDetailsTap?.call(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
