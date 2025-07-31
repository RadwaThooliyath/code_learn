import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final int index;
  final Color cardColor;
  final Color textColor;
  final VoidCallback? onDetailsTap;
  final double? width; // 👈 Add this line

  const CourseCard({
    super.key,
    required this.index,
    required this.cardColor,
    required this.textColor,
    this.onDetailsTap,
    this.width, // 👈 Include in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width / 1.4,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: cardColor,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card $index',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  Icon(Icons.bookmark_border, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Icon(Icons.favorite_border, size: 20, color: textColor),
                ],
              ),
            ),
            Positioned(
              bottom: 8,
              left: 16,
              child: GestureDetector(
                onTap: onDetailsTap,
                child: Text(
                  'Explore',
                  style: TextStyle(color: textColor, fontSize: 14),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 16,
              child: Text(
                '₹999',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
