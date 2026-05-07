import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String courseId;
  final String subjectId;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.courseId,
    required this.subjectId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _service = FirestoreService.instance;
  final _user = FirebaseAuth.instance.currentUser;

  Timer? _timer;
  List<QuizQuestion> _questions = const [];
  List<int?> _selectedAnswers = const [];
  int _currentIndex = 0;
  int _remainingSeconds = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    try {
      if (_user == null) {
        throw StateError('Please sign in before starting a quiz.');
      }

      final questions = await _service.questionsForQuiz(widget.quiz.id).first;
      final progress = await _service.getProgress(
        userId: _user.uid,
        quizId: widget.quiz.id,
      );

      final selectedAnswers = List<int?>.filled(questions.length, null);
      if (progress != null) {
        for (var i = 0;
            i < progress.selectedAnswers.length && i < selectedAnswers.length;
            i++) {
          selectedAnswers[i] = progress.selectedAnswers[i];
        }
      }

      if (!mounted) return;
      final restoredIndex = progress?.currentQuestionIndex ?? 0;
      final boundedIndex = questions.isEmpty
          ? 0
          : restoredIndex.clamp(0, questions.length - 1).toInt();
      setState(() {
        _questions = questions;
        _selectedAnswers = selectedAnswers;
        _currentIndex = boundedIndex;
        _remainingSeconds =
            (widget.quiz.duration <= 0 ? 10 : widget.quiz.duration) * 60;
        _isLoading = false;
      });

      _startTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Time is up. Submit after answering all questions.'),
          ),
        );
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: AppBackground(child: LoadingState(message: 'Preparing quiz...')),
      );
    }

    if (_error != null) {
      return Scaffold(body: AppBackground(child: ErrorState(error: _error)));
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: AppBackground(
          child: EmptyState(
            icon: Icons.help_outline_rounded,
            title: 'No questions yet',
            message: 'Add questions for this quiz from Admin.',
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final isLastQuestion = _currentIndex == _questions.length - 1;
    final answeredCount =
        _selectedAnswers.where((answer) => answer != null).length;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.quiz.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _BookmarkButton(question: currentQuestion, user: _user),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TimerPill(seconds: _remainingSeconds),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length} | $answeredCount answered',
                ),
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        currentQuestion.questionText,
                        key: ValueKey(currentQuestion.id),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: currentQuestion.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, optionIndex) {
                      final selected =
                          _selectedAnswers[_currentIndex] == optionIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                            width: selected ? 1.8 : 1.0,
                          ),
                        ),
                        child: RadioListTile<int>(
                          value: optionIndex,
                          groupValue: _selectedAnswers[_currentIndex],
                          onChanged: (value) {
                            _selectAnswer(value);
                          },
                          title: Text(
                            currentQuestion.options[optionIndex],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _currentIndex == 0
                            ? null
                            : () => _moveToQuestion(_currentIndex - 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                if (!isLastQuestion) {
                                  _moveToQuestion(_currentIndex + 1);
                                  return;
                                }
                                _submitQuiz();
                              },
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isLastQuestion
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.arrow_forward_rounded,
                              ),
                        label: Text(isLastQuestion ? 'Submit' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectAnswer(int? value) async {
    if (value == null || _user == null) return;
    setState(() {
      _selectedAnswers[_currentIndex] = value;
    });
    await _saveProgress();
  }

  Future<void> _moveToQuestion(int index) async {
    setState(() {
      _currentIndex = index;
    });
    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    final user = _user;
    if (user == null) return;

    await _service.saveProgress(
      userId: user.uid,
      quizId: widget.quiz.id,
      currentQuestionIndex: _currentIndex,
      selectedAnswers: _selectedAnswers,
    );
  }

  Future<void> _submitQuiz() async {
    final user = _user;
    if (user == null) return;

    final unanswered = _selectedAnswers.where((answer) => answer == null).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Please answer all questions before submitting. ($unanswered left)',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    var correctAnswers = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }

    try {
      await _service.saveAttempt(
        user: user,
        quiz: widget.quiz,
        courseId: widget.courseId,
        subjectId: widget.subjectId,
        questions: _questions,
        selectedAnswers: _selectedAnswers,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            result: QuizResult(
              quiz: widget.quiz,
              questions: _questions,
              selectedAnswers: _selectedAnswers,
              correctAnswers: correctAnswers,
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not save result: $error'),
        ),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _BookmarkButton extends StatelessWidget {
  final QuizQuestion question;
  final User? user;

  const _BookmarkButton({required this.question, required this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: FirestoreService.instance.isBookmarked(
        userId: currentUser.uid,
        questionId: question.id,
      ),
      builder: (context, snapshot) {
        final bookmarked = snapshot.data ?? false;

        return IconButton(
          tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark question',
          onPressed: () => FirestoreService.instance.toggleBookmark(
            userId: currentUser.uid,
            question: question,
          ),
          icon: Icon(
            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          ),
        );
      },
    );
  }
}

class _TimerPill extends StatelessWidget {
  final int seconds;

  const _TimerPill({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    final isLow = seconds <= 60;

    return Chip(
      avatar: Icon(
        Icons.timer_outlined,
        color: isLow ? Colors.white : Theme.of(context).colorScheme.primary,
      ),
      label: Text('$minutes:$remainingSeconds'),
      backgroundColor: isLow ? Colors.redAccent : null,
      labelStyle: TextStyle(color: isLow ? Colors.white : null),
    );
  }
}
