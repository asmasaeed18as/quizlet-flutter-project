import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String role;
  final DateTime? sessionExpiresAt;
  final int totalScore;
  final int quizzesAttempted;
  final int streak;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.sessionExpiresAt,
    required this.totalScore,
    required this.quizzesAttempted,
    required this.streak,
  });

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    return AppUser(
      id: data['id']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? 'Learner',
      email: data['email']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      role: data['role']?.toString() ?? 'user',
      sessionExpiresAt: data['sessionExpiresAt'] is Timestamp
          ? (data['sessionExpiresAt'] as Timestamp).toDate()
          : null,
      totalScore: (data['totalScore'] as num?)?.toInt() ?? 0,
      quizzesAttempted: (data['quizzesAttempted'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'sessionExpiresAt': sessionExpiresAt,
      'totalScore': totalScore,
      'quizzesAttempted': quizzesAttempted,
      'streak': streak,
    };
  }
}
