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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results card
            Card(
              color: AppColors.champagnePink,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Status icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                      child: Icon(
                        isPassed ? Icons.check : Icons.close,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      isPassed ? 'Congratulations!' : 'Quiz Not Passed',
                      style: AppTextStyle.headline1.copyWith(
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      quiz.title,
                      style: AppTextStyle.headline2,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Score display
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPassed ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${attempt.score ?? 0}',
                            style: AppTextStyle.headline1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            ' / ${quiz.maxPoints}',
                            style: AppTextStyle.headline1.copyWith(
                              fontSize: 24,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      '${scorePercentage.toStringAsFixed(1)}%',
                      style: AppTextStyle.headline1.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quiz details
            Card(
              color: AppColors.champagnePink,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Details',
                      style: AppTextStyle.headline2,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildDetailRow('Passing Score', '${quiz.passingScore}%'),
                    _buildDetailRow('Time Taken', _formatTime(attempt.timeSpent)),
                    _buildDetailRow('Time Limit', '${quiz.timeLimit} minutes'),
                    _buildDetailRow('Attempt Number', '${attempt.attemptNumber}'),
                    _buildDetailRow('Total Questions', '${quiz.questions.length}'),
                    _buildDetailRow('Date Completed', _formatDate(attempt.completedAt)),
                    
                    if (quiz.showResultsImmediately)
                      _buildDetailRow('Status', isPassed ? 'PASSED' : 'FAILED'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Feedback card
            Card(
              color: AppColors.champagnePink,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedback',
                      style: AppTextStyle.headline2,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    if (isPassed) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Great job! You have successfully passed this quiz.',
                                style: AppTextStyle.bodyText.copyWith(
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You need ${quiz.passingScore}% to pass this quiz.',
                                    style: AppTextStyle.bodyText.copyWith(
                                      color: Colors.red[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (quiz.maxAttempts > 1) ...[
                              const SizedBox(height: 8),
                              Text(
                                'You can try again. You have ${quiz.maxAttempts - attempt.attemptNumber} attempts remaining.',
                                style: AppTextStyle.caption.copyWith(
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    
                    if (quiz.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'About this quiz:',
                        style: AppTextStyle.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.description,
                        style: AppTextStyle.bodyText.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                if (!isPassed && quiz.maxAttempts > attempt.attemptNumber)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // The parent screen can handle retaking the quiz
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoBrightBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                
                if (!isPassed && quiz.maxAttempts > attempt.attemptNumber)
                  const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back to Course'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyle.bodyText.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.bodyText.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
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
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}