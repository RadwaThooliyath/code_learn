import 'package:flutter/material.dart';
import '../../app_constants/colors.dart';
import '../../utils/app_decoration.dart';

class CourseCard extends StatelessWidget {
  final int index;
  final Color cardColor;
  final Color textColor;
  final VoidCallback? onDetailsTap;
  final double? width;

  const CourseCard({
    super.key,
    required this.index,
    required this.cardColor,
    required this.textColor,
    this.onDetailsTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final courseData = _getCourseData(index);
    
    return Container(
      width: width ?? MediaQuery.of(context).size.width * 0.75,
      height: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: AppDecoration.borderRadiusL,
        boxShadow: AppDecoration.softShadow,
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: AppDecoration.borderRadiusL,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor,
                    cardColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Pattern background
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 40,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Course icon as background element
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Icon(
                      courseData['icon'],
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content overlay
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    courseData['category'].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  courseData['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  courseData['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const Spacer(),
                
                // Bottom section
                Row(
                  children: [
                    // Explore button
                    Expanded(
                      child: GestureDetector(
                        onTap: onDetailsTap,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Explore Course',
                              style: TextStyle(
                                color: cardColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        courseData['price'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCourseData(int index) {
    final courses = [
      {
        'title': 'Flutter Development',
        'subtitle': 'Build beautiful mobile apps',
        'category': 'Mobile',
        'price': 'Free',
        'icon': Icons.phone_android,
      },
      {
        'title': 'UI/UX Design',
        'subtitle': 'Create stunning interfaces',
        'category': 'Design',
        'price': '₹1,499',
        'icon': Icons.palette,
      },
      {
        'title': 'Python Programming',
        'subtitle': 'Master backend development',
        'category': 'Backend',
        'price': 'Free',
        'icon': Icons.code,
      },
      {
        'title': 'React Native',
        'subtitle': 'Cross-platform development',
        'category': 'Mobile',
        'price': '₹2,299',
        'icon': Icons.web,
      },
      {
        'title': 'Data Science',
        'subtitle': 'Analytics and machine learning',
        'category': 'Data',
        'price': '₹2,999',
        'icon': Icons.analytics,
      },
      {
        'title': 'Digital Marketing',
        'subtitle': 'Grow your online presence',
        'category': 'Marketing',
        'price': '₹1,799',
        'icon': Icons.campaign,
      },
    ];
    
    return courses[index % courses.length];
  }
}