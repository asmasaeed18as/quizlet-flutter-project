import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String id;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic> answers;
  final DateTime? completedAt;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.completedAt,
  });

  factory QuizAttempt.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final completedAt = data['completedAt'];

    return QuizAttempt(
      id: data['id']?.toString() ?? doc.id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Learner',
      userPhotoUrl: data['userPhotoUrl']?.toString() ?? '',
      quizId: data['quizId']?.toString() ?? '',
      quizTitle: data['quizTitle']?.toString() ?? 'Quiz',
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      answers: Map<String, dynamic>.from(data['answers'] as Map? ?? const {}),
      completedAt: completedAt is Timestamp ? completedAt.toDate() : null,
    );
  }

  double get scorePercent =>
      totalQuestions == 0 ? 0 : score / totalQuestions;
}
