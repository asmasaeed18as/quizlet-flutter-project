class QuizResult {
  final String category;
  final int totalQuestions;
  final int correctAnswers;

  const QuizResult({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  int get wrongAnswers => totalQuestions - correctAnswers;
  double get scorePercent =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;
}
