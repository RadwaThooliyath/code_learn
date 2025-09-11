import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_spacing.dart';

class StatsWidget extends StatefulWidget {
  final DashboardStats stats;

  const StatsWidget({
    super.key,
    required this.stats,
  });

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.logoDarkTeal,
            AppColors.brightPinkCrayola.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brightPinkCrayola.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Our Success Story',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.medium,
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  value: widget.stats.totalStudents,
                  label: 'Students',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.work,
                  value: widget.stats.totalPlacements,
                  label: 'Placements',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          AppSpacing.medium,
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  value: widget.stats.averagePackage.toInt(),
                  label: 'Avg Package (LPA)',
                  color: Colors.orange,
                  isDecimal: true,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.school,
                  value: widget.stats.coursesAvailable,
                  label: 'Courses',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
    bool isDecimal = false,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedValue = (_animation.value * value).toInt();
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              AppSpacing.small,
              Text(
                isDecimal ? '${widget.stats.averagePackage.toStringAsFixed(1)}' : '$animatedValue',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}