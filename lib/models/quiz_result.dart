import 'quiz.dart';
import 'quiz_question.dart';

class QuizResult {
  final Quiz quiz;
  final List<QuizQuestion> questions;
  final List<int?> selectedAnswers;
  final int correctAnswers;

  const QuizResult({
    required this.quiz,
    required this.questions,
    required this.selectedAnswers,
    required this.correctAnswers,
  });

  int get totalQuestions => questions.length;
  int get wrongAnswers => totalQuestions - correctAnswers;
  double get scorePercent =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}
