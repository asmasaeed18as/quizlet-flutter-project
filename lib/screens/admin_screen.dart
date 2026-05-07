import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/quiz.dart';
import '../models/quiz_subject.dart';
import '../services/firestore_service.dart';
import '../widgets/app_background.dart';
import '../widgets/async_state.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      const _SeedSampleDataButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Admin', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Use this page to add courses, subjects, quizzes, questions, or seed sample Firestore data.',
                  ),
                  const SizedBox(height: 14),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_done_rounded),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Need ready-made data? Tap "Seed Sample Data" at the top right.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Course'),
                      Tab(text: 'Subject'),
                      Tab(text: 'Quiz'),
                      Tab(text: 'Question'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        _AddCourseForm(),
                        _AddSubjectForm(),
                        _AddQuizForm(),
                        _AddQuestionForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeedSampleDataButton extends StatefulWidget {
  const _SeedSampleDataButton();

  @override
  State<_SeedSampleDataButton> createState() => _SeedSampleDataButtonState();
}

class _SeedSampleDataButtonState extends State<_SeedSampleDataButton> {
  bool _isSeeding = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSeeding ? null : _seed,
      icon: _isSeeding
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload_rounded),
      label: const Text('Seed Sample Data'),
    );
  }

  Future<void> _seed() async {
    setState(() => _isSeeding = true);
    try {
      await FirestoreService.instance.seedSampleData();
      if (mounted) {
        _showMessage(context, 'Sample Firestore data added successfully.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Could not seed sample data: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isSeeding = false);
      }
    }
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
    return _AdminCard(
      child: Form(
        key: _formKey,
        child: ListView(
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
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Course'),
            ),
          ],
        ),
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
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (!snapshot.hasData) return const LoadingState();
        final courses = snapshot.data!;
        if (courses.isEmpty) {
          return const EmptyState(
            icon: Icons.school_outlined,
            title: 'Add a course first',
            message: 'Subjects need to belong to a course.',
          );
        }

        _courseId ??= courses.first.id;

        return _AdminCard(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _courseId,
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
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Subject'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _courseId == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addSubject(
        courseId: _courseId!,
        title: _titleController.text,
      );
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
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (!snapshot.hasData) return const LoadingState();
        final subjects = snapshot.data!;
        if (subjects.isEmpty) {
          return const EmptyState(
            icon: Icons.topic_outlined,
            title: 'Add a subject first',
            message: 'Quizzes need to belong to a subject.',
          );
        }

        _subjectId ??= subjects.first.id;

        return _AdminCard(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _subjectId,
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
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Quiz'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _subjectId == null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addQuiz(
        subjectId: _subjectId!,
        title: _titleController.text,
        totalQuestions: int.parse(_totalController.text.trim()),
        duration: int.parse(_durationController.text.trim()),
      );
      _titleController.clear();
      if (mounted) _showMessage(context, 'Quiz added.');
    } catch (error) {
      if (mounted) _showMessage(context, 'Could not add quiz: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (!snapshot.hasData) return const LoadingState();
        final quizzes = snapshot.data!;
        if (quizzes.isEmpty) {
          return const EmptyState(
            icon: Icons.quiz_outlined,
            title: 'Add a quiz first',
            message: 'Questions need to belong to a quiz.',
          );
        }

        _quizId ??= quizzes.first.id;

        return _AdminCard(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _quizId,
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
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Question'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _quizId == null) {
      return;
    }

    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((option) => option.isNotEmpty)
        .toList();

    setState(() => _isSaving = true);
    try {
      await FirestoreService.instance.addQuestion(
        quizId: _quizId!,
        questionText: _questionController.text,
        options: options,
        correctAnswer: _correctController.text,
        explanation: _explanationController.text,
      );
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

class _AdminCard extends StatelessWidget {
  final Widget child;

  const _AdminCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
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
