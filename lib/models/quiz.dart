import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String subjectId;
  final String title;
  final int totalQuestions;
  final int duration;

  const Quiz({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.totalQuestions,
    required this.duration,
  });

  factory Quiz.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Quiz(
      id: data['id']?.toString() ?? doc.id,
      subjectId: data['subjectId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled quiz',
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      duration: (data['duration'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'totalQuestions': totalQuestions,
      'duration': duration,
    };
  }
}
