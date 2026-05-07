import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/quiz_attempt.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                Text('Quiz History', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: user == null
                      ? const EmptyState(
                          icon: Icons.history_toggle_off_rounded,
                          title: 'Not signed in',
                          message: 'Log in to view your quiz attempts.',
                        )
                      : StreamBuilder<List<QuizAttempt>>(
                          stream: FirestoreService.instance.attemptsForUser(user.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return ErrorState(error: snapshot.error);
                            }
                            if (!snapshot.hasData) {
                              return const LoadingState(message: 'Loading attempts...');
                            }

                            final attempts = snapshot.data!;
                            if (attempts.isEmpty) {
                              return const EmptyState(
                                icon: Icons.assignment_outlined,
                                title: 'No quiz history',
                                message: 'Your completed quizzes will appear here.',
                              );
                            }

                            return ListView.separated(
                              itemCount: attempts.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _HistoryTile(attempt: attempts[index]);
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

class _HistoryTile extends StatelessWidget {
  final QuizAttempt attempt;

  const _HistoryTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final percent = (attempt.scorePercent * 100).round();
    final completedAt = attempt.completedAt;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(child: Text('$percent%')),
        title: Text(attempt.quizTitle),
        subtitle: Text(
          completedAt == null
              ? '${attempt.score}/${attempt.totalQuestions} correct'
              : '${attempt.score}/${attempt.totalQuestions} correct | ${completedAt.toLocal().toString().split('.').first}',
        ),
      ),
    );
  }
}
