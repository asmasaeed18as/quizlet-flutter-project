import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/quiz_attempt.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: AppBackground(
          child: EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Not signed in',
            message: 'Please log in to view your profile.',
          ),
        ),
      );
    }

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<AppUser?>(
              stream: FirestoreService.instance.userStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) return ErrorState(error: snapshot.error);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingState(message: 'Loading profile...');
                }

                final appUser = snapshot.data;
                if (appUser == null) {
                  return const EmptyState(
                    icon: Icons.person_add_alt_rounded,
                    title: 'Profile is being prepared',
                    message: 'Try logging in again if this keeps showing.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(height: 10),
                    _ProfileHeader(user: appUser),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Score',
                            value: '${appUser.totalScore}',
                            icon: Icons.stars_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Attempts',
                            value: '${appUser.quizzesAttempted}',
                            icon: Icons.assignment_turned_in_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Streak',
                            value: '${appUser.streak}',
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent history',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          ),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: StreamBuilder<List<QuizAttempt>>(
                        stream: FirestoreService.instance.attemptsForUser(user.uid),
                        builder: (context, attemptsSnapshot) {
                          if (attemptsSnapshot.hasError) {
                            return ErrorState(error: attemptsSnapshot.error);
                          }
                          if (!attemptsSnapshot.hasData) {
                            return const LoadingState(message: 'Loading history...');
                          }

                          final attempts = attemptsSnapshot.data!.take(5).toList();
                          if (attempts.isEmpty) {
                            return const EmptyState(
                              icon: Icons.history_rounded,
                              title: 'No attempts yet',
                              message: 'Complete a quiz to build your history.',
                            );
                          }

                          return ListView.separated(
                            itemCount: attempts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _AttemptTile(attempt: attempts[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage:
                  user.photoUrl.isEmpty ? null : NetworkImage(user.photoUrl),
              child: user.photoUrl.isEmpty
                  ? Text(
                      user.name.isEmpty ? 'L' : user.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(user.email, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  final QuizAttempt attempt;

  const _AttemptTile({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final percent = (attempt.scorePercent * 100).round();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(child: Text('$percent%')),
        title: Text(attempt.quizTitle),
        subtitle: Text('${attempt.score}/${attempt.totalQuestions} correct'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
