import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = ["Algebra Test", "Physics Quiz", "Grammar Test"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Quizzes"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.quiz),
            title: Text(quizzes[index]),
            trailing: ElevatedButton(
              child: const Text("Start"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuizScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}