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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Quiz Results',
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
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
                color: AppColors.champagnePink,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
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
                          ? [Colors.green[300]!, Colors.green[600]!]
                          : [Colors.red[300]!, Colors.red[600]!],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isPassed ? Colors.green : Colors.red).withValues(alpha: 0.4),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Icon(
                      isPassed ? Icons.celebration : Icons.refresh,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Status Text
                  Text(
                    isPassed ? 'Congratulations!' : 'Keep Trying!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isPassed ? 'You passed the quiz!' : 'You can do better next time',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
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
                          ? [Colors.green[100]!, Colors.green[200]!]
                          : [Colors.red[100]!, Colors.red[200]!],
                      ),
                      border: Border.all(
                        color: isPassed ? Colors.green[400]! : Colors.red[400]!,
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${attempt.score ?? 0}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: isPassed ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        Text(
                          'out of ${quiz.maxPoints}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPassed ? Colors.green[600] : Colors.red[600],
                            borderRadius: BorderRadius.circular(12),
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
            
            const SizedBox(height: 24),
            
            // Quiz Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.champagnePink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                      Text(
                        quiz.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPassed ? Colors.green[200]! : Colors.orange[200]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.check_circle : Icons.lightbulb_outline,
                    color: isPassed ? Colors.green[600] : Colors.orange[600],
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isPassed 
                      ? 'Excellent work! You have successfully mastered this topic.'
                      : "Don\\'t give up! Review the material and try again.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPassed ? Colors.green[700] : Colors.orange[700],
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
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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