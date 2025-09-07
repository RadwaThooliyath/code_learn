import 'package:uptrail/model/course_model.dart';
import 'package:flutter/material.dart';
import '../../app_constants/colors.dart';
import '../../utils/app_decoration.dart';
import '../../utils/app_spacing.dart';
import 'youtube_preview_player.dart';
import 'authenticated_image.dart';
import 'rating_dialog.dart';

class RealCourseCard extends StatelessWidget {
  final Course course;
  final int index;
  final VoidCallback onTap;
  final double? width;

  const RealCourseCard({
    super.key,
    required this.course,
    required this.index,
    required this.onTap,
    this.width,
  });

  void _playPreviewVideo(BuildContext context) {
    if (course.previewVideoUrl != null && course.previewVideoUrl!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => YoutubePreviewPlayer(
            videoUrl: course.previewVideoUrl!,
            courseTitle: course.title,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RatingDialog(
          courseId: course.id,
          courseTitle: course.title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.champagnePink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Title with badges - Header Section
          AppSpacing.small,
          
          // Course Image/Banner Section
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Background Image
                  if (course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty)
                    Positioned.fill(
                      child: AuthenticatedImage(
                        imageUrl: course.thumbnailUrl!,
                        fit: BoxFit.cover,
                        loadingWidget: (context) => _buildCourseImagePlaceholder(),
                        errorWidget: (context, error) => _buildCourseImagePlaceholder(),
                      ),
                    )
                  else
                    _buildCourseImagePlaceholder(),
                  
                  // Language Badge - Bottom Right
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.logoBrightBlue.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.category ?? 'Course',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          AppSpacing.small,
          
          // Course Details Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  course.title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.medium,
                // Show description only if available
                if (course.description.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              course.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                
                // Show instructor only if available
                if (course.instructor != null && course.instructor!.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'by ${course.instructor}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                
                // Show level only if available
                if (course.level != null && course.level!.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level: ${course.level}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                
                // Show duration only if available
                if (course.duration != null)
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.duration} hours',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                
                // Show enrolled count only if available
                if (course.enrolledCount != null && course.enrolledCount! > 0)
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${course.enrolledCount} students enrolled',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                
                // Pricing Section
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      if (course.isFree)
                        const Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.green,
                          ),
                        )
                      else
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                course.priceDisplay ?? '₹${course.price?.toInt() ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.teal,
                                ),
                              ),
                              if (course.totalPriceDisplay != null && course.totalPriceDisplay!.isNotEmpty)
                                Text(
                                  'Total: ${course.totalPriceDisplay}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.brightPinkCrayola),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'EXPLORE',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightPinkCrayola,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          course.isEnrolled == true
                            ? 'CONTINUE'
                            : course.isFree
                              ? 'START FREE'
                              : 'BUY NOW',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCardColor(index).withValues(alpha: 0.8),
            _getCardColor(index),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCourseIcon(),
              color: Colors.white.withValues(alpha: 0.9),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              course.title.split(' ').take(2).join(' '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  Widget _buildSimpleGradient(Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.8),
            cardColor,
            cardColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCourseIcon(),
          color: Colors.white.withValues(alpha: 0.8),
          size: 48,
        ),
      ),
    );
  }
  
  Widget _buildProfessionalGradient(Color cardColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor.withValues(alpha: 0.8),
            cardColor,
            cardColor.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCourseIcon(),
              color: Colors.white.withValues(alpha: 0.9),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              "Course Preview",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      AppColors.robinEggBlue,
      AppColors.coral,
      AppColors.brightPinkCrayola,
      AppColors.champagnePink,
    ];
    return colors[index % colors.length];
  }

  IconData _getCourseIcon() {
    final category = course.category?.toLowerCase() ?? '';
    
    if (category.contains('mobile') || category.contains('app')) {
      return Icons.phone_android;
    } else if (category.contains('web') || category.contains('frontend')) {
      return Icons.web;
    } else if (category.contains('backend') || category.contains('server')) {
      return Icons.dns;
    } else if (category.contains('data') || category.contains('analysis')) {
      return Icons.analytics;
    } else if (category.contains('design') || category.contains('ui')) {
      return Icons.palette;
    } else if (category.contains('ai') || category.contains('machine')) {
      return Icons.psychology;
    } else {
      return Icons.school;
    }
  }
}