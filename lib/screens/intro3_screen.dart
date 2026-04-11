import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'intro_widgets.dart'; // Dots & NextButton

class Intro3Screen extends StatelessWidget {
  const Intro3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5EDE4);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Skip Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // Image placeholder
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Quiz paper image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Test Your Knowledge\nWith QUIZLET',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Quizlet is the best app to challenge\nyourself and your friends.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Dots(activeIndex: 2),

                  NextButton(
                    onPressed: () {
                      // FINAL → Go to Login Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}