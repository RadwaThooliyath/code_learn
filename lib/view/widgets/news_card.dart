import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
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
            if (article.featuredImage != null || article.thumbnail != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: article.thumbnail ?? article.featuredImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 120,
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 120,
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.brightPinkCrayola,
                              AppColors.coral,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    if (article.isFeatured) AppSpacing.small,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(article.category).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.categoryDisplay,
                            style: TextStyle(
                              color: _getCategoryColor(article.category),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (article.viewCount > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Colors.grey[500],
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${article.viewCount}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    AppSpacing.small,
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.small,
                    Expanded(
                      child: Text(
                        article.excerpt,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.small,
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey[500],
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'By ${article.createdBy}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'course_updates':
        return Colors.blue;
      case 'industry_news':
        return Colors.orange;
      case 'student_success':
        return Colors.green;
      case 'career_guidance':
        return Colors.purple;
      case 'technology_trends':
        return Colors.teal;
      default:
        return AppColors.brightPinkCrayola;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}