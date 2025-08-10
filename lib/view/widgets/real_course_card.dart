import 'package:uptrail/model/course_model.dart';
import 'package:flutter/material.dart';
import '../../app_constants/colors.dart';
import '../../utils/app_decoration.dart';
import 'youtube_preview_player.dart';
import 'authenticated_image.dart';

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

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor(index);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.75,
        height: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: AppDecoration.borderRadiusL,
          boxShadow: AppDecoration.softShadow,
        ),
        child: Stack(
          children: [
            // Background image/thumbnail
            ClipRRect(
              borderRadius: AppDecoration.borderRadiusL,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Thumbnail image
                    if (course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty)
                      Positioned.fill(
                        child: AuthenticatedImage(
                          imageUrl: course.thumbnailUrl!,
                          fit: BoxFit.cover,
                          loadingWidget: (context) => Container(
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
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, error) => Container(
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getCourseIcon(),
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Image\nUnavailable",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      // Fallback gradient background
                      Positioned.fill(
                        child: Container(
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
                        ),
                      ),
                    
                    // Overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Pattern background (reduced opacity when thumbnail is present)
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: course.thumbnailUrl != null ? 0.05 : 0.1),
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
                          color: Colors.white.withValues(alpha: course.thumbnailUrl != null ? 0.02 : 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    
                    // Course icon as background element
                    Positioned(
                      right: 20,
                      top: 20,
                      child: Icon(
                        _getCourseIcon(),
                        size: 32,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Play button overlay for preview video
            if (course.previewVideoUrl != null && course.previewVideoUrl!.isNotEmpty)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () => _playPreviewVideo(context),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Course content overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag
                    if (course.category != null && course.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.category!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Course title
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Bottom row with instructor and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Instructor info
                        if (course.instructor != null && course.instructor!.isNotEmpty)
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    course.instructor!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                            course.isFree ? 'Free' : (course.priceDisplay ?? '₹${course.price?.toInt() ?? 'N/A'}'),
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