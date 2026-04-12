import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatefulWidget {
  final String category;

  const QuizListScreen({super.key, required this.category});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = ["Algebra Test", "Physics Quiz", "Grammar Test"];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: widget.category,
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Quizzes'),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _slideAnimation,
            child: ListTile(
              leading: const Icon(Icons.quiz),
              title: Text(quizzes[index]),
              trailing: ElevatedButton(
                child: const Text("Start"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuizScreen()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
