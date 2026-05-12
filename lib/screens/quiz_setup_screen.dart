import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  final Quiz quiz;
  final String courseId;
  final String subjectId;

  const QuizSetupScreen({
    super.key,
    required this.quiz,
    required this.courseId,
    required this.subjectId,
  });

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int? _questionCount;
  late int _durationMinutes;
  late final TextEditingController _durationController;
  late final TextEditingController _passwordController;
  String _difficulty = 'any';
  bool _passwordVerified = false;

  @override
  void initState() {
    super.initState();
    _durationMinutes = widget.quiz.duration <= 0 ? 10 : widget.quiz.duration;
    _durationController = TextEditingController(text: '$_durationMinutes');
    _passwordController = TextEditingController();
    _passwordVerified = !widget.quiz.requiresPassword;
  }

  @override
  void dispose() {
    _durationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<List<QuizQuestion>>(
            stream: FirestoreService.instance.questionsForQuiz(widget.quiz.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) return ErrorState(error: snapshot.error);
              if (!snapshot.hasData) {
                return const LoadingState(message: 'Opening quiz setup...');
              }

              final allQuestions = snapshot.data!;
              final filteredQuestions = _difficulty == 'any'
                  ? allQuestions
                  : allQuestions
                      .where((question) => question.difficulty == _difficulty)
                      .toList();
              final easyCount =
                  allQuestions.where((question) => question.difficulty == 'easy').length;
              final mediumCount =
                  allQuestions.where((question) => question.difficulty == 'medium').length;
              final hardCount =
                  allQuestions.where((question) => question.difficulty == 'hard').length;
              final importedCount =
                  allQuestions.where((question) => question.isInternetImported).length;
              final sampleCount =
                  allQuestions.where((question) => question.isSeededSample).length;
              final manualCount = allQuestions.length - importedCount - sampleCount;
              final practiceVariantCount = allQuestions
                  .where((question) => question.isPracticeVariant)
                  .length;
              final totalAvailable = filteredQuestions.length;
              if (totalAvailable == 0) {
                return EmptyState(
                  icon: Icons.help_outline_rounded,
                  title: 'No matching questions',
                  message: _difficulty == 'any'
                      ? 'Add MCQs for this quiz from Admin first.'
                      : 'No $_difficulty questions are available for this quiz yet.',
                );
              }

              final selectedCount =
                  (_questionCount ?? totalAvailable).clamp(1, totalAvailable);
              final startsAt = widget.quiz.startsAt;
              final canStart = widget.quiz.hasStarted;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupHero(
                    title: widget.quiz.title,
                    totalAvailable: totalAvailable,
                  ),
                  const SizedBox(height: 18),
                  _SetupSection(
                    icon: Icons.dataset_rounded,
                    title: 'Question bank summary',
                    value: '${allQuestions.length} total',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This quiz uses the subject question bank. Your selected count and difficulty will be taken from the questions available here.',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _SummaryChip(label: 'Easy $easyCount'),
                            _SummaryChip(label: 'Medium $mediumCount'),
                            _SummaryChip(label: 'Hard $hardCount'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (manualCount > 0) _SummaryChip(label: 'Manual $manualCount'),
                            if (sampleCount > 0) _SummaryChip(label: 'Sample $sampleCount'),
                            if (importedCount > 0)
                              _SummaryChip(label: 'Internet $importedCount'),
                          ],
                        ),
                        if (practiceVariantCount > 0) ...[
                          const SizedBox(height: 10),
                          Text(
                            '$practiceVariantCount questions are labeled as practice variants so repeated seeded items are transparent to learners.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (startsAt != null)
                    _SetupSection(
                      icon: canStart
                          ? Icons.check_circle_outline_rounded
                          : Icons.schedule_rounded,
                      title: 'Exam availability',
                      value: canStart ? 'Open now' : 'Locked',
                      child: Text(
                        canStart
                            ? 'This exam is available to start now.'
                            : 'This exam will open on ${startsAt.day.toString().padLeft(2, '0')}/${startsAt.month.toString().padLeft(2, '0')}/${startsAt.year} at ${startsAt.hour.toString().padLeft(2, '0')}:${startsAt.minute.toString().padLeft(2, '0')}.',
                      ),
                    ),
                  if (startsAt != null) const SizedBox(height: 14),
                  if (widget.quiz.requiresPassword)
                    _SetupSection(
                      icon: _passwordVerified
                          ? Icons.lock_open_rounded
                          : Icons.lock_outline_rounded,
                      title: 'Exam password',
                      value: _passwordVerified ? 'Verified' : 'Required',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Enter exam password',
                            ),
                            onChanged: (_) {
                              if (_passwordVerified) {
                                setState(() => _passwordVerified = false);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: _verifyPassword,
                              icon: const Icon(Icons.verified_user_rounded),
                              label: const Text('Verify Password'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.quiz.requiresPassword) const SizedBox(height: 14),
                  _SetupSection(
                    icon: Icons.format_list_numbered_rounded,
                    title: 'How many MCQs?',
                    value: '$selectedCount',
                    child: Column(
                      children: [
                        Slider(
                          value: selectedCount.toDouble(),
                          min: 1,
                          max: totalAvailable.toDouble(),
                          divisions: totalAvailable > 1 ? totalAvailable - 1 : null,
                          label: '$selectedCount',
                          onChanged: (value) {
                            setState(() => _questionCount = value.round());
                          },
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final count in _quickCounts(totalAvailable))
                              ChoiceChip(
                                label: Text('$count'),
                                selected: selectedCount == count,
                                onSelected: (_) {
                                  setState(() => _questionCount = count);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SetupSection(
                    icon: Icons.signal_cellular_alt_rounded,
                    title: 'Which difficulty?',
                    value: _difficulty[0].toUpperCase() + _difficulty.substring(1),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final difficulty in const [
                          'any',
                          'easy',
                          'medium',
                          'hard',
                        ])
                          ChoiceChip(
                            label: Text(
                              difficulty == 'any'
                                  ? 'Any'
                                  : difficulty[0].toUpperCase() +
                                      difficulty.substring(1),
                            ),
                            selected: _difficulty == difficulty,
                            onSelected: (_) {
                              setState(() {
                                _difficulty = difficulty;
                                _questionCount = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SetupSection(
                    icon: Icons.timer_rounded,
                    title: 'How much time?',
                    value: '$_durationMinutes min',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Custom minutes',
                            hintText: 'Enter any positive number',
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed != null && parsed > 0) {
                              setState(() => _durationMinutes = parsed);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Slider(
                          value: _durationMinutes.toDouble(),
                          min: 1,
                          max: 180,
                          divisions: 179,
                          label: '$_durationMinutes min',
                          onChanged: (value) {
                            setState(() {
                              _durationMinutes = value.round();
                              _durationController.text = '$_durationMinutes';
                            });
                          },
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final minutes in const [5, 10, 15, 20, 30])
                              ChoiceChip(
                                label: Text('$minutes min'),
                                selected: _durationMinutes == minutes,
                                onSelected: (_) {
                                  setState(() {
                                    _durationMinutes = minutes;
                                    _durationController.text = '$_durationMinutes';
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: (!canStart || !_passwordVerified)
                        ? null
                        : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            quiz: widget.quiz,
                            courseId: widget.courseId,
                            subjectId: widget.subjectId,
                            questionLimit: selectedCount,
                            durationMinutes: _durationMinutes,
                            difficulty: _difficulty,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Quiz'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<int> _quickCounts(int totalAvailable) {
    final counts = <int>{};
    for (final count in [5, 10, 15, 20, totalAvailable]) {
      if (count >= 1 && count <= totalAvailable) counts.add(count);
    }
    if (counts.isEmpty) counts.add(totalAvailable);
    return counts.toList()..sort();
  }

  void _verifyPassword() {
    final isValid =
        _passwordController.text.trim() == widget.quiz.password.trim();
    setState(() => _passwordVerified = isValid);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          isValid ? 'Password verified.' : 'Incorrect quiz password.',
        ),
      ),
    );
  }
}

class _SetupHero extends StatelessWidget {
  final String title;
  final int totalAvailable;

  const _SetupHero({
    required this.title,
    required this.totalAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7A59), Color(0xFFFFC857)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 22,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalAvailable MCQs available',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/quiz_paper.png',
              width: 88,
              height: 88,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;

  const _SummaryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SetupSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget child;

  const _SetupSection({
    required this.icon,
    required this.title,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
