import 'package:cloud_firestore/cloud_firestore.dart';

class Bookmark {
  final String id;
  final String userId;
  final String questionId;
  final String quizId;
  final String questionText;
  final DateTime? createdAt;

  const Bookmark({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.quizId,
    required this.questionText,
    required this.createdAt,
  });

  factory Bookmark.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];

    return Bookmark(
      id: data['id']?.toString() ?? doc.id,
      userId: data['userId']?.toString() ?? '',
      questionId: data['questionId']?.toString() ?? '',
      quizId: data['quizId']?.toString() ?? '',
      questionText: data['questionText']?.toString() ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }
}
