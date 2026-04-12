import 'package:flutter/material.dart';
import '../data/quiz_data.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatelessWidget {
  final String category;

  const QuizListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final questions = QuizData.forCategory(category);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: questions.isEmpty
                ? const Center(
                    child: Text('No quiz available for this category.'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(height: 10),
                      Hero(
                        tag: category,
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            '$category Quiz',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have ${questions.length} MCQs in this category.',
                        style: const TextStyle(color: Color(0xFF4A5568)),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoRow(
                                  icon: Icons.timer_outlined,
                                  label: 'Estimated time',
                                  value: '${questions.length * 2} min',
                                ),
                                const SizedBox(height: 12),
                                _InfoRow(
                                  icon: Icons.help_outline_rounded,
                                  label: 'Questions',
                                  value: '${questions.length}',
                                ),
                                const SizedBox(height: 12),
                                const _InfoRow(
                                  icon: Icons.assignment_turned_in_outlined,
                                  label: 'Format',
                                  value: 'Multiple Choice',
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              QuizScreen(category: category),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text('Start Quiz'),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 10),
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
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
