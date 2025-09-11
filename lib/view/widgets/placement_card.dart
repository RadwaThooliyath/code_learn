import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PlacementCard extends StatelessWidget {
  final Placement placement;
  final VoidCallback? onTap;

  const PlacementCard({
    super.key,
    required this.placement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 200, // Fixed height to prevent overflow
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: placement.studentPhoto != null
                        ? CachedNetworkImageProvider(placement.studentPhoto!)
                        : null,
                    child: placement.studentPhoto == null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey[500],
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          placement.studentName,
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
                          placement.courseCompleted,
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (placement.companyLogo != null)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: placement.companyLogo!,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.business,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.business,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppColors.brightPinkCrayola,
                        size: 16,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          placement.companyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          placement.jobTitle,
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
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (placement.canShowPackage && placement.packageAmount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.brightPinkCrayola,
                                  AppColors.coral,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₹${placement.packageAmount!.toStringAsFixed(1)} LPA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (placement.location != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[400],
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  placement.location!,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getPlacementTypeColor(placement.placementType),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        placement.placementTypeDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPlacementTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full_time':
        return Colors.green;
      case 'internship':
        return Colors.blue;
      case 'freelance':
        return Colors.orange;
      case 'contract':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}