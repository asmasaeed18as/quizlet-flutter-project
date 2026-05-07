import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'admin_screen.dart';
import 'bookmarks_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(user: user, onSignOut: () => _signOut(context)),
                const SizedBox(height: 16),
                const _DailyChallengeCard(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Courses',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap a course to open subjects and quizzes.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminScreen()),
                      ),
                      icon: const Icon(Icons.admin_panel_settings_rounded),
                      label: const Text('Admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<List<Course>>(
                    stream: FirestoreService.instance.coursesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(error: snapshot.error);
                      }

                      if (!snapshot.hasData) {
                        return const LoadingState(message: 'Loading courses...');
                      }

                      final courses = snapshot.data!;
                      if (courses.isEmpty) {
                        return const EmptyState(
                          icon: Icons.school_outlined,
                          title: 'No courses yet',
                          message:
                              'Use the admin screen to add your first course.',
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount =
                              constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 620 ? 2 : 1;

                          return GridView.builder(
                            itemCount: courses.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: crossAxisCount == 1 ? 1.65 : 1.25,
                            ),
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return _CourseCard(
                                course: course,
                                index: index,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SubjectsScreen(course: course),
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

  Future<void> _signOut(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign out failed. Please try again.')),
      );
    }
  }
}

class _HomeHeader extends StatelessWidget {
  final User? user;
  final VoidCallback onSignOut;

  const _HomeHeader({required this.user, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Learner';
    final initial = name.trim().isEmpty ? 'L' : name.trim()[0].toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage:
              user?.photoURL == null ? null : NetworkImage(user!.photoURL!),
          child: user?.photoURL == null ? Text(initial) : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name',
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Choose a course and keep your streak alive.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          icon: const Icon(Icons.person_rounded),
        ),
        PopupMenuButton<_HomeAction>(
          tooltip: 'More',
          onSelected: (action) {
            final screen = switch (action) {
              _HomeAction.leaderboard => const LeaderboardScreen(),
              _HomeAction.bookmarks => const BookmarksScreen(),
              _HomeAction.signOut => null,
            };

            if (action == _HomeAction.signOut) {
              onSignOut();
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen!),
            );
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _HomeAction.leaderboard,
              child: Text('Leaderboard'),
            ),
            PopupMenuItem(
              value: _HomeAction.bookmarks,
              child: Text('Bookmarks'),
            ),
            PopupMenuItem(
              value: _HomeAction.signOut,
              child: Text('Sign out'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Quiz>>(
      stream: FirestoreService.instance.allQuizzesStream(),
      builder: (context, snapshot) {
        final quizzes = snapshot.data ?? const <Quiz>[];
        final quiz = quizzes.isEmpty
            ? null
            : quizzes[DateTime.now().day % quizzes.length];

        return GlassCard(
          padding: const EdgeInsets.all(18),
          onTap: quiz == null
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          quiz: quiz,
                          courseId: '',
                        subjectId: quiz.subjectId,
                      ),
                    ),
                  ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB347), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      quiz == null
                          ? 'Add quizzes to unlock today\'s challenge.'
                          : quiz.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        );
      },
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final int index;
  final VoidCallback onTap;

  const _CourseCard({
    required this.course,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFF227C9D), Color(0xFF17C3B2)],
      const [Color(0xFFFFCB77), Color(0xFFFE6D73)],
      const [Color(0xFF3A86FF), Color(0xFF8338EC)],
      const [Color(0xFF2D6A4F), Color(0xFF95D5B2)],
    ];
    final colors = gradients[index % gradients.length];

    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 240),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_stories_rounded, color: Colors.white),
              const Spacer(),
              Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFEFF7FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _HomeAction { leaderboard, bookmarks, signOut }
