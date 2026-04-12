import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<QuizQuestion> _questions;
  late final List<int?> _selectedAnswers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _questions = QuizData.forCategory(widget.category);
    _selectedAnswers = List<int?>.filled(_questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(
          child: Text('No questions found for this category.'),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final isLastQuestion = _currentIndex == _questions.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
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
                        '${widget.category} Quiz',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFDDE5F5),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(color: Color(0xFF4A5568)),
                ),
                const SizedBox(height: 14),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
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
                              ? const Color(0xFFEDEBFF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primary
                                : const Color(0xFFDDE3EF),
                            width: selected ? 1.8 : 1.0,
                          ),
                        ),
                        child: RadioListTile<int>(
                          value: optionIndex,
                          groupValue: _selectedAnswers[_currentIndex],
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswers[_currentIndex] = value;
                            });
                          },
                          activeColor: AppTheme.primary,
                          title: Text(
                            currentQuestion.options[optionIndex],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _currentIndex == 0
                            ? null
                            : () {
                                setState(() {
                                  _currentIndex--;
                                });
                              },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isLastQuestion) {
                            setState(() {
                              _currentIndex++;
                            });
                            return;
                          }
                          _submitQuiz();
                        },
                        child: Text(isLastQuestion ? 'Submit Quiz' : 'Next'),
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

  void _submitQuiz() {
    final unanswered = _selectedAnswers.where((a) => a == null).length;
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

    int correctAnswers = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctOptionIndex) {
        correctAnswers++;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: QuizResult(
            category: widget.category,
            totalQuestions: _questions.length,
            correctAnswers: correctAnswers,
          ),
        ),
      ),
    );
  }
}
