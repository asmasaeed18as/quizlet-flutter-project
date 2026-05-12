import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'quiz_setup_screen.dart';

class QuizListScreen extends StatefulWidget {
  final Course course;
  final QuizSubject subject;

  const QuizListScreen({
    super.key,
    required this.course,
    required this.subject,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(height: 10),
                _QuizListHeader(course: widget.course, subject: widget.subject),
                const SizedBox(height: 14),
                _SearchField(
                  controller: _searchController,
                  hintText: 'Search quizzes',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<Quiz>>(
                    stream: FirestoreService.instance.quizzesForSubject(
                      widget.subject.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return ErrorState(error: snapshot.error);
                      if (!snapshot.hasData) {
                        return const LoadingState(message: 'Loading quizzes...');
                      }

                      final query = _searchQuery.trim().toLowerCase();
                      final quizzes = snapshot.data!
                          .where((quiz) => quiz.isPublished)
                          .where(
                            (quiz) => query.isEmpty
                                ? true
                                : quiz.title.toLowerCase().contains(query),
                          )
                          .toList();
                      if (quizzes.isEmpty) {
                        return EmptyState(
                          icon: query.isEmpty
                              ? Icons.quiz_outlined
                              : Icons.search_off_rounded,
                          title: query.isEmpty
                              ? 'No published quizzes yet'
                              : 'No quizzes found',
                          message: query.isEmpty
                              ? 'The admin has not published any quizzes for this subject yet.'
                              : 'Try a different quiz name or keyword.',
                        );
                      }

                      return StreamBuilder<List<QuizProgress>>(
                        stream: user == null
                            ? const Stream.empty()
                            : FirestoreService.instance.progressForUser(user.uid),
                        builder: (context, progressSnapshot) {
                          final progressByQuiz = {
                            for (final progress
                                in progressSnapshot.data ?? const <QuizProgress>[])
                              progress.quizId: progress,
                          };

                          return ListView.separated(
                            itemCount: quizzes.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final quiz = quizzes[index];
                              return _QuizTile(
                                quiz: quiz,
                                hasProgress: progressByQuiz.containsKey(quiz.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizSetupScreen(
                                      quiz: quiz,
                                      courseId: widget.course.id,
                                      subjectId: widget.subject.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _QuizListHeader extends StatelessWidget {
  final Course course;
  final QuizSubject subject;

  const _QuizListHeader({
    required this.course,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${course.title} quizzes',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/quiz_paper.png',
            width: 76,
            height: 76,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _QuizTile extends StatelessWidget {
  final Quiz quiz;
  final bool hasProgress;
  final VoidCallback onTap;

  const _QuizTile({
    required this.quiz,
    required this.hasProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startsAt = quiz.startsAt;
    final startLabel = startsAt == null
        ? 'Starts anytime'
        : quiz.hasStarted
            ? 'Started'
            : 'Starts ${startsAt.day.toString().padLeft(2, '0')}/${startsAt.month.toString().padLeft(2, '0')} ${startsAt.hour.toString().padLeft(2, '0')}:${startsAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
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
                        Icons.play_lesson_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (hasProgress)
                      Chip(
                        label: const Text('Resume'),
                        avatar: const Icon(Icons.play_circle_outline_rounded),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (quiz.isAdminGenerated) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Generated by Admin',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    _QuizMeta(
                      icon: Icons.help_outline_rounded,
                      text: '${quiz.totalQuestions} questions',
                    ),
                    const SizedBox(width: 14),
                    _QuizMeta(
                      icon: Icons.timer_outlined,
                      text: '${quiz.duration} min',
                    ),
                    const SizedBox(width: 14),
                    _QuizMeta(
                      icon: quiz.requiresPassword
                          ? Icons.lock_outline_rounded
                          : Icons.lock_open_rounded,
                      text: quiz.requiresPassword ? 'Password' : 'Open',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuizMeta(
                      icon: quiz.hasStarted
                          ? Icons.play_circle_outline_rounded
                          : Icons.schedule_rounded,
                      text: startLabel,
                    ),
                    const Spacer(),
                    const Icon(Icons.tune_rounded),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _QuizMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}
