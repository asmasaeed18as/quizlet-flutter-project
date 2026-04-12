import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'intro1_screen.dart';

class Frame252Screen extends StatelessWidget {
  const Frame252Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Intro1Screen()),
          );
        },
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/image1.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'LLM Based Quiz Generator',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap to continue',
                      style: TextStyle(color: Color(0xFF4A5568)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
