import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/quiz_model.dart';
import 'package:uptrail/services/quiz_service.dart';
import 'package:uptrail/view/quiz_results_page.dart';

class QuizTakingPage extends StatefulWidget {
  final Quiz quiz;

  const QuizTakingPage({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends State<QuizTakingPage> {
  final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();
  
  QuizAttempt? _currentAttempt;
  Map<int, List<int>> _selectedAnswers = {};
  Map<int, String?> _textAnswers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  Timer? _timer;
  int _remainingTimeInSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startQuizAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _startQuizAttempt() async {
    try {
      final attempt = await _quizService.startQuizAttempt(widget.quiz.id);
      setState(() {
        _currentAttempt = attempt;
        _remainingTimeInSeconds = widget.quiz.timeLimit * 60; // Convert to seconds
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11); // Remove "Exception: " prefix
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unable to Start Quiz'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTimeInSeconds > 0) {
          _remainingTimeInSeconds--;
        } else {
          timer.cancel();
          _submitQuiz();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  void _selectAnswer(int questionId, int choiceId) {
    setState(() {
      _selectedAnswers[questionId] = [choiceId];
    });
  }

  void _setTextAnswer(int questionId, String answer) {
    setState(() {
      _textAnswers[questionId] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting || _currentAttempt == null) return;

    bool hasUnanswered = false;
    for (final question in widget.quiz.questions) {
      if (question.questionType == 'multiple_choice') {
        if (!_selectedAnswers.containsKey(question.id) || 
            _selectedAnswers[question.id]!.isEmpty) {
          hasUnanswered = true;
          break;
        }
      } else {
        if (!_textAnswers.containsKey(question.id) || 
            _textAnswers[question.id]?.trim().isEmpty == true) {
          hasUnanswered = true;
          break;
        }
      }
    }

    if (hasUnanswered) {
      final shouldSubmit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Quiz'),
          content: const Text('You have unanswered questions. Do you want to submit anyway?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        ),
      );
      
      if (shouldSubmit != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = <QuizAnswer>[];
      
      for (final question in widget.quiz.questions) {
        if (question.questionType == 'multiple_choice') {
          final selectedChoices = _selectedAnswers[question.id] ?? [];
          if (selectedChoices.isNotEmpty) {
            answers.add(QuizAnswer(
              question: question.id,
              selectedChoice: selectedChoices.first,
            ));
          }
        } else {
          final textAnswer = _textAnswers[question.id];
          if (textAnswer != null && textAnswer.trim().isNotEmpty) {
            answers.add(QuizAnswer(
              question: question.id,
              textAnswer: textAnswer,
            ));
          }
        }
      }

      final result = await _quizService.submitQuizAttempt(
        attemptId: _currentAttempt!.id,
        answers: answers,
      );

      _timer?.cancel();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultsPage(
              quiz: widget.quiz,
              attempt: result,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11); // Remove "Exception: " prefix
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to Submit Quiz'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.logoBrightBlue,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz'),
            content: const Text('Are you sure you want to exit? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.background,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _remainingTimeInSeconds < 300 ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(_remainingTimeInSeconds),
                style: TextStyle(
                  color: _remainingTimeInSeconds < 300 ? Colors.white : AppColors.logoBrightBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.champagnePink,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Text(
                        '${widget.quiz.questions[_currentQuestionIndex].points} point${widget.quiz.questions[_currentQuestionIndex].points != 1 ? 's' : ''}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.logoBrightBlue),
                  ),
                ],
              ),
            ),
            
            // Question content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentQuestionIndex = index;
                  });
                },
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  return _buildQuestionCard(question);
                },
              ),
            ),
            
            // Navigation and question overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.champagnePink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Question overview dots
                  Wrap(
                    spacing: 8,
                    children: List.generate(widget.quiz.questions.length, (index) {
                      final question = widget.quiz.questions[index];
                      final isAnswered = question.questionType == 'multiple_choice'
                          ? _selectedAnswers.containsKey(question.id) && _selectedAnswers[question.id]!.isNotEmpty
                          : _textAnswers.containsKey(question.id) && _textAnswers[question.id]?.trim().isNotEmpty == true;
                      
                      return GestureDetector(
                        onTap: () => _goToQuestion(index),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: index == _currentQuestionIndex
                                ? AppColors.logoBrightBlue
                                : isAnswered
                                    ? Colors.green
                                    : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index == _currentQuestionIndex || isAnswered
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _previousQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      
                      if (_currentQuestionIndex > 0 && _currentQuestionIndex < widget.quiz.questions.length - 1)
                        const SizedBox(width: 16),
                      
                      if (_currentQuestionIndex < widget.quiz.questions.length - 1)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.logoBrightBlue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Next'),
                          ),
                        ),
                      
                      if (_currentQuestionIndex == widget.quiz.questions.length - 1)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Submit Quiz'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppColors.champagnePink,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.questionText,
                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              if (question.questionType == 'multiple_choice')
                ..._buildMultipleChoiceOptions(question),
              
              if (question.questionType == 'short_answer' || question.questionType == 'text')
                _buildTextAnswerField(question),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(QuizQuestion question) {
    return question.choices.map((choice) {
      final isSelected = _selectedAnswers[question.id]?.contains(choice.id) == true;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => _selectAnswer(question.id, choice.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.logoBrightBlue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.logoBrightBlue.withValues(alpha: 0.1) : Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.logoBrightBlue : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.logoBrightBlue : Colors.white,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    choice.choiceText,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTextAnswerField(QuizQuestion question) {
    return TextFormField(
      onChanged: (value) => _setTextAnswer(question.id, value),
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Enter your answer here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.logoBrightBlue, width: 2),
        ),
      ),
    );
  }
}