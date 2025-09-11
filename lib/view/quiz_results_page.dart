import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:uptrail/utils/app_decoration.dart';
import 'package:uptrail/utils/app_spacing.dart';

class QuizResultsPage extends StatelessWidget {
  final Quiz quiz;
  final QuizAttempt attempt;

  const QuizResultsPage({
    super.key,
    required this.quiz,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    final scorePercentage = double.tryParse(attempt.scorePercentage) ?? 0.0;
    final isPassed = attempt.isPassed.toLowerCase() == 'true' || 
                    attempt.isPassed.toLowerCase() == 'passed';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            // Main Results Card
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingXL,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPassed ? [
                    AppColors.champagnePink,
                    AppColors.champagnePink,
                  ] : [
                    Colors.white,
                    AppColors.champagnePink.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: AppDecoration.borderRadiusXL,
                boxShadow: AppDecoration.mediumShadow,
                border: Border.all(
                  color: isPassed 
                      ? AppColors.champagnePink.withValues(alpha: 0.2)
                      : AppColors.brightPinkCrayola,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Status Icon with Animation-like Effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isPassed 
                          ? [AppColors.brightPinkCrayola, AppColors.champagnePink]
                          : [AppColors.coral, AppColors.brightPinkCrayola],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPassed 
                              ? AppColors.green1.withValues(alpha: 0.3)
                              : AppColors.coral.withValues(alpha: 0.3),
                          spreadRadius: 4,
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isPassed ? Icons.emoji_events : Icons.trending_up,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  AppSpacing.medium,
                  
                  // Status Text
                  Text(
                    isPassed ? 'Congratulations!' : 'Keep Trying!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.black54 : AppColors.coral,
                    ),
                  ),
                  
                  AppSpacing.verySmall,
                  
                  Text(
                    isPassed 
                        ? 'Outstanding work! You\'ve mastered this quiz.' 
                        : 'Don\'t give up! Review and try again.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  AppSpacing.large,
                  
                  // Score Circle
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPassed 
                          ? [
                              AppColors.champagnePink.withValues(alpha: 0.8),
                              AppColors.champagnePink.withValues(alpha: 0.1),
                            ]
                          : [
                              AppColors.champagnePink.withValues(alpha: 0.8),
                              AppColors.coral.withValues(alpha: 0.1),
                            ],
                      ),
                      border: Border.all(
                        color: isPassed ? AppColors.green1 : AppColors.coral,
                        width: 3,
                      ),
                      boxShadow: AppDecoration.softShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${attempt.score ?? 0}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? AppColors.green1 : AppColors.coral,
                          ),
                        ),
                        Text(
                          'out of ${quiz.maxPoints}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppSpacing.verySmall,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPassed 
                                  ? [AppColors.green1, AppColors.robinEggBlue]
                                  : [AppColors.coral, AppColors.brightPinkCrayola],
                            ),
                            borderRadius: AppDecoration.borderRadiusXL,
                            boxShadow: AppDecoration.softShadow,
                          ),
                          child: Text(
                            '${scorePercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.medium,
            
            // Quiz Details Card
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingL,
              decoration: BoxDecoration(
                color: AppColors.champagnePink,
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppSpacing.paddingS,
                        decoration: BoxDecoration(
                          color: AppColors.champagnePink,
                          borderRadius: AppDecoration.borderRadiusS,
                        ),
                        child: Icon(
                          Icons.quiz_outlined,
                          color: AppColors.logoBrightBlue,
                          size: 20,
                        ),
                      ),
                      AppSpacing.hSmall,
                      Expanded(
                        child: Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.small,
                  
                  // Details Grid - Fixed render flex issue with Flexible
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: _buildDetailItem(
                          Icons.timer_outlined,
                          'Time Taken',
                          _formatTime(attempt.timeSpent),
                        ),
                      ),
                      AppSpacing.hSmall,
                      Flexible(
                        flex: 1,
                        child: _buildDetailItem(
                          Icons.help_outline,
                          'Questions',
                          '${quiz.questions.length}',
                        ),
                      ),
                    ],
                  ),
                  
                  AppSpacing.small,
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 1,
                        child: _buildDetailItem(
                          Icons.trending_up_outlined,
                          'Passing Score',
                          '${quiz.passingScore}%',
                        ),
                      ),
                      AppSpacing.hSmall,
                      Flexible(
                        flex: 1,
                        child: _buildDetailItem(
                          Icons.repeat_outlined,
                          'Attempt',
                          '#${attempt.attemptNumber}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            AppSpacing.medium,
            
            // Feedback Section
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingL,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPassed ? [
                    AppColors.green2,
                    AppColors.green1,
                  ] : [
                    AppColors.champagnePink.withValues(alpha: 0.8),
                    AppColors.coral.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: AppDecoration.borderRadiusL,
                border: Border.all(
                  color: isPassed ? AppColors.green1.withValues(alpha: 0.3) : AppColors.coral.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: AppDecoration.softShadow,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.green1 : AppColors.coral,
                      shape: BoxShape.circle,
                      boxShadow: AppDecoration.softShadow,
                    ),
                    child: Icon(
                      isPassed ? Icons.star : Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  AppSpacing.small,
                  Text(
                    isPassed 
                        ? 'Excellent work! You have successfully mastered this topic.'
                        : 'Don\'t give up! Review the material and try again.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? AppColors.white : Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            AppSpacing.large,
            
            // Action Buttons - Fixed render flex issue
            Column(
              children: [
                if (!isPassed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shadowColor: AppColors.coral.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDecoration.borderRadiusL,
                        ),
                      ),
                    ),
                  ),
                
                if (!isPassed)
                  AppSpacing.small,
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brightPinkCrayola,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Course'),

                  ),
                ),
              ],
            ),
            
            AppSpacing.medium,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: AppSpacing.paddingM,
      decoration: BoxDecoration(
        color: AppColors.champagnePink.withValues(alpha: 0.2),
        borderRadius: AppDecoration.borderRadiusM,
        border: Border.all(
          color: AppColors.brightPinkCrayola.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingS,
            decoration: BoxDecoration(
              color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.logoBrightBlue,
              size: 18,
            ),
          ),
          AppSpacing.verySmall,
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }
}