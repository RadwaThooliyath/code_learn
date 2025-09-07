import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/utils/app_text_style.dart';

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
      backgroundColor: AppColors.logoLightGray,
      appBar: AppBar(
        title: const Text(
          'Quiz Results',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isPassed ? AppColors.logoGreen : AppColors.coral,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Results Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPassed ? [
                    Colors.white,
                    AppColors.logoGreen.withValues(alpha: 0.05),
                  ] : [
                    Colors.white,
                    AppColors.coral.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isPassed 
                        ? AppColors.logoGreen.withValues(alpha: 0.1)
                        : AppColors.coral.withValues(alpha: 0.1),
                    spreadRadius: 3,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isPassed 
                      ? AppColors.logoGreen.withValues(alpha: 0.2)
                      : AppColors.coral.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Status Icon with Animation-like Effect
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isPassed 
                          ? [AppColors.logoGreen, AppColors.logoGreen.withValues(alpha: 0.8)]
                          : [AppColors.coral, AppColors.brightPinkCrayola.withValues(alpha: 0.8)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPassed 
                              ? AppColors.logoGreen.withValues(alpha: 0.4)
                              : AppColors.coral.withValues(alpha: 0.4),
                          spreadRadius: 8,
                          blurRadius: 25,
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
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Status Text
                  Text(
                    isPassed ? '🎉 Congratulations!' : '💪 Keep Trying!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? AppColors.logoGreen : AppColors.coral,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
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
                  
                  const SizedBox(height: 32),
                  
                  // Score Circle
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isPassed 
                          ? [
                              AppColors.logoGreen.withValues(alpha: 0.1),
                              AppColors.logoGreen.withValues(alpha: 0.2),
                            ]
                          : [
                              AppColors.coral.withValues(alpha: 0.1),
                              AppColors.brightPinkCrayola.withValues(alpha: 0.2),
                            ],
                      ),
                      border: Border.all(
                        color: isPassed ? AppColors.logoGreen : AppColors.coral,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isPassed 
                              ? AppColors.logoGreen.withValues(alpha: 0.2)
                              : AppColors.coral.withValues(alpha: 0.2),
                          spreadRadius: 4,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${attempt.score ?? 0}',
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? AppColors.logoGreen : AppColors.coral,
                          ),
                        ),
                        Text(
                          'out of ${quiz.maxPoints}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPassed 
                                  ? [AppColors.logoGreen, AppColors.logoGreen.withValues(alpha: 0.8)]
                                  : [AppColors.coral, AppColors.brightPinkCrayola],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isPassed 
                                    ? AppColors.logoGreen.withValues(alpha: 0.3)
                                    : AppColors.coral.withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${scorePercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
            
            const SizedBox(height: 24),
            
            // Quiz Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        color: AppColors.logoBrightBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quiz.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          Icons.timer_outlined,
                          'Time Taken',
                          _formatTime(attempt.timeSpent),
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          Icons.help_outline,
                          'Questions',
                          '${quiz.questions.length}',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          Icons.trending_up_outlined,
                          'Passing Score',
                          '${quiz.passingScore}%',
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          Icons.repeat_outlined,
                          'Attempt',
                          '${attempt.attemptNumber}/${quiz.maxAttempts}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Feedback Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPassed ? [
                    AppColors.logoGreen.withValues(alpha: 0.05),
                    AppColors.logoGreen.withValues(alpha: 0.1),
                  ] : [
                    AppColors.logoYellow.withValues(alpha: 0.05),
                    AppColors.coral.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPassed ? AppColors.logoGreen.withValues(alpha: 0.3) : AppColors.coral.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPassed 
                        ? AppColors.logoGreen.withValues(alpha: 0.1)
                        : AppColors.coral.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPassed ? AppColors.logoGreen : AppColors.coral,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isPassed 
                              ? AppColors.logoGreen.withValues(alpha: 0.3)
                              : AppColors.coral.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPassed ? Icons.star : Icons.trending_up,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed 
                        ? '🌟 Excellent work! You have successfully mastered this topic.'
                        : '📚 Don\'t give up! Review the material and try again.',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? AppColors.logoGreen : AppColors.coral,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isPassed && quiz.maxAttempts > attempt.attemptNumber) ...[
                    const SizedBox(height: 8),
                    Text(
                      'You have ${quiz.maxAttempts - attempt.attemptNumber} attempts remaining.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                if (!isPassed && quiz.maxAttempts > attempt.attemptNumber)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: AppColors.coral.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                
                if (!isPassed && quiz.maxAttempts > attempt.attemptNumber)
                  const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoBrightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      shadowColor: AppColors.logoBrightBlue.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.logoBrightBlue,
          size: 20,
        ),
        const SizedBox(height: 4),
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