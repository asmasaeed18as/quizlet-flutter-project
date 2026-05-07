import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String quizId;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QuizQuestion.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final options = (data['options'] as List<dynamic>? ?? const [])
        .map((option) => option.toString())
        .toList();

    return QuizQuestion(
      id: data['id']?.toString() ?? doc.id,
      quizId: data['quizId']?.toString() ?? '',
      questionText: data['questionText']?.toString() ?? '',
      options: options,
      correctAnswer: data['correctAnswer']?.toString() ?? '',
      explanation: data['explanation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }

  int get correctOptionIndex {
    final directIndex = options.indexOf(correctAnswer);
    if (directIndex != -1) return directIndex;

    final parsedIndex = int.tryParse(correctAnswer);
    if (parsedIndex != null && parsedIndex >= 0 && parsedIndex < options.length) {
      return parsedIndex;
    }

    return -1;
  }
}
