import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatelessWidget {
  final Course course;
  final QuizSubject subject;

  const QuizListScreen({
    super.key,
    required this.course,
    required this.subject,
  });

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
                Text(subject.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('${course.title} quizzes'),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<Quiz>>(
                    stream: FirestoreService.instance.quizzesForSubject(subject.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return ErrorState(error: snapshot.error);
                      if (!snapshot.hasData) {
                        return const LoadingState(message: 'Loading quizzes...');
                      }

                      final quizzes = snapshot.data!;
                      if (quizzes.isEmpty) {
                        return const EmptyState(
                          icon: Icons.quiz_outlined,
                          title: 'No quizzes yet',
                          message: 'Add quizzes for this subject from Admin.',
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
                                    builder: (_) => QuizScreen(
                                      quiz: quiz,
                                      courseId: course.id,
                                      subjectId: subject.id,
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
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                ],
              ),
            ],
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
