import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/course.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'bookmarks_screen.dart';
import 'leaderboard_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? 'Learner';
    final initial = name.trim().isEmpty ? 'L' : name.trim()[0].toUpperCase();
    final photoUrl = user?.photoURL;
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              foregroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
              child: hasPhoto ? null : Text(initial),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Hi, $name',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        actions: [
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
              if (action == _HomeAction.signOut) {
                _signOut(context);
                return;
              }

              final screen = switch (action) {
                _HomeAction.leaderboard => const LeaderboardScreen(),
                _HomeAction.bookmarks => const BookmarksScreen(),
                _HomeAction.signOut => const SizedBox.shrink(),
              };

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => screen),
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
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
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
              final filteredCourses = courses.where((course) {
                final query = _searchQuery.trim().toLowerCase();
                if (query.isEmpty) return true;
                return course.title.toLowerCase().contains(query) ||
                    course.description.toLowerCase().contains(query);
              }).toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  Text(
                    'Choose a course and keep your streak alive.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  const _HomeHero(),
                  const SizedBox(height: 20),
                  Text(
                    'Courses',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a course to open subjects and quizzes.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  _SearchField(
                    controller: _searchController,
                    hintText: 'Search courses',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  if (courses.isEmpty)
                    const SizedBox(
                      height: 260,
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: 'No courses yet',
                        message:
                            'Tap the Admin button to add or seed Firestore data.',
                      ),
                    )
                  else if (filteredCourses.isEmpty)
                    const SizedBox(
                      height: 220,
                      child: EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No courses found',
                        message: 'Try a different course name or keyword.',
                      ),
                    )
                  else
                    _CoursesGrid(courses: filteredCourses),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await FirestoreService.instance.clearSession(userId);
        } catch (_) {}
      }
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Firebase sign-out is the important step; Google sign-out is best-effort.
      }

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Practice smarter today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pick a course, set your own MCQ count and timer, then beat your last score.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoursesGrid extends StatelessWidget {
  final List<Course> courses;

  const _CoursesGrid({required this.courses});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 620
                ? 2
                : 1;

        return GridView.builder(
          itemCount: courses.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: crossAxisCount == 1 ? 1.5 : 1.2,
          ),
          itemBuilder: (context, index) {
            final course = courses[index];
            return _CourseCard(
              course: course,
              index: index,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectsScreen(course: course),
                ),
              ),
            );
          },
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 80).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  top: -20,
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 118,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFEFF7FF),
                        height: 1.4,
                      ),
                    ),
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

enum _HomeAction { leaderboard, bookmarks, signOut }

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
