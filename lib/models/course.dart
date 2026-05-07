import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String description;

  const Course({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Course.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return Course(
      id: data['id']?.toString() ?? doc.id,
      title: data['title']?.toString() ?? 'Untitled course',
      description: data['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
