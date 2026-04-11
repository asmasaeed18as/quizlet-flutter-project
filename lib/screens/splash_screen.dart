import 'package:flutter/material.dart';
import 'intro1_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE4),
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Intro1Screen()),
          );
        },
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz, size: 80, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                "QUIZLET",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text("Tap to Continue"),
            ],
          ),
        ),
      ),
    );
  }
}