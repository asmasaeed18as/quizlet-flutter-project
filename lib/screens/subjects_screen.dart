import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'quiz_list_screen.dart';

class SubjectsScreen extends StatefulWidget {
  final Course course;

  const SubjectsScreen({super.key, required this.course});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _CourseHeader(course: widget.course),
                const SizedBox(height: 14),
                _SearchField(
                  controller: _searchController,
                  hintText: 'Search subjects',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<QuizSubject>>(
                    stream: FirestoreService.instance.subjectsForCourse(
                      widget.course.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return ErrorState(error: snapshot.error);
                      if (!snapshot.hasData) {
                        return const LoadingState(message: 'Loading subjects...');
                      }

                      final subjects = snapshot.data!;
                      final query = _searchQuery.trim().toLowerCase();
                      final filteredSubjects = subjects.where((subject) {
                        if (query.isEmpty) return true;
                        return subject.title.toLowerCase().contains(query);
                      }).toList();
                      if (subjects.isEmpty) {
                        return const EmptyState(
                          icon: Icons.category_outlined,
                          title: 'No subjects yet',
                          message: 'Add subjects for this course from Admin.',
                        );
                      }
                      if (filteredSubjects.isEmpty) {
                        return const EmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No subjects found',
                          message: 'Try a different subject name.',
                        );
                      }

                      return ListView.separated(
                        itemCount: filteredSubjects.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          return _SubjectTile(
                            subject: subject,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizListScreen(
                                  course: widget.course,
                                  subject: subject,
                                ),
                              ),
                            ),
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

class _CourseHeader extends StatelessWidget {
  final Course course;

  const _CourseHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
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
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
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
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: const TextStyle(color: Colors.white, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/image1.png',
              width: 82,
              height: 82,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final QuizSubject subject;
  final VoidCallback onTap;

  const _SubjectTile({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.topic_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(
            subject.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: const Text('Tap to view quizzes'),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          onTap: onTap,
        ),
      ),
    );
  }
}
