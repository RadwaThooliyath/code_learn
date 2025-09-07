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
        backgroundColor: AppColors.logoLightGray,
        appBar: AppBar(
          title: Text(
            widget.quiz.title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.logoBrightBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _remainingTimeInSeconds < 300 
                    ? AppColors.brightPinkCrayola 
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: _remainingTimeInSeconds < 300 
                        ? Colors.white 
                        : AppColors.logoBrightBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingTimeInSeconds),
                    style: TextStyle(
                      color: _remainingTimeInSeconds < 300 
                          ? Colors.white 
                          : AppColors.logoBrightBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.logoBrightBlue.withValues(alpha: 0.1),
                    AppColors.logoGreen.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Progress: ${((_currentQuestionIndex + 1) / widget.quiz.questions.length * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.logoGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.quiz.questions[_currentQuestionIndex].points} point${widget.quiz.questions[_currentQuestionIndex].points != 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.logoGreen),
                      minHeight: 6,
                    ),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, -4),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            gradient: index == _currentQuestionIndex
                                ? LinearGradient(
                                    colors: [AppColors.logoBrightBlue, AppColors.logoGreen],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : isAnswered
                                    ? LinearGradient(
                                        colors: [AppColors.logoGreen, AppColors.logoGreen.withValues(alpha: 0.8)],
                                      )
                                    : null,
                            color: index == _currentQuestionIndex || isAnswered 
                                ? null 
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: index == _currentQuestionIndex
                                  ? AppColors.logoBrightBlue
                                  : isAnswered
                                      ? AppColors.logoGreen
                                      : Colors.grey[400]!,
                              width: index == _currentQuestionIndex ? 2 : 1,
                            ),
                            boxShadow: index == _currentQuestionIndex || isAnswered ? [
                              BoxShadow(
                                color: (index == _currentQuestionIndex 
                                    ? AppColors.logoBrightBlue 
                                    : AppColors.logoGreen).withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Center(
                            child: isAnswered && index != _currentQuestionIndex
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index == _currentQuestionIndex || isAnswered
                                          ? Colors.white
                                          : Colors.black87,
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
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.logoBrightBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: AppColors.logoBrightBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Question ${_currentQuestionIndex + 1}',
                      style: TextStyle(
                        color: AppColors.logoBrightBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
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
    return question.choices.asMap().entries.map((entry) {
      final index = entry.key;
      final choice = entry.value;
      final isSelected = _selectedAnswers[question.id]?.contains(choice.id) == true;
      final optionLetter = String.fromCharCode(65 + index); // A, B, C, D...
      
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectAnswer(question.id, choice.id),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? LinearGradient(
                        colors: [
                          AppColors.logoBrightBlue.withValues(alpha: 0.1),
                          AppColors.logoGreen.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(
                  color: isSelected ? AppColors.logoBrightBlue : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? null : AppColors.logoLightGray,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.logoBrightBlue.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.logoBrightBlue : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.logoBrightBlue : Colors.grey[400]!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        optionLetter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.logoBrightBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      choice.choiceText,
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.black87,
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.logoGreen,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTextAnswerField(QuizQuestion question) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        onChanged: (value) => _setTextAnswer(question.id, value),
        maxLines: 5,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: 'Type your answer here...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          filled: true,
          fillColor: AppColors.logoLightGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.logoBrightBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.edit_note,
              color: AppColors.logoBrightBlue,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}