import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/sample_quiz_data.dart';
import '../models/app_user.dart';
import '../models/bookmark.dart';
import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_question.dart';
import '../models/quiz_subject.dart';
import 'trivia_api_service.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();
  static const Duration sessionTimeout = Duration(minutes: 15);

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

  Future<void> ensureUserProfile(
    User user, {
    String? name,
    String? role,
  }) async {
    final doc = _users.doc(user.uid);
    final snapshot = await doc.get();
    final displayName = _userName(user, name: name);
    final resolvedRole = role ?? _defaultRoleForUser(user);

    if (!snapshot.exists) {
      await doc.set({
        'id': user.uid,
        'name': displayName,
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': resolvedRole,
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
      'role': snapshot.data()?['role']?.toString() ?? resolvedRole,
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> startSession(String userId) {
    return _users.doc(userId).set({
      'sessionExpiresAt': Timestamp.fromDate(
        DateTime.now().add(sessionTimeout),
      ),
      'lastActiveAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearSession(String userId) {
    return _users.doc(userId).set({
      'sessionExpiresAt': null,
    }, SetOptions(merge: true));
  }

  Stream<List<Course>> coursesStream() {
    return _courses.snapshots().map((snapshot) {
      final courses = _uniqueCourses(snapshot.docs.map(Course.fromDoc).toList());
      courses.sort((a, b) => a.title.compareTo(b.title));
      return courses;
    });
  }

  Stream<List<QuizSubject>> subjectsForCourse(String courseId) {
    return _subjects
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      final subjects = _uniqueSubjects(
        snapshot.docs.map(QuizSubject.fromDoc).toList(),
      );
      subjects.sort((a, b) => a.title.compareTo(b.title));
      return subjects;
    });
  }

  Stream<List<QuizSubject>> allSubjectsStream() {
    return _subjects.snapshots().map((snapshot) {
      final subjects = _uniqueSubjects(snapshot.docs.map(QuizSubject.fromDoc).toList());
      subjects.sort((a, b) => a.title.compareTo(b.title));
      return subjects;
    });
  }

  Stream<List<Quiz>> quizzesForSubject(String subjectId) {
    return _quizzes
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .map((snapshot) {
      final quizzes = _uniqueQuizzes(snapshot.docs.map(Quiz.fromDoc).toList());
      quizzes.sort((a, b) => a.title.compareTo(b.title));
      return quizzes;
    });
  }

  Stream<List<Quiz>> allQuizzesStream() {
    return _quizzes.snapshots().map((snapshot) {
      final quizzes = _uniqueQuizzes(snapshot.docs.map(Quiz.fromDoc).toList());
      quizzes.sort((a, b) => a.title.compareTo(b.title));
      return quizzes;
    });
  }

  Stream<List<QuizQuestion>> questionsForQuiz(String quizId) {
    return _questions
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snapshot) {
      final questions = _uniqueQuestions(
        snapshot.docs.map(QuizQuestion.fromDoc).toList(),
      );
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

  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Future<bool> isAdminUser(String userId) async {
    final user = await getUserProfile(userId);
    return user?.isAdmin == true;
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
    final appUser = await userStream(user.uid).first;
    if (appUser?.isAdmin == true) {
      throw StateError('Admin accounts cannot create quiz attempts.');
    }

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

  Stream<List<QuizAttempt>> attemptsForQuiz(String quizId) {
    return _attempts
        .where('quizId', isEqualTo: quizId)
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

  Stream<List<AppUser>> leaderboard({int limit = 20}) {
    return _users
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(AppUser.fromDoc)
              .where((user) => !user.isAdmin)
              .toList();
        });
  }

  Stream<Set<String>> adminUserIdsStream() {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .map(AppUser.fromDoc)
          .where((user) => user.isAdmin)
          .map((user) => user.id)
          .toSet();
    });
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
    final trimmedTitle = title.trim();
    final existing = await _courses.get();
    final hasDuplicate = existing.docs
        .map(Course.fromDoc)
        .any((course) => _normalized(course.title) == _normalized(trimmedTitle));
    if (hasDuplicate) {
      throw StateError('A course with this title already exists.');
    }

    final doc = _courses.doc();
    await doc.set({
      'id': doc.id,
      'title': trimmedTitle,
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> addSubject({
    required String courseId,
    required String title,
  }) async {
    final trimmedTitle = title.trim();
    final existing = await _subjects.where('courseId', isEqualTo: courseId).get();
    final hasDuplicate = existing.docs.map(QuizSubject.fromDoc).any(
      (subject) => _normalized(subject.title) == _normalized(trimmedTitle),
    );
    if (hasDuplicate) {
      throw StateError('A subject with this title already exists in this course.');
    }

    final doc = _subjects.doc();
    await doc.set({
      'id': doc.id,
      'courseId': courseId,
      'title': trimmedTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> _createQuiz({
    required String subjectId,
    required String title,
    required int totalQuestions,
    required int duration,
    String password = '',
    DateTime? startsAt,
    bool isPublished = true,
  }) async {
    final trimmedTitle = title.trim();
    final existing = await _quizzes.where('subjectId', isEqualTo: subjectId).get();
    final hasDuplicate = existing.docs.map(Quiz.fromDoc).any(
      (quiz) => _normalized(quiz.title) == _normalized(trimmedTitle),
    );
    if (hasDuplicate) {
      throw StateError('A quiz with this title already exists in this subject.');
    }

    final doc = _quizzes.doc();
    await doc.set({
      'id': doc.id,
      'subjectId': subjectId,
      'title': trimmedTitle,
      'totalQuestions': totalQuestions,
      'duration': duration,
      'password': password.trim(),
      'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt),
      'isPublished': isPublished,
      'isAdminGenerated': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<String> addQuiz({
    required String subjectId,
    required String title,
    required int totalQuestions,
    required int duration,
    String password = '',
    DateTime? startsAt,
    bool isPublished = true,
  }) {
    return _createQuiz(
      subjectId: subjectId,
      title: title,
      totalQuestions: totalQuestions,
      duration: duration,
      password: password,
      startsAt: startsAt,
      isPublished: isPublished,
    );
  }

  Future<String> addQuestion({
    required String quizId,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
    required String explanation,
    String difficulty = 'medium',
    String source = 'manual',
  }) async {
    final trimmedQuestion = questionText.trim();
    final trimmedOptions = options.map((option) => option.trim()).toList();
    final existing = await _questions.where('quizId', isEqualTo: quizId).get();
    final hasDuplicate = existing.docs.map(QuizQuestion.fromDoc).any(
      (question) => _questionSignature(question) == _questionSignatureFromValues(
        quizId: quizId,
        questionText: trimmedQuestion,
        options: trimmedOptions,
        correctAnswer: correctAnswer.trim(),
      ),
    );
    if (hasDuplicate) {
      throw StateError('This MCQ already exists in the selected quiz.');
    }

    final doc = _questions.doc();
    final batch = _db.batch();
    batch.set(doc, {
      'id': doc.id,
      'quizId': quizId,
      'questionText': trimmedQuestion,
      'options': trimmedOptions,
      'correctAnswer': correctAnswer.trim(),
      'explanation': explanation.trim(),
      'difficulty': _normalizedDifficulty(difficulty),
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_quizzes.doc(quizId), {
      'totalQuestions': FieldValue.increment(1),
    }, SetOptions(merge: true));
    await batch.commit();
    return doc.id;
  }

  Future<TriviaImportResult> importQuestionsFromTriviaApi({
    required String quizId,
    required int amount,
    String? categoryId,
    String? difficulty,
  }) async {
    final importedQuestions = <QuizQuestion>[];
    var remaining = amount;

    while (remaining > 0) {
      final batchSize = remaining > 50 ? 50 : remaining;
      final questions = await TriviaApiService.instance.fetchQuestions(
        amount: batchSize,
        categoryId: categoryId,
        difficulty: difficulty,
      );

      for (final question in questions) {
        try {
          final questionId = await addQuestion(
            quizId: quizId,
            questionText: question.questionText,
            options: question.options,
            correctAnswer: question.correctAnswer,
            explanation:
                'Imported from Open Trivia DB (${question.category}, ${question.difficulty}).',
            difficulty: question.difficulty,
            source: 'internet',
          );
          importedQuestions.add(
            QuizQuestion(
              id: questionId,
              quizId: quizId,
              questionText: question.questionText,
              options: question.options,
              correctAnswer: question.correctAnswer,
              explanation:
                  'Imported from Open Trivia DB (${question.category}, ${question.difficulty}).',
              difficulty: _normalizedDifficulty(question.difficulty),
              isPracticeVariant: false,
              practiceVariantLabel: '',
              source: 'internet',
            ),
          );
        } on StateError {
          // Skip duplicates quietly during batch import.
        }
      }

      if (questions.isEmpty) break;
      remaining -= batchSize;
    }

    await syncQuizQuestionCount(quizId);
    return TriviaImportResult(importedQuestions: importedQuestions);
  }

  Future<TriviaImportResult> importSubjectQuestionBankFromTriviaApi({
    required QuizSubject subject,
    required Course course,
    int totalQuestions = 10,
    int duration = 30,
  }) async {
    final quizId = await _ensureSubjectQuestionBankQuiz(
      subject: subject,
      duration: duration,
    );

    final categoryId = _defaultTriviaCategoryId(
      subjectTitle: subject.title,
      courseTitle: course.title,
    );
    if (categoryId == null) {
      throw StateError(
        'Online import is not available for "${subject.title}" because Open Trivia DB does not provide a reliable category for this subject. Try a broader subject like Computers, Mathematics, Science, History, or Geography.',
      );
    }

    final imported = await importQuestionsFromTriviaApi(
      quizId: quizId,
      amount: totalQuestions,
      categoryId: categoryId,
      difficulty: 'any',
    );

    await _quizzes.doc(quizId).set({
      'duration': duration,
    }, SetOptions(merge: true));

    return imported;
  }

  Future<String> ensureSubjectQuestionBankQuizId({
    required QuizSubject subject,
    int duration = 30,
  }) {
    return _ensureSubjectQuestionBankQuiz(
      subject: subject,
      duration: duration,
    );
  }

  bool supportsTriviaImport({
    required String subjectTitle,
    required String courseTitle,
  }) {
    return _defaultTriviaCategoryId(
          subjectTitle: subjectTitle,
          courseTitle: courseTitle,
        ) !=
        null;
  }

  Future<BulkImportResult> importQuestionBanksForAllSubjects({
    int totalQuestionsPerSubject = 210,
    int duration = 30,
  }) async {
    final courseSnapshot = await _courses.get();
    final subjectSnapshot = await _subjects.get();

    final courses = {
      for (final course in courseSnapshot.docs.map(Course.fromDoc)) course.id: course,
    };
    final subjects = subjectSnapshot.docs.map(QuizSubject.fromDoc).toList()
      ..sort((a, b) => a.title.compareTo(b.title));

    var importedQuestions = 0;
    var subjectCount = 0;

    for (final subject in subjects) {
      final course = courses[subject.courseId];
      if (course == null) continue;

      final imported = await importSubjectQuestionBankFromTriviaApi(
        subject: subject,
        course: course,
        totalQuestions: totalQuestionsPerSubject,
        duration: duration,
      );
      importedQuestions += imported.count;
      subjectCount++;
    }

    return BulkImportResult(
      subjectCount: subjectCount,
      importedQuestions: importedQuestions,
    );
  }

  Future<int> removeDuplicateContent() async {
    final legacyRemovals = await removeCoursesByTitles(const [
      'Social Science',
      'Software Testing',
    ]);

    final duplicateCourseIds = <String>{};
    final duplicateSubjectIds = <String>{};
    final duplicateQuizIds = <String>{};
    final duplicateQuestionIds = <String>{};
    final courseReassignments = <String, String>{};
    final subjectReassignments = <String, String>{};
    final quizReassignments = <String, String>{};

    final courseSnapshot = await _courses.get();
    final subjectSnapshot = await _subjects.get();
    final quizSnapshot = await _quizzes.get();
    final questionSnapshot = await _questions.get();

    final courses = courseSnapshot.docs.map(Course.fromDoc).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final subjects = subjectSnapshot.docs.map(QuizSubject.fromDoc).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final quizzes = quizSnapshot.docs.map(Quiz.fromDoc).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final questions = questionSnapshot.docs.map(QuizQuestion.fromDoc).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final seenCourses = <String, Course>{};
    for (final course in courses) {
      final key = _normalized(course.title);
      final existing = seenCourses[key];
      if (existing != null) {
        duplicateCourseIds.add(course.id);
        courseReassignments[course.id] = existing.id;
      } else {
        seenCourses[key] = course;
      }
    }

    final seenSubjects = <String, QuizSubject>{};
    for (final subject in subjects) {
      final resolvedCourseId = courseReassignments[subject.courseId] ?? subject.courseId;
      final resolvedSubject = QuizSubject(
        id: subject.id,
        courseId: resolvedCourseId,
        title: subject.title,
      );
      final key = '${resolvedSubject.courseId}|${_normalized(resolvedSubject.title)}';
      final existing = seenSubjects[key];
      if (existing != null) {
        duplicateSubjectIds.add(subject.id);
        subjectReassignments[subject.id] = existing.id;
      } else {
        seenSubjects[key] = resolvedSubject;
      }
    }

    final seenQuizzes = <String, Quiz>{};
    for (final quiz in quizzes) {
      final resolvedSubjectId = subjectReassignments[quiz.subjectId] ?? quiz.subjectId;
      final resolvedQuiz = Quiz(
        id: quiz.id,
        subjectId: resolvedSubjectId,
        title: quiz.title,
        totalQuestions: quiz.totalQuestions,
        duration: quiz.duration,
        password: quiz.password,
        startsAt: quiz.startsAt,
        isPublished: quiz.isPublished,
        isAdminGenerated: quiz.isAdminGenerated,
      );
      final key = '${resolvedQuiz.subjectId}|${_normalized(resolvedQuiz.title)}';
      final existing = seenQuizzes[key];
      if (existing != null) {
        duplicateQuizIds.add(quiz.id);
        quizReassignments[quiz.id] = existing.id;
      } else {
        seenQuizzes[key] = resolvedQuiz;
      }
    }

    final seenQuestions = <String, String>{};
    for (final question in questions) {
      final resolvedQuizId = quizReassignments[question.quizId] ?? question.quizId;
      final key = _questionSignatureFromValues(
        quizId: resolvedQuizId,
        questionText: question.questionText,
        options: question.options,
        correctAnswer: question.correctAnswer,
      );
      if (seenQuestions.containsKey(key)) {
        duplicateQuestionIds.add(question.id);
      } else {
        seenQuestions[key] = question.id;
      }
    }

    var mutationCount = 0;
    final batch = _db.batch();

    for (final subject in subjects) {
      final targetCourseId = courseReassignments[subject.courseId];
      if (targetCourseId != null && !duplicateSubjectIds.contains(subject.id)) {
        batch.update(_subjects.doc(subject.id), {'courseId': targetCourseId});
        mutationCount++;
      }
    }

    for (final quiz in quizzes) {
      final targetSubjectId = subjectReassignments[quiz.subjectId];
      if (targetSubjectId != null && !duplicateQuizIds.contains(quiz.id)) {
        batch.update(_quizzes.doc(quiz.id), {'subjectId': targetSubjectId});
        mutationCount++;
      }
    }

    for (final question in questions) {
      final targetQuizId = quizReassignments[question.quizId];
      if (targetQuizId != null && !duplicateQuestionIds.contains(question.id)) {
        batch.update(_questions.doc(question.id), {'quizId': targetQuizId});
        mutationCount++;
      }
    }

    for (final questionId in duplicateQuestionIds) {
      batch.delete(_questions.doc(questionId));
      mutationCount++;
    }

    for (final quizId in duplicateQuizIds) {
      batch.delete(_quizzes.doc(quizId));
      mutationCount++;
    }

    for (final subjectId in duplicateSubjectIds) {
      batch.delete(_subjects.doc(subjectId));
      mutationCount++;
    }

    for (final courseId in duplicateCourseIds) {
      batch.delete(_courses.doc(courseId));
      mutationCount++;
    }

    if (mutationCount > 0) {
      await batch.commit();
    }

    await syncAllQuizQuestionCounts();
    return mutationCount + legacyRemovals;
  }

  Future<int> removeCoursesByTitles(List<String> courseTitles) async {
    if (courseTitles.isEmpty) return 0;

    final normalizedTitles = courseTitles.map(_normalized).toSet();
    final courseSnapshot = await _courses.get();
    final coursesToDelete = courseSnapshot.docs
        .map(Course.fromDoc)
        .where((course) => normalizedTitles.contains(_normalized(course.title)))
        .toList();

    if (coursesToDelete.isEmpty) return 0;

    final courseIds = coursesToDelete.map((course) => course.id).toSet();
    final subjectSnapshot = await _subjects.get();
    final subjectsToDelete = subjectSnapshot.docs
        .map(QuizSubject.fromDoc)
        .where((subject) => courseIds.contains(subject.courseId))
        .toList();
    final subjectIds = subjectsToDelete.map((subject) => subject.id).toSet();

    final quizSnapshot = await _quizzes.get();
    final quizzesToDelete = quizSnapshot.docs
        .map(Quiz.fromDoc)
        .where((quiz) => subjectIds.contains(quiz.subjectId))
        .toList();
    final quizIds = quizzesToDelete.map((quiz) => quiz.id).toSet();

    final questionSnapshot = await _questions.get();
    final questionIds = questionSnapshot.docs
        .map(QuizQuestion.fromDoc)
        .where((question) => quizIds.contains(question.quizId))
        .map((question) => question.id)
        .toList();

    final attemptSnapshot = await _attempts.get();
    final attemptIds = attemptSnapshot.docs
        .map(QuizAttempt.fromDoc)
        .where((attempt) => quizIds.contains(attempt.quizId))
        .map((attempt) => attempt.id)
        .toList();

    final progressSnapshot = await _progress.get();
    final progressIds = progressSnapshot.docs
        .where((doc) {
          final progress = QuizProgress.fromDoc(doc);
          return quizIds.contains(progress.quizId);
        })
        .map((doc) => doc.id)
        .toList();

    final bookmarkSnapshot = await _bookmarks.get();
    final bookmarkIds = bookmarkSnapshot.docs
        .map(Bookmark.fromDoc)
        .where((bookmark) => quizIds.contains(bookmark.quizId))
        .map((bookmark) => bookmark.id)
        .toList();

    final docRefs = <DocumentReference<Map<String, dynamic>>>[
      for (final id in questionIds) _questions.doc(id),
      for (final id in attemptIds) _attempts.doc(id),
      for (final id in progressIds) _progress.doc(id),
      for (final id in bookmarkIds) _bookmarks.doc(id),
      for (final quiz in quizzesToDelete) _quizzes.doc(quiz.id),
      for (final subject in subjectsToDelete) _subjects.doc(subject.id),
      for (final course in coursesToDelete) _courses.doc(course.id),
    ];

    for (var i = 0; i < docRefs.length; i += 450) {
      final batch = _db.batch();
      final chunk = docRefs.skip(i).take(450);
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }

    return docRefs.length;
  }

  Future<int> seedSampleContent() async {
    final batch = _db.batch();
    var questionCount = 0;

    for (final course in sampleCourses) {
      batch.set(_courses.doc(course.id), {
        'id': course.id,
        'title': course.title,
        'description': course.description,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      for (final subject in course.subjects) {
        batch.set(_subjects.doc(subject.id), {
          'id': subject.id,
          'courseId': course.id,
          'title': subject.title,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        for (final quiz in subject.quizzes) {
          batch.set(_quizzes.doc(quiz.id), {
            'id': quiz.id,
            'subjectId': subject.id,
            'title': quiz.title,
            'totalQuestions': quiz.questions.length,
            'duration': quiz.duration,
            'password': '',
            'startsAt': null,
            'isPublished': true,
            'isAdminGenerated': true,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          for (final question in quiz.questions) {
            batch.set(_questions.doc(question.id), {
              'id': question.id,
              'quizId': quiz.id,
              'questionText': question.questionText,
              'options': question.options,
              'correctAnswer': question.correctAnswer,
              'explanation': question.explanation,
              'difficulty': 'medium',
              'isPracticeVariant': false,
              'practiceVariantLabel': '',
              'source': 'sample',
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            questionCount++;
          }
        }
      }
    }

    await batch.commit();
    return questionCount;
  }

  Future<bool> hasSeedSampleContent() async {
    final firstCourse = sampleCourses.isEmpty ? null : sampleCourses.first;
    if (firstCourse == null) {
      return false;
    }

    final courseDoc = await _courses.doc(firstCourse.id).get();
    return courseDoc.exists;
  }

  Future<void> syncQuizQuestionCount(String quizId) async {
    final questionSnapshot = await _questions
        .where('quizId', isEqualTo: quizId)
        .get();
    await _quizzes.doc(quizId).set({
      'totalQuestions': questionSnapshot.docs.length,
    }, SetOptions(merge: true));
  }

  Future<void> syncAllQuizQuestionCounts() async {
    final quizSnapshot = await _quizzes.get();
    for (final doc in quizSnapshot.docs) {
      await syncQuizQuestionCount(doc.id);
    }
  }

  Future<String> _ensureSubjectQuestionBankQuiz({
    required QuizSubject subject,
    required int duration,
  }) async {
    final preferredTitle = '${subject.title} Question Bank';
    final quizSnapshot = await _quizzes
        .where('subjectId', isEqualTo: subject.id)
        .get();

    for (final quiz in quizSnapshot.docs.map(Quiz.fromDoc)) {
      if (_normalized(quiz.title) == _normalized(preferredTitle)) {
        await _quizzes.doc(quiz.id).set({
          'duration': duration,
        }, SetOptions(merge: true));
        return quiz.id;
      }
    }

    if (quizSnapshot.docs.isNotEmpty) {
      final existing = Quiz.fromDoc(quizSnapshot.docs.first);
      await _quizzes.doc(existing.id).set({
        'duration': duration,
      }, SetOptions(merge: true));
      return existing.id;
    }

    return _createQuiz(
      subjectId: subject.id,
      title: preferredTitle,
      totalQuestions: 0,
      duration: duration,
      password: '',
      startsAt: null,
      isPublished: true,
    );
  }

  String? _defaultTriviaCategoryId({
    required String subjectTitle,
    required String courseTitle,
  }) {
    final subject = _normalized(subjectTitle);
    final course = _normalized(courseTitle);
    final combined = '$course $subject';

    if (subject.contains('dart') ||
        subject.contains('flutter') ||
        subject.contains('react') ||
        subject.contains('angular') ||
        subject.contains('html') ||
        subject.contains('css') ||
        subject.contains('javascript') ||
        subject.contains('java') ||
        subject.contains('python') ||
        subject.contains('c++') ||
        subject.contains('c#')) {
      return null;
    }

    if (combined.contains('computer') ||
        combined.contains('program') ||
        combined.contains('database') ||
        combined.contains('network')) {
      return '18';
    }
    if (combined.contains('math') ||
        combined.contains('algebra') ||
        combined.contains('geometry') ||
        combined.contains('arithmetic')) {
      return '19';
    }
    if (combined.contains('science') ||
        combined.contains('physics') ||
        combined.contains('chemistry') ||
        combined.contains('biology')) {
      return '17';
    }
    if (combined.contains('history') || combined.contains('pakistan studies')) {
      return '23';
    }
    if (combined.contains('geography') || combined.contains('world')) {
      return '22';
    }
    if (combined.contains('general knowledge') || combined.contains('gk')) {
      return '9';
    }

    return null;
  }

  String _progressId(String userId, String quizId) => '${userId}_$quizId';
  String _bookmarkId(String userId, String questionId) =>
      '${userId}_$questionId';

  List<Course> _uniqueCourses(List<Course> courses) {
    final byTitle = <String, Course>{};
    for (final course in courses) {
      final key = _normalized(course.title);
      final existing = byTitle[key];
      if (existing == null ||
          course.description.trim().length > existing.description.trim().length) {
        byTitle[key] = course;
      }
    }
    return byTitle.values.toList();
  }

  List<QuizSubject> _uniqueSubjects(List<QuizSubject> subjects) {
    final seen = <String>{};
    return subjects
        .where((subject) => seen.add('${subject.courseId}|${_normalized(subject.title)}'))
        .toList();
  }

  List<Quiz> _uniqueQuizzes(List<Quiz> quizzes) {
    final seen = <String>{};
    return quizzes
        .where((quiz) => seen.add('${quiz.subjectId}|${_normalized(quiz.title)}'))
        .toList();
  }

  List<QuizQuestion> _uniqueQuestions(List<QuizQuestion> questions) {
    final seen = <String>{};
    return questions.where((question) => seen.add(_questionSignature(question))).toList();
  }

  String _questionSignature(QuizQuestion question) {
    return _questionSignatureFromValues(
      quizId: question.quizId,
      questionText: question.questionText,
      options: question.options,
      correctAnswer: question.correctAnswer,
    );
  }

  String _questionSignatureFromValues({
    required String quizId,
    required String questionText,
    required List<String> options,
    required String correctAnswer,
  }) {
    final normalizedOptions =
        options.map(_normalized).where((option) => option.isNotEmpty).join('|');
    return '$quizId|${_normalized(questionText)}|$normalizedOptions|${_normalized(correctAnswer)}';
  }

  String _normalized(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizedDifficulty(String value) {
    final normalized = _normalized(value);
    if (normalized == 'easy' || normalized == 'medium' || normalized == 'hard') {
      return normalized;
    }
    return 'medium';
  }

  String _userName(User user, {String? name}) {
    final explicitName = name?.trim();
    if (explicitName != null && explicitName.isNotEmpty) return explicitName;

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final emailName = user.email?.split('@').first.trim();
    if (emailName != null && emailName.isNotEmpty) return emailName;

    return 'Learner';
  }

  String _defaultRoleForUser(User user) {
    return 'user';
  }
}

class BulkImportResult {
  final int subjectCount;
  final int importedQuestions;

  const BulkImportResult({
    required this.subjectCount,
    required this.importedQuestions,
  });
}

class TriviaImportResult {
  final List<QuizQuestion> importedQuestions;

  const TriviaImportResult({
    required this.importedQuestions,
  });

  int get count => importedQuestions.length;
}
