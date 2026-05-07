import 'package:cloud_firestore/cloud_firestore.dart';

class QuizProgress {
  final String userId;
  final String quizId;
  final int currentQuestionIndex;
  final List<int?> selectedAnswers;

  const QuizProgress({
    required this.userId,
    required this.quizId,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
  });

  factory QuizProgress.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return QuizProgress(
      userId: data['userId']?.toString() ?? '',
      quizId: data['quizId']?.toString() ?? '',
      currentQuestionIndex:
          (data['currentQuestionIndex'] as num?)?.toInt() ?? 0,
      selectedAnswers: (data['selectedAnswers'] as List<dynamic>? ?? const [])
          .map((answer) => answer == null ? null : (answer as num).toInt())
          .toList(),
    );
  }
}
