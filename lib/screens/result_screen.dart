import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 1200),
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ScaleTransition(
                scale: _cardAnimation,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Card(
                      margin: const EdgeInsets.only(top: 38),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${widget.result.category} Quiz Completed',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 18),
                            _AnimatedScoreRing(percent: percent),
                            const SizedBox(height: 20),
                            _ResultTile(
                              label: 'Correct Answers',
                              value:
                                  '${widget.result.correctAnswers}/${widget.result.totalQuestions}',
                              color: AppTheme.success,
                            ),
                            const SizedBox(height: 10),
                            _ResultTile(
                              label: 'Wrong Answers',
                              value: '${widget.result.wrongAnswers}',
                              color: AppTheme.danger,
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const HomeScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text('Back Home'),
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
                            math.sin(_iconFloatAnimation.value * math.pi * 2) *
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
                            colors: [Color(0xFFFFD84D), Color(0xFFFFA64D)],
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
                backgroundColor: const Color(0xFFE5EAF6),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
              Center(
                child: Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
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
  final Color color;

  const _ResultTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
