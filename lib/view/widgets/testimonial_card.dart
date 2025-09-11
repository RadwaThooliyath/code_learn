import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TestimonialCard extends StatelessWidget {
  final Testimonial testimonial;
  final VoidCallback? onTap;

  const TestimonialCard({
    super.key,
    required this.testimonial,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 280, // Increased height to accommodate media content
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Content Section
            _buildMediaContent(),
            
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with student info and type icon
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: testimonial.studentPhoto != null
                              ? CachedNetworkImageProvider(testimonial.studentPhoto!)
                              : null,
                          child: testimonial.studentPhoto == null
                              ? Icon(
                                  Icons.person,
                                  color: Colors.grey[500],
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                testimonial.studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                testimonial.courseName,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        _buildTestimonialTypeIcon(),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < testimonial.overallRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Testimonial text (only show if not empty)
                    if (testimonial.testimonialText.isNotEmpty)
                      Expanded(
                        child: Text(
                          testimonial.testimonialText,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    // Bottom info
                    if (testimonial.currentPosition != null && 
                        testimonial.currentPosition!.isNotEmpty ||
                        testimonial.currentCompany != null && 
                        testimonial.currentCompany!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.brightPinkCrayola.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _buildPositionText(),
                          style: TextStyle(
                            color: AppColors.brightPinkCrayola,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
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

  Widget _buildTestimonialTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (testimonial.testimonialType.toLowerCase()) {
      case 'video_youtube':
        iconData = Icons.play_circle_fill;
        iconColor = Colors.red;
        break;
      case 'video_upload':
        iconData = Icons.videocam;
        iconColor = Colors.blue;
        break;
      case 'audio':
        iconData = Icons.mic;
        iconColor = Colors.purple;
        break;
      case 'text_image':
      default:
        iconData = Icons.chat_bubble;
        iconColor = AppColors.brightPinkCrayola;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 16,
      ),
    );
  }

  Widget _buildMediaContent() {
    final type = testimonial.testimonialType.toLowerCase();
    
    switch (type) {
      case 'video_youtube':
        return _buildYouTubeContent();
      case 'video_upload':
        return _buildUploadedVideoContent();
      case 'audio':
        return _buildAudioContent();
      case 'text_image':
        return _buildImageContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildYouTubeContent() {
    final videoId = testimonial.youtubeVideoId;
    final thumbnailUrl = testimonial.youtubeThumbnailUrl;
    
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // YouTube Thumbnail
          if (thumbnailUrl != null && thumbnailUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildYouTubeVideoPlaceholder(),
                errorWidget: (context, url, error) => _buildYouTubeVideoPlaceholder(),
              ),
            )
          else if (videoId != null && videoId.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildYouTubeVideoPlaceholder(),
                errorWidget: (context, url, error) => _buildYouTubeVideoPlaceholder(),
              ),
            )
          else
            _buildYouTubeVideoPlaceholder(),
          
          // Play button overlay
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // YouTube branding
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'YouTube',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Show "Video not available" indicator if no video ID
          if ((videoId == null || videoId.isEmpty) && (thumbnailUrl == null || thumbnailUrl.isEmpty))
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Video Setup Pending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadedVideoContent() {
    final videoThumbnail = testimonial.videoThumbnail;
    
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          if (videoThumbnail != null && videoThumbnail.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: videoThumbnail,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildVideoPlaceholder(),
                errorWidget: (context, url, error) => _buildVideoPlaceholder(),
              ),
            )
          else
            _buildVideoPlaceholder(),
          
          // Play button overlay
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          
          // Video duration badge (if available)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Audio waveform pattern (decorative)
          Positioned.fill(
            child: CustomPaint(
              painter: AudioWaveformPainter(),
            ),
          ),
          
          // Audio icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          
          // Audio badge
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'AUDIO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: AppColors.card2,
      ),
      child: testimonial.studentPhoto != null
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: testimonial.studentPhoto!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildDefaultContent() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            AppColors.logoDarkTeal,
            AppColors.brightPinkCrayola,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Testimonial',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.black,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Video Testimonial',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeVideoPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.8),
            Colors.red.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              'YouTube Testimonial',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Video content coming soon',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: AppColors.card2,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              color: Colors.grey[400],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Image',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildPositionText() {
    final position = testimonial.currentPosition?.isNotEmpty == true 
        ? testimonial.currentPosition! 
        : '';
    final company = testimonial.currentCompany?.isNotEmpty == true 
        ? testimonial.currentCompany! 
        : '';
    
    if (position.isNotEmpty && company.isNotEmpty) {
      return '$position at $company';
    } else if (position.isNotEmpty) {
      return position;
    } else if (company.isNotEmpty) {
      return 'Employee at $company';
    } else {
      return 'Student';
    }
  }
}

// Custom painter for audio waveform pattern
class AudioWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final spacing = size.width / 20;
    
    for (int i = 0; i < 20; i++) {
      final x = i * spacing;
      final height = (i % 4 + 1) * (size.height / 8) + 10;
      final startY = (size.height - height) / 2;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, startY + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}