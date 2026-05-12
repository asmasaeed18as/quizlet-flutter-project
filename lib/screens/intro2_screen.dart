import 'package:flutter/material.dart';
import '../services/app_launch_service.dart';
import 'intro3_screen.dart';
import 'intro_widgets.dart';
import 'login_screen.dart';

class Intro2Screen extends StatelessWidget {
  const Intro2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreenShell(
      activeIndex: 1,
      imagePath: 'assets/images/challenge.png',
      eyebrow: 'Stay motivated',
      title: 'The Ultimate Challenge',
      subtitle:
          'Take focused quizzes, beat your previous score, and build a habit of learning every day.',
      highlights: const [
        'Pick custom MCQ counts based on your practice goals',
        'Adjust timer and difficulty for easy, medium, or hard practice',
        'Resume attempts with saved quiz progress when you come back',
      ],
      onSkip: () async {
        await AppLaunchService.markOnboardingSeen();
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      onNext: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Intro3Screen()),
        );
      },
    );
  }
}
