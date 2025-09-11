import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:flutter/services.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () => _shareArticle(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.featuredImage != null)
                    CachedNetworkImage(
                      imageUrl: article.featuredImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.card2,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildDefaultHeader(),
                    )
                  else
                    _buildDefaultHeader(),
                  // Gradient overlay
                  Container(
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
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brightPinkCrayola.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          article.categoryDisplay,
                          style: TextStyle(
                            color: AppColors.brightPinkCrayola,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(article.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  AppSpacing.large,
                  
                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  
                  AppSpacing.medium,
                  
                  // Meta info
                  Row(
                    children: [
                      if (article.createdBy.isNotEmpty) ...[
                        Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'By ${article.createdBy}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.visibility,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${article.viewCount} views',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.large,
                  
                  // Excerpt
                  if (article.excerpt.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card2.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.logoDarkTeal.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        article.excerpt,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                    AppSpacing.large,
                  ],
                  
                  // Content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card2.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.content,
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  
                  AppSpacing.large,
                  
                  // Tags
                  if (article.tags != null && article.tags!.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.medium,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _parseTags(article.tags!).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.logoDarkTeal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.logoDarkTeal.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              color: AppColors.logoDarkTeal,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AppSpacing.large,
                  ],
                  
                  // Bottom actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: () => _shareArticle(context),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[700],
                        ),
                        _buildActionButton(
                          icon: Icons.bookmark_border,
                          label: 'Save',
                          onTap: () => _saveArticle(context),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[700],
                        ),
                        _buildActionButton(
                          icon: Icons.feedback_outlined,
                          label: 'Feedback',
                          onTap: () => _provideFeedback(context),
                        ),
                      ],
                    ),
                  ),
                  
                  AppSpacing.veryLarge,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader() {
    return Container(
      decoration: BoxDecoration(
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
            Icon(
              Icons.newspaper,
              size: 80,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'News Article',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: AppColors.brightPinkCrayola,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  List<String> _parseTags(String tags) {
    return tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _shareArticle(BuildContext context) {
    // Create shareable text
    final shareText = '''
${article.title}

${article.excerpt}

Read more: https://uptrail.info/news/${article.slug}
    ''';

    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Article link copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.brightPinkCrayola,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _saveArticle(BuildContext context) {
    // TODO: Implement save functionality with local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.bookmark, color: Colors.white),
            SizedBox(width: 8),
            Text('Article saved for later reading!'),
          ],
        ),
        backgroundColor: AppColors.logoDarkTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _provideFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Article Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you rate this article?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeedbackButton(
                  context,
                  icon: Icons.thumb_up,
                  label: 'Helpful',
                  color: Colors.green,
                ),
                _buildFeedbackButton(
                  context,
                  icon: Icons.thumb_down,
                  label: 'Not Helpful',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}