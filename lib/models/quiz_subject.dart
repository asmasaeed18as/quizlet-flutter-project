import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSubject {
  final String id;
  final String courseId;
  final String title;

  const QuizSubject({
    required this.id,
    required this.courseId,
    required this.title,
  });

  factory QuizSubject.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return QuizSubject(
      id: data['id']?.toString() ?? doc.id,
      courseId: data['courseId']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled subject',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
    };
  }
}
