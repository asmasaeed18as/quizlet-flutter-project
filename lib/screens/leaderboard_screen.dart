import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/course.dart';
import '../models/quiz_attempt.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                  Text(
                    'Leaderboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Global'),
                      Tab(text: 'Course'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        _GlobalLeaderboard(),
                        _CourseLeaderboard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalLeaderboard extends StatelessWidget {
  const _GlobalLeaderboard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppUser>>(
      stream: FirestoreService.instance.leaderboard(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (!snapshot.hasData) {
          return const LoadingState(message: 'Loading rankings...');
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return const EmptyState(
            icon: Icons.leaderboard_outlined,
            title: 'No rankings yet',
            message: 'Scores will appear after quizzes are completed.',
          );
        }

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final user = users[index];
            return _RankTile(
              rank: index + 1,
              name: user.name,
              photoUrl: user.photoUrl,
              score: user.totalScore,
              detail: '${user.quizzesAttempted} attempts',
            );
          },
        );
      },
    );
  }
}

class _CourseLeaderboard extends StatefulWidget {
  const _CourseLeaderboard();

  @override
  State<_CourseLeaderboard> createState() => _CourseLeaderboardState();
}

class _CourseLeaderboardState extends State<_CourseLeaderboard> {
  String? _selectedCourseId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: FirestoreService.instance.coursesStream(),
      builder: (context, courseSnapshot) {
        if (courseSnapshot.hasError) return ErrorState(error: courseSnapshot.error);
        if (!courseSnapshot.hasData) {
          return const LoadingState(message: 'Loading courses...');
        }

        final courses = courseSnapshot.data!;
        if (courses.isEmpty) {
          return const EmptyState(
            icon: Icons.school_outlined,
            title: 'No courses yet',
            message: 'Add courses before course rankings can be shown.',
          );
        }

        final selectedCourseId = _selectedCourseId ?? courses.first.id;

        return Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCourseId,
              decoration: const InputDecoration(labelText: 'Course'),
              items: [
                for (final course in courses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<Set<String>>(
                stream: FirestoreService.instance.adminUserIdsStream(),
                builder: (context, adminSnapshot) {
                  if (adminSnapshot.hasError) {
                    return ErrorState(error: adminSnapshot.error);
                  }
                  if (!adminSnapshot.hasData) {
                    return const LoadingState(message: 'Loading course ranking...');
                  }

                  final adminUserIds = adminSnapshot.data!;

                  return StreamBuilder<List<QuizAttempt>>(
                    stream:
                        FirestoreService.instance.attemptsForCourse(selectedCourseId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(error: snapshot.error);
                      }
                      if (!snapshot.hasData) {
                        return const LoadingState(
                          message: 'Loading course ranking...',
                        );
                      }

                      final userAttempts = snapshot.data!
                          .where((attempt) => !adminUserIds.contains(attempt.userId))
                          .toList();
                      final entries = _rankCourseAttempts(userAttempts);
                      if (entries.isEmpty) {
                        return const EmptyState(
                          icon: Icons.leaderboard_outlined,
                          title: 'No course scores yet',
                          message: 'Complete a quiz in this course to rank here.',
                        );
                      }

                      return ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _RankTile(
                            rank: index + 1,
                            name: entry.name,
                            photoUrl: entry.photoUrl,
                            score: entry.score,
                            detail: '${entry.attempts} attempts',
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<_CourseRankEntry> _rankCourseAttempts(List<QuizAttempt> attempts) {
    final entries = <String, _CourseRankEntry>{};

    for (final attempt in attempts) {
      final existing = entries[attempt.userId];
      entries[attempt.userId] = _CourseRankEntry(
        name: attempt.userName,
        photoUrl: attempt.userPhotoUrl,
        score: (existing?.score ?? 0) + attempt.score,
        attempts: (existing?.attempts ?? 0) + 1,
      );
    }

    final ranked = entries.values.toList();
    ranked.sort((a, b) => b.score.compareTo(a.score));
    return ranked;
  }
}

class _RankTile extends StatelessWidget {
  final int rank;
  final String name;
  final String photoUrl;
  final int score;
  final String detail;

  const _RankTile({
    required this.rank,
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: photoUrl.isEmpty ? null : NetworkImage(photoUrl),
          child: photoUrl.isEmpty ? Text('$rank') : null,
        ),
        title: Text(name),
        subtitle: Text(detail),
        trailing: Text(
          '$score pts',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _CourseRankEntry {
  final String name;
  final String photoUrl;
  final int score;
  final int attempts;

  const _CourseRankEntry({
    required this.name,
    required this.photoUrl,
    required this.score,
    required this.attempts,
  });
}
