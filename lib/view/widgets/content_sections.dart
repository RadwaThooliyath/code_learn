import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/view/widgets/placement_card.dart';
import 'package:uptrail/view/widgets/testimonial_card.dart';
import 'package:uptrail/view/widgets/news_card.dart';
import 'package:uptrail/view/all_testimonials_page.dart';
import 'package:uptrail/view/news_detail_page.dart';
import 'package:uptrail/view/widgets/youtube_preview_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlacementsSection extends StatelessWidget {
  final List<Placement> placements;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const PlacementsSection({
    super.key,
    required this.placements,
    this.isLoading = false,
    this.onSeeAll,
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
              const Row(
                children: [
                  Icon(
                    Icons.work,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Recent Placements",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppColors.brightPinkCrayola,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.medium,
        if (isLoading)
          const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (placements.isEmpty)
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card2.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No placements available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: placements.length,
              itemBuilder: (context, index) {
                return PlacementCard(
                  placement: placements[index],
                  onTap: () {
                    // TODO: Navigate to placement detail page
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  final List<Testimonial> testimonials;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const TestimonialsSection({
    super.key,
    required this.testimonials,
    this.isLoading = false,
    this.onSeeAll,
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
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Student Testimonials",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppColors.brightPinkCrayola,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.medium,
        if (isLoading)
          const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (testimonials.isEmpty)
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card2.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No testimonials available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: testimonials.length,
              itemBuilder: (context, index) {
                return TestimonialCard(
                  testimonial: testimonials[index],
                  onTap: () {
                    _showTestimonialDetail(context, testimonials[index]);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _showTestimonialDetail(BuildContext context, Testimonial testimonial) {
    final type = testimonial.testimonialType.toLowerCase();
    
    // For video testimonials, show video player instead of dialog
    if (type == 'video_youtube' && testimonial.youtubeVideoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YoutubePreviewPlayer(
            videoUrl: 'https://youtube.com/watch?v=${testimonial.youtubeVideoId}',
            courseTitle: '${testimonial.studentName} - ${testimonial.courseName}',
          ),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Media section for non-YouTube content
              if (type != 'text_image' || testimonial.studentPhoto != null)
                _buildDetailMediaSection(testimonial),
              
              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  testimonial.studentName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  testimonial.courseName,
                                  style: TextStyle(
                                    color: AppColors.brightPinkCrayola,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                      
                      AppSpacing.medium,
                      
                      // Rating and type
                      Row(
                        children: [
                          Row(
                            children: [
                              for (int i = 1; i <= 5; i++)
                                Icon(
                                  i <= testimonial.overallRating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                '${testimonial.overallRating}/5',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(type).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getTypeColor(type).withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getTypeIcon(type),
                                  color: _getTypeColor(type),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTypeLabel(type),
                                  style: TextStyle(
                                    color: _getTypeColor(type),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      AppSpacing.medium,
                      
                      // Content based on type
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Audio player controls for audio testimonials
                              if (type == 'audio' && testimonial.audioFile != null) 
                                _buildAudioPlayer(testimonial.audioFile!),
                              
                              // Text content (if available)
                              if (testimonial.testimonialText.isNotEmpty) ...[
                                Text(
                                  testimonial.testimonialText,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                AppSpacing.medium,
                              ],
                              
                              // Additional details
                              if (testimonial.currentPosition != null && testimonial.currentPosition!.isNotEmpty ||
                                  testimonial.currentCompany != null && testimonial.currentCompany!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[700]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Current Status',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (testimonial.currentPosition != null && testimonial.currentPosition!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.work, color: Colors.grey[400], size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              testimonial.currentPosition!,
                                              style: TextStyle(color: Colors.grey[300], fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      if (testimonial.currentCompany != null && testimonial.currentCompany!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.business, color: Colors.grey[400], size: 16),
                                            const SizedBox(width: 8),
                                            Text(
                                              testimonial.currentCompany!,
                                              style: TextStyle(color: Colors.grey[300], fontSize: 14),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                                AppSpacing.medium,
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AllTestimonialsPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'View All Testimonials',
                                style: TextStyle(color: AppColors.brightPinkCrayola),
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
      ),
    );
  }
  
  Widget _buildDetailMediaSection(Testimonial testimonial) {
    final type = testimonial.testimonialType.toLowerCase();
    
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          if (type == 'text_image' && testimonial.studentPhoto != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: testimonial.studentPhoto!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildMediaPlaceholder(type),
                errorWidget: (context, url, error) => _buildMediaPlaceholder(type),
              ),
            )
          else if (type == 'video_upload' && testimonial.videoThumbnail != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: testimonial.videoThumbnail!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildMediaPlaceholder(type),
                errorWidget: (context, url, error) => _buildMediaPlaceholder(type),
              ),
            )
          else
            _buildMediaPlaceholder(type),
          
          // Overlay for video types
          if (type.startsWith('video'))
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          
          // Type badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeColor(type),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getTypeLabel(type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMediaPlaceholder(String type) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          colors: [
            _getTypeColor(type).withValues(alpha: 0.8),
            _getTypeColor(type).withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(type),
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 12),
            Text(
              _getTypeLabel(type),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAudioPlayer(String audioUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Testimonial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to play audio',
                  style: TextStyle(
                    color: Colors.purple[300],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getTypeColor(String type) {
    switch (type) {
      case 'video_youtube':
        return Colors.red;
      case 'video_upload':
        return Colors.blue;
      case 'audio':
        return Colors.purple;
      case 'text_image':
      default:
        return AppColors.brightPinkCrayola;
    }
  }
  
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'video_youtube':
        return Icons.play_circle_fill;
      case 'video_upload':
        return Icons.videocam;
      case 'audio':
        return Icons.mic;
      case 'text_image':
      default:
        return Icons.chat_bubble;
    }
  }
  
  String _getTypeLabel(String type) {
    switch (type) {
      case 'video_youtube':
        return 'YouTube';
      case 'video_upload':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'text_image':
      default:
        return 'Text';
    }
  }
}

class NewsSection extends StatelessWidget {
  final List<NewsArticle> news;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const NewsSection({
    super.key,
    required this.news,
    this.isLoading = false,
    this.onSeeAll,
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
              const Row(
                children: [
                  Icon(
                    Icons.newspaper,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Latest News & Updates",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    backgroundColor: AppColors.brightPinkCrayola,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.medium,
        if (isLoading)
          const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (news.isEmpty)
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card2.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.newspaper,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No news available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: news.length,
              itemBuilder: (context, index) {
                return NewsCard(
                  article: news[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(article: news[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}