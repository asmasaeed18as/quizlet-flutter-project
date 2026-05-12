import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded)),
              Tab(text: 'Course', icon: Icon(Icons.school_rounded)),
              Tab(text: 'Subject', icon: Icon(Icons.topic_rounded)),
              Tab(text: 'Quiz', icon: Icon(Icons.quiz_rounded)),
              Tab(text: 'Import', icon: Icon(Icons.download_rounded)),
              Tab(text: 'Question', icon: Icon(Icons.help_rounded)),
            ],
          ),
        ),
        body: AppBackground(
          child: SafeArea(
            top: false,
            child: const TabBarView(
              children: [
                _AdminTabBody(
                  children: [
                    _SeedSampleContentCard(),
                    SizedBox(height: 12),
                    _CleanupDuplicatesCard(),
                    SizedBox(height: 12),
                    _QuestionBankSummaryPanel(),
                  ],
                ),
                _AdminTabBody(
                  children: [
                    _AddCourseForm(),
                  ],
                ),
                _AdminTabBody(
                  children: [
                    _AddSubjectForm(),
                  ],
                ),
                _AdminTabBody(
                  children: [
                    _AddQuizForm(),
                  ],
                ),
                _AdminTabBody(
                  children: [
                    _ImportQuestionsForm(),
                  ],
                ),
                _AdminTabBody(
                  children: [
                    _AddQuestionForm(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await FirestoreService.instance.clearSession(userId);
        } catch (_) {}
      }
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!context.mounted) return;
      _showMessage(context, 'Sign out failed. Please try again.');
    }
  }
}

class _AdminTabBody extends StatelessWidget {
  final List<Widget> children;

  const _AdminTabBody({required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: children,
    );
  }
}

class _SeedSampleContentCard extends StatefulWidget {
  const _SeedSampleContentCard();

  @override
  State<_SeedSampleContentCard> createState() => _SeedSampleContentCardState();
}

class _SeedSampleContentCardState extends State<_SeedSampleContentCard> {
  bool _isSeeding = false;
  bool _isChecking = true;
  bool _hasSeedData = false;

  @override
  void initState() {
    super.initState();
    _loadSeedStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0093E9), Color(0xFF80D0C7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              const SizedBox(height: 10),
              const Text(
                'Demo Sample Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _hasSeedData
                    ? 'Sample demo data already exists. Use this again only if you want to restore the demo dataset for testing.'
                    : 'Add a small demo dataset with 5 courses, 15 subjects, 15 quizzes, and 75 curated sample MCQs for testing only.',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF087EA4),
                ),
                onPressed: (_isSeeding || _isChecking) ? null : _seed,
                icon: (_isSeeding || _isChecking)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  _isChecking
                      ? 'Checking sample data...'
                      : _isSeeding
                          ? (_hasSeedData
                              ? 'Restoring sample data...'
                              : 'Adding content...')
                          : (_hasSeedData
                              ? 'Demo Data Already Added'
                              : 'Add Sample MCQs'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSeedStatus() async {
    try {
      final hasSeedData = await FirestoreService.instance.hasSeedSampleContent();
      if (!mounted) return;
      setState(() {
        _hasSeedData = hasSeedData;
        _isChecking = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasSeedData = false;
        _isChecking = false;
      });
    }
  }

  Future<void> _seed() async {
    final wasAlreadySeeded = _hasSeedData;
    setState(() => _isSeeding = true);
    try {
      final count = await FirestoreService.instance.seedSampleContent();
      if (!mounted) return;
      setState(() => _hasSeedData = true);
      _showMessage(
        context,
        wasAlreadySeeded
            ? 'Sample data synced: $count MCQs.'
            : 'Sample content added: $count MCQs.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(context, 'Could not add sample content: $error');
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }
}

class _AdminInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _AdminInfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanupDuplicatesCard extends StatefulWidget {
  const _CleanupDuplicatesCard();

  @override
  State<_CleanupDuplicatesCard> createState() =>
      _CleanupDuplicatesCardState();
}

class _CleanupDuplicatesCardState extends State<_CleanupDuplicatesCard> {
  bool _isCleaning = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove Repetitive Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Delete duplicate courses, subjects, quizzes, and MCQs from Firestore and keep only unique entries visible.',
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _isCleaning ? null : _cleanup,
              icon: _isCleaning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cleaning_services_rounded),
              label: Text(
                _isCleaning ? 'Cleaning duplicates...' : 'Delete Duplicates',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cleanup() async {
    setState(() => _isCleaning = true);
    try {
      final removed = await FirestoreService.instance.removeDuplicateContent();
      if (!mounted) return;
      _showMessage(
        context,
        removed == 0
            ? 'No duplicate data found.'
            : 'Removed $removed duplicate items.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(context, 'Could not remove duplicates: $error');
    } finally {
      if (mounted) setState(() => _isCleaning = false);
    }
  }
}

class _InlineState extends StatelessWidget {
  final Widget child;

  const _InlineState({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 180, child: child);
  }
}

class _AddCourseForm extends StatefulWidget {
  const _AddCourseForm();

  @override
  State<_AddCourseForm> createState() => _AddCourseFormState();
}

class _AddCourseFormState extends State<_AddCourseForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Course title'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 3,
            maxLines: 5,
            validator: _required,
          ),
          const SizedBox(height: 18),
          _SaveButton(
            isSaving: _isSaving,
            label: 'Add Course',
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addCourse(
        title: _titleController.text,
        description: _descriptionController.text,
      );
      _titleController.clear();
      _descriptionController.clear();
      if (mounted) _showMessage(context, 'Course added.');
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not add course: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AddSubjectForm extends StatefulWidget {
  const _AddSubjectForm();

  @override
  State<_AddSubjectForm> createState() => _AddSubjectFormState();
}

class _AddSubjectFormState extends State<_AddSubjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _courseId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: FirestoreService.instance.coursesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _InlineState(child: ErrorState(error: snapshot.error));
        }
        if (!snapshot.hasData) {
          return const _InlineState(child: LoadingState());
        }

        final courses = snapshot.data!;
        if (courses.isEmpty) {
          return const _InlineState(
            child: EmptyState(
              icon: Icons.school_outlined,
              title: 'Add a course first',
              message: 'Subjects need to belong to a course.',
            ),
          );
        }

        final selectedCourseId = _safeSelectedId(_courseId, courses);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCourseId,
                decoration: const InputDecoration(labelText: 'Course'),
                items: [
                  for (final course in courses)
                    DropdownMenuItem(
                      value: course.id,
                      child: Text(course.title),
                    ),
                ],
                onChanged: (value) => setState(() => _courseId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Subject title'),
                validator: _required,
              ),
              const SizedBox(height: 18),
              _SaveButton(
                isSaving: _isSaving,
                label: 'Add Subject',
                onPressed: () => _save(selectedCourseId),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(String courseId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addSubject(
        courseId: courseId,
        title: _titleController.text,
      );
      _courseId = courseId;
      _titleController.clear();
      if (mounted) _showMessage(context, 'Subject added.');
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not add subject: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AddQuizForm extends StatefulWidget {
  const _AddQuizForm();

  @override
  State<_AddQuizForm> createState() => _AddQuizFormState();
}

class _AddQuizFormState extends State<_AddQuizForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalController = TextEditingController(text: '10');
  final _durationController = TextEditingController(text: '10');
  String? _subjectId;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuizSubject>>(
      stream: FirestoreService.instance.allSubjectsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _InlineState(child: ErrorState(error: snapshot.error));
        }
        if (!snapshot.hasData) {
          return const _InlineState(child: LoadingState());
        }

        final subjects = snapshot.data!;
        if (subjects.isEmpty) {
          return const _InlineState(
            child: EmptyState(
              icon: Icons.topic_outlined,
              title: 'Add a subject first',
              message: 'Quizzes need to belong to a subject.',
            ),
          );
        }

        final selectedSubjectId = _safeSelectedId(_subjectId, subjects);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: [
                  for (final subject in subjects)
                    DropdownMenuItem(
                      value: subject.id,
                      child: Text(subject.title),
                    ),
                ],
                onChanged: (value) => setState(() => _subjectId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Quiz title'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Total questions'),
                keyboardType: TextInputType.number,
                validator: _positiveNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration minutes'),
                keyboardType: TextInputType.number,
                validator: _positiveNumber,
              ),
              const SizedBox(height: 18),
              _SaveButton(
                isSaving: _isSaving,
                label: 'Add Quiz',
                onPressed: () => _save(selectedSubjectId),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(String subjectId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addQuiz(
        subjectId: subjectId,
        title: _titleController.text,
        totalQuestions: int.parse(_totalController.text.trim()),
        duration: int.parse(_durationController.text.trim()),
      );
      _subjectId = subjectId;
      _titleController.clear();
      if (mounted) _showMessage(context, 'Quiz added.');
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not add quiz: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _ImportQuestionsForm extends StatefulWidget {
  const _ImportQuestionsForm();

  @override
  State<_ImportQuestionsForm> createState() => _ImportQuestionsFormState();
}

class _ImportQuestionsFormState extends State<_ImportQuestionsForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '10');
  String? _subjectId;
  bool _isImporting = false;
  List<QuizQuestion> _lastImportedQuestions = const [];
  String? _lastImportedSubjectTitle;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: FirestoreService.instance.coursesStream(),
      builder: (context, courseSnapshot) {
        if (courseSnapshot.hasError) {
          return _InlineState(child: ErrorState(error: courseSnapshot.error));
        }
        if (!courseSnapshot.hasData) {
          return const _InlineState(child: LoadingState());
        }

        return StreamBuilder<List<QuizSubject>>(
          stream: FirestoreService.instance.allSubjectsStream(),
          builder: (context, subjectSnapshot) {
            if (subjectSnapshot.hasError) {
              return _InlineState(child: ErrorState(error: subjectSnapshot.error));
            }
            if (!subjectSnapshot.hasData) {
              return const _InlineState(child: LoadingState());
            }

            final coursesById = {
              for (final course in courseSnapshot.data!) course.id: course,
            };
            final subjects = subjectSnapshot.data!
                .where((subject) {
                  final course = coursesById[subject.courseId];
                  if (course == null) return false;
                  return FirestoreService.instance.supportsTriviaImport(
                    subjectTitle: subject.title,
                    courseTitle: course.title,
                  );
                })
                .toList();

            if (subjects.isEmpty) {
              return const _InlineState(
                child: EmptyState(
                  icon: Icons.topic_outlined,
                  title: 'No supported subjects',
                  message:
                      'Only subjects supported by the current internet source are shown here.',
                ),
              );
            }

            final selectedSubjectId = _safeSelectedId(_subjectId, subjects);

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedSubjectId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Internet-supported subject',
                    ),
                    selectedItemBuilder: (context) {
                      return [
                        for (final subject in subjects)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              subject.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ];
                    },
                    items: [
                      for (final subject in subjects)
                        DropdownMenuItem(
                          value: subject.id,
                          child: Text(
                            '${subject.title} (${coursesById[subject.courseId]?.title ?? 'Supported'})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _subjectId = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of MCQs',
                      hintText: 'Example: 10, 25, 50',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _positiveNumber,
                  ),
                  const SizedBox(height: 18),
                  _SaveButton(
                    isSaving: _isImporting,
                    label: 'Import Online MCQs',
                    onPressed: () => _import(selectedSubjectId, subjects),
                  ),
                  if (_lastImportedQuestions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showImportedQuestions(
                        context,
                        _lastImportedQuestions,
                        _lastImportedSubjectTitle ?? 'Imported MCQs',
                      ),
                      icon: const Icon(Icons.visibility_rounded),
                      label: const Text('View Imported MCQs'),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _import(
    String subjectId,
    List<QuizSubject> subjects,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final subject = subjects.firstWhere((item) => item.id == subjectId);
    final courses = await FirestoreService.instance.coursesStream().first;
    final course = courses.firstWhere((item) => item.id == subject.courseId);

    setState(() => _isImporting = true);
    try {
      final result =
          await FirestoreService.instance.importSubjectQuestionBankFromTriviaApi(
        subject: subject,
        course: course,
        totalQuestions: int.parse(_amountController.text.trim()),
        duration: 30,
      );
      _subjectId = subjectId;
      _lastImportedQuestions = result.importedQuestions;
      _lastImportedSubjectTitle = subject.title;
      if (!mounted) return;
      _showMessage(
        context,
        result.count == 0
            ? 'No new MCQs were imported. They may already exist or the API returned no matching questions.'
            : 'Imported ${result.count} online MCQs.',
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(context, 'Could not import online MCQs: $error');
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _showImportedQuestions(
    BuildContext context,
    List<QuizQuestion> questions,
    String subjectTitle,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$subjectTitle Imported MCQs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  const Text('These are the MCQs imported in your most recent fetch.'),
                  const SizedBox(height: 14),
                  Expanded(
                    child: questions.isEmpty
                        ? const EmptyState(
                            icon: Icons.help_outline_rounded,
                            title: 'No imported MCQs yet',
                            message: 'Import some questions first to review them here.',
                          )
                        : ListView.separated(
                            itemCount: questions.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final question = questions[index];
                              return Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  title: Text(question.questionText),
                                  subtitle: Text(
                                    'Difficulty: ${question.difficulty[0].toUpperCase()}${question.difficulty.substring(1)}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddQuestionForm extends StatefulWidget {
  const _AddQuestionForm();

  @override
  State<_AddQuestionForm> createState() => _AddQuestionFormState();
}

class _AddQuestionFormState extends State<_AddQuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  final _correctController = TextEditingController();
  final _explanationController = TextEditingController();
  String? _quizId;
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    _correctController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Quiz>>(
      stream: FirestoreService.instance.allQuizzesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _InlineState(child: ErrorState(error: snapshot.error));
        }
        if (!snapshot.hasData) {
          return const _InlineState(child: LoadingState());
        }

        final quizzes = snapshot.data!;
        if (quizzes.isEmpty) {
          return const _InlineState(
            child: EmptyState(
              icon: Icons.quiz_outlined,
              title: 'Add a quiz first',
              message: 'Questions need to belong to a quiz.',
            ),
          );
        }

        final selectedQuizId = _safeSelectedId(_quizId, quizzes);

        return Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedQuizId,
                decoration: const InputDecoration(labelText: 'Quiz'),
                items: [
                  for (final quiz in quizzes)
                    DropdownMenuItem(
                      value: quiz.id,
                      child: Text(quiz.title),
                    ),
                ],
                onChanged: (value) => setState(() => _quizId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Question'),
                minLines: 2,
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _optionControllers.length; i++) ...[
                TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _correctController,
                decoration: const InputDecoration(
                  labelText: 'Correct answer',
                  hintText: 'Type the exact option text or 0-based index',
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _explanationController,
                decoration: const InputDecoration(labelText: 'Explanation'),
                minLines: 2,
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 18),
              _SaveButton(
                isSaving: _isSaving,
                label: 'Add Question',
                onPressed: () => _save(selectedQuizId),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(String quizId) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addQuestion(
        quizId: quizId,
        questionText: _questionController.text,
        options: options,
        correctAnswer: _correctController.text,
        explanation: _explanationController.text,
      );
      _quizId = quizId;
      _questionController.clear();
      for (final controller in _optionControllers) {
        controller.clear();
      }
      _correctController.clear();
      _explanationController.clear();
      if (mounted) _showMessage(context, 'Question added.');
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not add question: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _QuestionBankSummaryPanel extends StatefulWidget {
  const _QuestionBankSummaryPanel();

  @override
  State<_QuestionBankSummaryPanel> createState() => _QuestionBankSummaryPanelState();
}

class _QuestionBankSummaryPanelState extends State<_QuestionBankSummaryPanel> {
  String? _subjectId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<QuizSubject>>(
      stream: FirestoreService.instance.allSubjectsStream(),
      builder: (context, subjectSnapshot) {
        if (subjectSnapshot.hasError) {
          return _InlineState(child: ErrorState(error: subjectSnapshot.error));
        }
        if (!subjectSnapshot.hasData) {
          return const _InlineState(child: LoadingState());
        }

        final subjects = subjectSnapshot.data!;
        if (subjects.isEmpty) {
          return const _InlineState(
            child: EmptyState(
              icon: Icons.topic_outlined,
              title: 'No subjects yet',
              message: 'Add a subject first to review quiz bank statistics.',
            ),
          );
        }

        final selectedSubjectId = _safeSelectedId(_subjectId, subjects);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedSubjectId,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: [
                for (final subject in subjects)
                  DropdownMenuItem(
                    value: subject.id,
                    child: Text(subject.title),
                  ),
              ],
              onChanged: (value) => setState(() => _subjectId = value),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<Quiz>>(
              stream: FirestoreService.instance.quizzesForSubject(selectedSubjectId),
              builder: (context, quizSnapshot) {
                if (quizSnapshot.hasError) {
                  return _InlineState(child: ErrorState(error: quizSnapshot.error));
                }
                if (!quizSnapshot.hasData) {
                  return const _InlineState(child: LoadingState());
                }

                final quizzes = quizSnapshot.data!;
                if (quizzes.isEmpty) {
                  return const _InlineState(
                    child: EmptyState(
                      icon: Icons.quiz_outlined,
                      title: 'No quizzes yet',
                      message: 'Create a quiz or import a question bank first.',
                    ),
                  );
                }

                final quiz = quizzes.firstWhere(
                  (item) => item.title.toLowerCase().contains('question bank'),
                  orElse: () => quizzes.first,
                );

                return StreamBuilder<List<QuizQuestion>>(
                  stream: FirestoreService.instance.questionsForQuiz(quiz.id),
                  builder: (context, questionSnapshot) {
                    if (questionSnapshot.hasError) {
                      return _InlineState(child: ErrorState(error: questionSnapshot.error));
                    }
                    if (!questionSnapshot.hasData) {
                      return const _InlineState(child: LoadingState());
                    }

                    final questions = questionSnapshot.data!;
                    final easy = questions.where((item) => item.difficulty == 'easy').length;
                    final medium = questions.where((item) => item.difficulty == 'medium').length;
                    final hard = questions.where((item) => item.difficulty == 'hard').length;
                    final manual = questions.where((item) => item.source == 'manual').length;
                    final sample = questions.where((item) => item.source == 'sample').length;
                    final internet = questions.where((item) => item.source == 'internet').length;
                    final variants =
                        questions.where((item) => item.isPracticeVariant).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This summary shows the current question bank that learners will use for this subject.',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          quiz.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _MetricChip(label: 'Total ${questions.length}'),
                            _MetricChip(label: 'Easy $easy'),
                            _MetricChip(label: 'Medium $medium'),
                            _MetricChip(label: 'Hard $hard'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (manual > 0) _MetricChip(label: 'Manual $manual'),
                            if (sample > 0) _MetricChip(label: 'Sample $sample'),
                            if (internet > 0) _MetricChip(label: 'Internet $internet'),
                          ],
                        ),
                        if (variants > 0) ...[
                          const SizedBox(height: 10),
                          Text(
                            '$variants questions are marked as practice variants.',
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;

  const _MetricChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final String label;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isSaving,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_rounded),
        label: Text(label),
      ),
    );
  }
}

String _safeSelectedId<T extends Object>(String? selectedId, List<T> items) {
  String itemId(T item) {
    if (item is Course) return item.id;
    if (item is QuizSubject) return item.id;
    if (item is Quiz) return item.id;
    throw ArgumentError('Unsupported dropdown item type.');
  }

  if (selectedId != null && items.any((item) => itemId(item) == selectedId)) {
    return selectedId;
  }

  return itemId(items.first);
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required.';
  return null;
}

String? _positiveNumber(String? value) {
  final parsed = int.tryParse(value?.trim() ?? '');
  if (parsed == null || parsed <= 0) return 'Enter a positive number.';
  return null;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ),
  );
}
