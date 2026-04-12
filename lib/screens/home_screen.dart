import 'package:flutter/material.dart';
import 'quiz_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.deepPurple,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(context, "Math"),
          _buildCard(context, "Science"),
          _buildCard(context, "History"),
          _buildCard(context, "English"),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizListScreen(category: title)),
          );
        },
        child: Center(
          child: Hero(
            tag: title,
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
