import 'dart:convert';

import 'package:http/http.dart' as http;

class TriviaApiQuestion {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String difficulty;
  final String category;

  const TriviaApiQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
    required this.category,
  });
}

class TriviaApiService {
  TriviaApiService._();

  static final TriviaApiService instance = TriviaApiService._();

  Future<List<TriviaApiQuestion>> fetchQuestions({
    required int amount,
    String? categoryId,
    String? difficulty,
  }) async {
    final params = <String, String>{
      'amount': amount.toString(),
      'type': 'multiple',
      'encode': 'url3986',
    };

    final normalizedDifficulty = difficulty?.trim().toLowerCase();
    if (categoryId != null && categoryId.trim().isNotEmpty) {
      params['category'] = categoryId.trim();
    }
    if (normalizedDifficulty != null &&
        normalizedDifficulty.isNotEmpty &&
        normalizedDifficulty != 'any') {
      params['difficulty'] = normalizedDifficulty;
    }

    final uri = Uri.https('opentdb.com', '/api.php', params);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw StateError('Trivia API request failed with ${response.statusCode}.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final responseCode = (data['response_code'] as num?)?.toInt() ?? -1;
    if (responseCode != 0) {
      throw StateError(_friendlyApiError(responseCode));
    }

    final results = (data['results'] as List<dynamic>? ?? const []);
    return results.map((item) {
      final map = item as Map<String, dynamic>;
      final correct = _decode(map['correct_answer']?.toString() ?? '');
      final incorrect = (map['incorrect_answers'] as List<dynamic>? ?? const [])
          .map((answer) => _decode(answer.toString()))
          .toList();
      final options = [...incorrect, correct]..sort();

      return TriviaApiQuestion(
        questionText: _decode(map['question']?.toString() ?? ''),
        options: options,
        correctAnswer: correct,
        difficulty: _decode(map['difficulty']?.toString() ?? ''),
        category: _decode(map['category']?.toString() ?? ''),
      );
    }).toList();
  }

  String _decode(String value) {
    return Uri.decodeComponent(value.replaceAll('+', '%20')).trim();
  }

  String _friendlyApiError(int code) {
    switch (code) {
      case 1:
        return 'No questions were available for this selection.';
      case 2:
        return 'The trivia request used an invalid parameter.';
      case 3:
        return 'Trivia API session token was not found.';
      case 4:
        return 'Trivia API has no new questions left for this selection.';
      case 5:
        return 'Trivia API rate limit reached. Please wait a moment.';
      default:
        return 'Trivia API returned an unexpected response.';
    }
  }
}
