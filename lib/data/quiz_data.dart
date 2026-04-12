import '../models/quiz_question.dart';

class QuizData {
  static const Map<String, List<QuizQuestion>> categoryQuestions = {
    'Grammar': [
      QuizQuestion(
        question: 'Which sentence is grammatically correct?',
        options: [
          'She do not like tea.',
          'She does not like tea.',
          'She does not likes tea.',
          'She not like tea.',
        ],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: 'Choose the correct past tense of "go".',
        options: ['Goed', 'Gone', 'Went', 'Going'],
        correctOptionIndex: 2,
      ),
      QuizQuestion(
        question: 'Which word is a conjunction?',
        options: ['Quickly', 'Beautiful', 'And', 'Table'],
        correctOptionIndex: 2,
      ),
    ],
    'Maths': [
      QuizQuestion(
        question: 'What is 12 × 3?',
        options: ['36', '24', '30', '42'],
        correctOptionIndex: 0,
      ),
      QuizQuestion(
        question: 'What is the square root of 81?',
        options: ['7', '9', '8', '6'],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: 'If x + 5 = 11, what is x?',
        options: ['5', '7', '6', '4'],
        correctOptionIndex: 2,
      ),
    ],
    'Physics': [
      QuizQuestion(
        question: 'What is the SI unit of force?',
        options: ['Joule', 'Pascal', 'Newton', 'Watt'],
        correctOptionIndex: 2,
      ),
      QuizQuestion(
        question: 'Speed is distance divided by _____.',
        options: ['Mass', 'Time', 'Force', 'Energy'],
        correctOptionIndex: 1,
      ),
      QuizQuestion(
        question: 'Which device is used to measure electric current?',
        options: ['Voltmeter', 'Ammeter', 'Thermometer', 'Barometer'],
        correctOptionIndex: 1,
      ),
    ],
  };

  static List<QuizQuestion> forCategory(String category) {
    return categoryQuestions[category] ?? const [];
  }
}
