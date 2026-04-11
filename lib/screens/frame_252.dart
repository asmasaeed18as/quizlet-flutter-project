// lib/screens/frame_252.dart
import 'package:flutter/material.dart';
import 'intro1_screen.dart';

class Frame252Screen extends StatelessWidget {
  const Frame252Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5EDE4);

    return Scaffold(
      backgroundColor: background,
      body: GestureDetector(
        onTap: () {
          // Tap anywhere → go to Intro1
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Intro1Screen()),
          );
        },
        child: const SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo placeholder – replace with Image.asset later
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.redAccent,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'LLM BASED QUIZ GENERATOR',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Tap to continue',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}