import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/bookmark.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

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
                Text(
                  'Bookmarks',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: user == null
                      ? const EmptyState(
                          icon: Icons.bookmark_remove_outlined,
                          title: 'Not signed in',
                          message: 'Log in to save and review questions.',
                        )
                      : StreamBuilder<List<Bookmark>>(
                          stream:
                              FirestoreService.instance.bookmarksForUser(user.uid),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return ErrorState(error: snapshot.error);
                            }
                            if (!snapshot.hasData) {
                              return const LoadingState(message: 'Loading bookmarks...');
                            }

                            final bookmarks = snapshot.data!;
                            if (bookmarks.isEmpty) {
                              return const EmptyState(
                                icon: Icons.bookmark_border_rounded,
                                title: 'No bookmarks yet',
                                message:
                                    'Bookmark questions during a quiz to review them later.',
                              );
                            }

                            return ListView.separated(
                              itemCount: bookmarks.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return _BookmarkTile(bookmark: bookmarks[index]);
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

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;

  const _BookmarkTile({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.bookmark_rounded),
        title: Text(bookmark.questionText),
        subtitle: Text('Quiz ID: ${bookmark.quizId}'),
      ),
    );
  }
}
