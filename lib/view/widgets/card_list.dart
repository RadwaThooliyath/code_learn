import 'package:code_learn/utils/app_text_style.dart';
import 'package:code_learn/utils/app_spacing.dart';
import 'package:code_learn/app_constants/colors.dart';
import 'package:flutter/material.dart';
import 'course_card.dart';

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
              TextButton(
                onPressed: () {},
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
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
