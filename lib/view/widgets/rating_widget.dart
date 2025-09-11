import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showNumber;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.activeColor,
    this.inactiveColor,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starRating = index + 1;
          return Icon(
            starRating <= rating
                ? Icons.star
                : starRating - 0.5 <= rating
                    ? Icons.star_half
                    : Icons.star_border,
            size: size,
            color: starRating <= rating + 0.5
                ? activeColor ?? Colors.amber
                : inactiveColor ?? Colors.grey[400],
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int initialRating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(int rating) onRatingChanged;
  final bool enabled;

  const InteractiveStarRating({
    super.key,
    required this.onRatingChanged,
    this.initialRating = 0,
    this.maxRating = 5,
    this.size = 30,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late int currentRating;

  @override
  void initState() {
    super.initState();
    currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(InteractiveStarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      currentRating = widget.initialRating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starRating = index + 1;
        return GestureDetector(
          onTap: widget.enabled
              ? () {
                  setState(() {
                    currentRating = starRating;
                  });
                  widget.onRatingChanged(starRating);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Icon(
              starRating <= currentRating
                  ? Icons.star
                  : Icons.star_border,
              size: widget.size,
              color: starRating <= currentRating
                  ? widget.activeColor ?? Colors.amber
                  : widget.inactiveColor ?? Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}

class RatingDistribution extends StatelessWidget {
  final Map<String, int> distribution;
  final int totalRatings;
  final double maxBarWidth;

  const RatingDistribution({
    super.key,
    required this.distribution,
    required this.totalRatings,
    this.maxBarWidth = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = distribution[stars.toString()] ?? 0;
        final percentage = totalRatings > 0 ? count / totalRatings : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.green1,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class RatingCard extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<String, int> distribution;
  final VoidCallback? onViewAllReviews;

  const RatingCard({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
    this.onViewAllReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.champagnePink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Ratings & Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                if (onViewAllReviews != null)
                  TextButton(
                    onPressed: onViewAllReviews,
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      StarRating(
                        rating: averageRating,
                        size: 24,
                        activeColor: Colors.red,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalRatings ${totalRatings == 1 ? 'review' : 'reviews'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: RatingDistribution(
                    distribution: distribution,
                    totalRatings: totalRatings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}