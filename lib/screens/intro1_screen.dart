import 'package:flutter/material.dart';
import 'intro2_screen.dart';
import 'login_screen.dart';
import 'intro_widgets.dart';

class Intro1Screen extends StatelessWidget {
  const Intro1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE4),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Skip"),
              ),
            ),
            const Spacer(),
            const Text(
              "Welcome to QUIZLET",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create and play interactive quizzes easily.",
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Dots(activeIndex: 0),
                NextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const Intro2Screen()),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}