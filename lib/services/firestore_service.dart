import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/bookmark.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_question.dart';
import '../models/quiz_subject.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _courses =>
      _db.collection('courses');
  CollectionReference<Map<String, dynamic>> get _subjects =>
      _db.collection('subjects');
  CollectionReference<Map<String, dynamic>> get _quizzes =>
      _db.collection('quizzes');
  CollectionReference<Map<String, dynamic>> get _questions =>
      _db.collection('questions');
  CollectionReference<Map<String, dynamic>> get _attempts =>
      _db.collection('attempts');
  CollectionReference<Map<String, dynamic>> get _progress =>
      _db.collection('progress');
  CollectionReference<Map<String, dynamic>> get _bookmarks =>
      _db.collection('bookmarks');

  Stream<AppUser?> userStream(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Future<void> ensureUserProfile(User user, {String? name}) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    final displayName = _userName(user, name: name);

    if (!snapshot.exists) {
      await doc.set({
        'id': user.uid,
        'name': displayName,
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'totalScore': 0,
        'quizzesAttempted': 0,
        'streak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await doc.set({
      'id': user.uid,
      'name': displayName,
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Course>> coursesStream() {
    return _courses.snapshots().map((snapshot) {
      final courses = snapshot.docs.map(Course.fromDoc).toList();
      courses.sort((a, b) => a.title.compareTo(b.title));
      return courses;
    });
  }

  Stream<List<QuizSubject>> subjectsForCourse(String courseId) {
    return _subjects
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      final subjects = snapshot.docs.map(QuizSubject.fromDoc).toList();
      subjects.sort((a, b) => a.title.compareTo(b.title));
      return subjects;
    });
  }

  Stream<List<QuizSubject>> allSubjectsStream() {
    return _subjects.snapshots().map((snapshot) {
      final subjects = snapshot.docs.map(QuizSubject.fromDoc).toList();
      subjects.sort((a, b) => a.title.compareTo(b.title));
      return subjects;
    });
  }

  Stream<List<Quiz>> quizzesForSubject(String subjectId) {
    return _quizzes
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .map((snapshot) {
      final quizzes = snapshot.docs.map(Quiz.fromDoc).toList();
      quizzes.sort((a, b) => a.title.compareTo(b.title));
      return quizzes;
    });
  }

  Stream<List<Quiz>> allQuizzesStream() {
    return _quizzes.snapshots().map((snapshot) {
      final quizzes = snapshot.docs.map(Quiz.fromDoc).toList();
      quizzes.sort((a, b) => a.title.compareTo(b.title));
      return quizzes;
    });
  }

  Stream<List<QuizQuestion>> questionsForQuiz(String quizId) {
    return _questions
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) {
      final questions = snapshot.docs.map(QuizQuestion.fromDoc).toList();
      questions.sort((a, b) => a.id.compareTo(b.id));
      return questions;
    });
  }

  Future<Course?> getCourse(String courseId) async {
    final doc = await _courses.doc(courseId).get();
    return doc.exists ? Course.fromDoc(doc) : null;
  }

  Future<QuizSubject?> getSubject(String subjectId) async {
    final doc = await _subjects.doc(subjectId).get();
    return doc.exists ? QuizSubject.fromDoc(doc) : null;
  }

  Future<Quiz?> getQuiz(String quizId) async {
    final doc = await _quizzes.doc(quizId).get();
    return doc.exists ? Quiz.fromDoc(doc) : null;
  }

  Future<QuizProgress?> getProgress({
    required String userId,
    required String quizId,
  }) async {
    final doc = await _progress.doc(_progressId(userId, quizId)).get();
    return doc.exists ? QuizProgress.fromDoc(doc) : null;
  }

  Future<void> saveProgress({
    required String userId,
    required String quizId,
    required int currentQuestionIndex,
    required List<int?> selectedAnswers,
  }) {
    return _progress.doc(_progressId(userId, quizId)).set({
      'userId': userId,
      'quizId': quizId,
      'currentQuestionIndex': currentQuestionIndex,
      'selectedAnswers': selectedAnswers,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearProgress({
    required String userId,
    required String quizId,
  }) {
    return _progress.doc(_progressId(userId, quizId)).delete();
  }

  Stream<List<QuizProgress>> progressForUser(String userId) {
    return _progress
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map(QuizProgress.fromDoc).toList();
    });
  }

  Future<String> saveAttempt({
    required User user,
    required Quiz quiz,
    required String courseId,
    required String subjectId,
    required List<QuizQuestion> questions,
    required List<int?> selectedAnswers,
  }) async {
    var score = 0;
    final answers = <String, dynamic>{};

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      final selectedIndex = selectedAnswers[i];
      final selectedAnswer = selectedIndex == null ||
              selectedIndex < 0 ||
              selectedIndex >= question.options.length
          ? ''
          : question.options[selectedIndex];
      final isCorrect = selectedIndex == question.correctOptionIndex;
      if (isCorrect) score++;

      answers[question.id] = {
        'selectedIndex': selectedIndex,
        'selectedAnswer': selectedAnswer,
        'correctAnswer': question.correctAnswer,
        'isCorrect': isCorrect,
      };
    }

    final attemptDoc = _attempts.doc();
    final batch = _db.batch();

    batch.set(attemptDoc, {
      'id': attemptDoc.id,
      'userId': user.uid,
      'userName': _userName(user),
      'userPhotoUrl': user.photoURL ?? '',
      'quizId': quiz.id,
      'quizTitle': quiz.title,
      'courseId': courseId,
      'subjectId': subjectId,
      'score': score,
      'totalQuestions': questions.length,
      'answers': answers,
      'completedAt': FieldValue.serverTimestamp(),
    });

    batch.set(_users.doc(user.uid), {
      'id': user.uid,
      'name': _userName(user),
      'email': user.email ?? '',
      'photoUrl': user.photoURL ?? '',
      'totalScore': FieldValue.increment(score),
      'quizzesAttempted': FieldValue.increment(1),
      'streak': FieldValue.increment(1),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    batch.delete(_progress.doc(_progressId(user.uid, quiz.id)));
    await batch.commit();
    return attemptDoc.id;
  }

  Stream<List<QuizAttempt>> attemptsForUser(String userId) {
    return _attempts
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final attempts = snapshot.docs.map(QuizAttempt.fromDoc).toList();
      attempts.sort((a, b) {
        final aDate = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return attempts;
    });
  }

  Stream<List<QuizAttempt>> attemptsForCourse(String courseId) {
    return _attempts
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(QuizAttempt.fromDoc).toList());
  }

  Stream<List<AppUser>> leaderboard({int limit = 20}) {
    return _users
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AppUser.fromDoc).toList());
  }

  Stream<List<Bookmark>> bookmarksForUser(String userId) {
    return _bookmarks
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final bookmarks = snapshot.docs.map(Bookmark.fromDoc).toList();
      bookmarks.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return bookmarks;
    });
  }

  Stream<bool> isBookmarked({
    required String userId,
    required String questionId,
  }) {
    return _bookmarks
        .doc(_bookmarkId(userId, questionId))
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleBookmark({
    required String userId,
    required QuizQuestion question,
  }) async {
    final doc = _bookmarks.doc(_bookmarkId(userId, question.id));
    final snapshot = await doc.get();
    if (snapshot.exists) {
      await doc.delete();
      return;
    }

    await doc.set({
      'id': doc.id,
      'userId': userId,
      'questionId': question.id,
      'quizId': question.quizId,
      'questionText': question.questionText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> addCourse({
    required String title,
    required String description,
  }) async {
    final doc = _courses.doc();
    await doc.set({
      'id': doc.id,
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> addSubject({
    required String courseId,
    required String title,
  }) async {
    final doc = _subjects.doc();
    await doc.set({
      'id': doc.id,
      'courseId': courseId,
      'title': title.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> addQuiz({
    required String subjectId,
    required String title,
    required int totalQuestions,
    required int duration,
  }) async {
    final doc = _quizzes.doc();
    await doc.set({
      'id': doc.id,
      'subjectId': subjectId,
      'title': title.trim(),
      'totalQuestions': totalQuestions,
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> addQuestion({
    required String quizId,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    required String explanation,
  }) async {
    final doc = _questions.doc();
    await doc.set({
      'id': doc.id,
      'quizId': quizId,
      'questionText': questionText.trim(),
      'options': options.map((option) => option.trim()).toList(),
      'correctAnswer': correctAnswer.trim(),
      'explanation': explanation.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> seedSampleData() async {
    final batch = _db.batch();

    final courses = [
      {
        'id': 'course_english',
        'title': 'English',
        'description': 'Grammar, vocabulary, and comprehension practice',
      },
      {
        'id': 'course_math',
        'title': 'Mathematics',
        'description': 'Arithmetic, algebra, and problem solving',
      },
      {
        'id': 'course_physics',
        'title': 'Physics',
        'description': 'Motion, force, energy, and experiments',
      },
    ];

    final subjects = [
      {
        'id': 'subject_grammar',
        'courseId': 'course_english',
        'title': 'Grammar',
      },
      {
        'id': 'subject_vocabulary',
        'courseId': 'course_english',
        'title': 'Vocabulary',
      },
      {
        'id': 'subject_algebra',
        'courseId': 'course_math',
        'title': 'Algebra',
      },
      {
        'id': 'subject_arithmetic',
        'courseId': 'course_math',
        'title': 'Arithmetic',
      },
      {
        'id': 'subject_motion',
        'courseId': 'course_physics',
        'title': 'Motion',
      },
      {
        'id': 'subject_energy',
        'courseId': 'course_physics',
        'title': 'Energy',
      },
    ];

    final quizzes = [
      {
        'id': 'quiz_tenses',
        'subjectId': 'subject_grammar',
        'title': 'Tenses Basics',
        'totalQuestions': 3,
        'duration': 10,
      },
      {
        'id': 'quiz_synonyms',
        'subjectId': 'subject_vocabulary',
        'title': 'Synonyms Challenge',
        'totalQuestions': 3,
        'duration': 8,
      },
      {
        'id': 'quiz_linear_eq',
        'subjectId': 'subject_algebra',
        'title': 'Linear Equations',
        'totalQuestions': 3,
        'duration': 10,
      },
      {
        'id': 'quiz_basic_arithmetic',
        'subjectId': 'subject_arithmetic',
        'title': 'Basic Arithmetic',
        'totalQuestions': 3,
        'duration': 8,
      },
      {
        'id': 'quiz_speed_motion',
        'subjectId': 'subject_motion',
        'title': 'Speed and Motion',
        'totalQuestions': 3,
        'duration': 10,
      },
      {
        'id': 'quiz_energy_forms',
        'subjectId': 'subject_energy',
        'title': 'Forms of Energy',
        'totalQuestions': 3,
        'duration': 8,
      },
    ];

    final questions = [
      {
        'id': 'q_tenses_1',
        'quizId': 'quiz_tenses',
        'questionText': 'Choose the correct sentence.',
        'options': [
          'She go to school every day.',
          'She goes to school every day.',
          'She going to school every day.',
          'She gone to school every day.',
        ],
        'correctAnswer': 'She goes to school every day.',
        'explanation':
            'For third-person singular in present simple, use goes.',
      },
      {
        'id': 'q_tenses_2',
        'quizId': 'quiz_tenses',
        'questionText': 'Identify the past tense sentence.',
        'options': [
          'He eats breakfast.',
          'He is eating breakfast.',
          'He ate breakfast.',
          'He will eat breakfast.',
        ],
        'correctAnswer': 'He ate breakfast.',
        'explanation': 'Ate is the past tense of eat.',
      },
      {
        'id': 'q_tenses_3',
        'quizId': 'quiz_tenses',
        'questionText': 'Which sentence is in future tense?',
        'options': [
          'They played football.',
          'They are playing football.',
          'They will play football.',
          'They play football.',
        ],
        'correctAnswer': 'They will play football.',
        'explanation': 'Will play shows future tense.',
      },
      {
        'id': 'q_syn_1',
        'quizId': 'quiz_synonyms',
        'questionText': 'Choose the synonym of happy.',
        'options': ['Sad', 'Joyful', 'Angry', 'Tired'],
        'correctAnswer': 'Joyful',
        'explanation': 'Joyful has a similar meaning to happy.',
      },
      {
        'id': 'q_syn_2',
        'quizId': 'quiz_synonyms',
        'questionText': 'Choose the synonym of quick.',
        'options': ['Slow', 'Rapid', 'Weak', 'Late'],
        'correctAnswer': 'Rapid',
        'explanation': 'Rapid means fast or quick.',
      },
      {
        'id': 'q_syn_3',
        'quizId': 'quiz_synonyms',
        'questionText': 'Choose the synonym of begin.',
        'options': ['Start', 'End', 'Break', 'Close'],
        'correctAnswer': 'Start',
        'explanation': 'Start means the same as begin.',
      },
      {
        'id': 'q_lin_1',
        'quizId': 'quiz_linear_eq',
        'questionText': 'Solve: x + 5 = 12',
        'options': ['5', '6', '7', '8'],
        'correctAnswer': '7',
        'explanation': 'Subtract 5 from both sides: x = 7.',
      },
      {
        'id': 'q_lin_2',
        'quizId': 'quiz_linear_eq',
        'questionText': 'Solve: 2x = 14',
        'options': ['6', '7', '8', '9'],
        'correctAnswer': '7',
        'explanation': 'Divide both sides by 2.',
      },
      {
        'id': 'q_lin_3',
        'quizId': 'quiz_linear_eq',
        'questionText': 'Solve: x - 3 = 4',
        'options': ['5', '6', '7', '8'],
        'correctAnswer': '7',
        'explanation': 'Add 3 to both sides.',
      },
      {
        'id': 'q_arith_1',
        'quizId': 'quiz_basic_arithmetic',
        'questionText': 'What is 8 + 5?',
        'options': ['11', '12', '13', '14'],
        'correctAnswer': '13',
        'explanation': '8 plus 5 equals 13.',
      },
      {
        'id': 'q_arith_2',
        'quizId': 'quiz_basic_arithmetic',
        'questionText': 'What is 9 x 3?',
        'options': ['18', '21', '27', '36'],
        'correctAnswer': '27',
        'explanation': '9 multiplied by 3 is 27.',
      },
      {
        'id': 'q_arith_3',
        'quizId': 'quiz_basic_arithmetic',
        'questionText': 'What is 20 - 6?',
        'options': ['12', '13', '14', '15'],
        'correctAnswer': '14',
        'explanation': '20 minus 6 equals 14.',
      },
      {
        'id': 'q_motion_1',
        'quizId': 'quiz_speed_motion',
        'questionText': 'Speed is defined as:',
        'options': [
          'Distance x Time',
          'Distance / Time',
          'Time / Distance',
          'Mass x Acceleration',
        ],
        'correctAnswer': 'Distance / Time',
        'explanation': 'Speed equals distance divided by time.',
      },
      {
        'id': 'q_motion_2',
        'quizId': 'quiz_speed_motion',
        'questionText': 'What is the SI unit of speed?',
        'options': ['km', 'm/s', 'kg', 'N'],
        'correctAnswer': 'm/s',
        'explanation': 'Meters per second is the SI unit of speed.',
      },
      {
        'id': 'q_motion_3',
        'quizId': 'quiz_speed_motion',
        'questionText':
            'If distance increases while time stays the same, speed will:',
        'options': ['Decrease', 'Increase', 'Stay zero', 'Disappear'],
        'correctAnswer': 'Increase',
        'explanation':
            'More distance in the same time means greater speed.',
      },
      {
        'id': 'q_energy_1',
        'quizId': 'quiz_energy_forms',
        'questionText': 'Which is a form of energy?',
        'options': ['Heat', 'Length', 'Mass', 'Volume'],
        'correctAnswer': 'Heat',
        'explanation': 'Heat is a form of energy.',
      },
      {
        'id': 'q_energy_2',
        'quizId': 'quiz_energy_forms',
        'questionText': 'Stored energy is called:',
        'options': [
          'Kinetic energy',
          'Potential energy',
          'Sound energy',
          'Thermal energy',
        ],
        'correctAnswer': 'Potential energy',
        'explanation': 'Potential energy is stored energy.',
      },
      {
        'id': 'q_energy_3',
        'quizId': 'quiz_energy_forms',
        'questionText': 'Energy of motion is called:',
        'options': [
          'Potential energy',
          'Chemical energy',
          'Kinetic energy',
          'Light energy',
        ],
        'correctAnswer': 'Kinetic energy',
        'explanation':
            'Kinetic energy is the energy an object has due to motion.',
      },
    ];

    for (final course in courses) {
      batch.set(
        _courses.doc(course['id']! as String),
        {
          ...course,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    for (final subject in subjects) {
      batch.set(
        _subjects.doc(subject['id']! as String),
        {
          ...subject,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    for (final quiz in quizzes) {
      batch.set(
        _quizzes.doc(quiz['id']! as String),
        {
          ...quiz,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    for (final question in questions) {
      batch.set(
        _questions.doc(question['id']! as String),
        {
          ...question,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  String _progressId(String userId, String quizId) => '${userId}_$quizId';
  String _bookmarkId(String userId, String questionId) =>
      '${userId}_$questionId';

  String _userName(User user, {String? name}) {
    final explicitName = name?.trim();
    if (explicitName != null && explicitName.isNotEmpty) return explicitName;

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final emailName = user.email?.split('@').first.trim();
    if (emailName != null && emailName.isNotEmpty) return emailName;

    return 'Learner';
  }
}
