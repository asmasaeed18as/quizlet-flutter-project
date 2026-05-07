import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../widgets/app_background.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _cardAnimation;
  late final Animation<double> _iconFloatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _cardAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _iconFloatAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.result.scorePercent * 100).round();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ScaleTransition(
                        scale: _cardAnimation,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Card(
                              margin: const EdgeInsets.only(top: 38),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 72, 20, 20),
                                child: Column(
                                  children: [
                                    Text(
                                      '${widget.result.quiz.title} Completed',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    const SizedBox(height: 18),
                                    _AnimatedScoreRing(percent: percent),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ResultTile(
                                            label: 'Correct',
                                            value:
                                                '${widget.result.correctAnswers}',
                                            icon: Icons.check_circle_rounded,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _ResultTile(
                                            label: 'Incorrect',
                                            value:
                                                '${widget.result.wrongAnswers}',
                                            icon: Icons.cancel_rounded,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _iconFloatAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    0,
                                    math.sin(
                                          _iconFloatAnimation.value *
                                              math.pi *
                                              2,
                                        ) *
                                        4,
                                  ),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 74,
                                height: 74,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFFFD84D),
                                      Color(0xFFFFA64D),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Review answers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(widget.result.questions.length, (index) {
                        final question = widget.result.questions[index];
                        final selectedIndex = widget.result.selectedAnswers[index];
                        final selectedAnswer = selectedIndex == null ||
                                selectedIndex < 0 ||
                                selectedIndex >= question.options.length
                            ? 'Not answered'
                            : question.options[selectedIndex];
                        final isCorrect =
                            selectedIndex == question.correctOptionIndex;

                        return _ExplanationCard(
                          number: index + 1,
                          question: question.questionText,
                          selectedAnswer: selectedAnswer,
                          correctAnswer: question.correctAnswer,
                          explanation: question.explanation,
                          isCorrect: isCorrect,
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedScoreRing extends StatelessWidget {
  final int percent;

  const _AnimatedScoreRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 134,
          height: 134,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 11,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              Center(
                child: Text(
                  '${(value * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final int number;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final String explanation;
  final bool isCorrect;

  const _ExplanationCard({
    required this.number,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Colors.redAccent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.14),
                  child: Text('$number'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Your answer: $selectedAnswer'),
            Text('Correct answer: $correctAnswer'),
            if (explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                explanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
