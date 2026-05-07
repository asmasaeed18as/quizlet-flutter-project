import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'quiz_list_screen.dart';

class SubjectsScreen extends StatelessWidget {
  final Course course;

  const SubjectsScreen({super.key, required this.course});

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
                Text(course.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(course.description),
                const SizedBox(height: 18),
                Expanded(
                  child: StreamBuilder<List<QuizSubject>>(
                    stream: FirestoreService.instance.subjectsForCourse(course.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return ErrorState(error: snapshot.error);
                      if (!snapshot.hasData) {
                        return const LoadingState(message: 'Loading subjects...');
                      }

                      final subjects = snapshot.data!;
                      if (subjects.isEmpty) {
                        return const EmptyState(
                          icon: Icons.category_outlined,
                          title: 'No subjects yet',
                          message: 'Add subjects for this course from Admin.',
                        );
                      }

                      return ListView.separated(
                        itemCount: subjects.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return _SubjectTile(
                            subject: subject,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizListScreen(
                                  course: course,
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

class _SubjectTile extends StatelessWidget {
  final QuizSubject subject;
  final VoidCallback onTap;

  const _SubjectTile({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
