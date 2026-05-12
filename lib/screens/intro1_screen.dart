import 'package:flutter/material.dart';
import '../services/app_launch_service.dart';
import 'intro2_screen.dart';
import 'intro_widgets.dart';
import 'login_screen.dart';

class Intro1Screen extends StatelessWidget {
  const Intro1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreenShell(
      activeIndex: 0,
      imagePath: 'assets/images/login_bg.png',
      eyebrow: 'Smart learning',
      title: 'Welcome to Quizlet',
      subtitle:
          'Create, explore, and attempt interactive quizzes with a smooth learning experience built for students.',
      highlights: const [
        'Browse courses and subjects in a clean, guided flow',
        'Start with a polished quiz interface and real-time progress',
        'Designed for both quick practice and focused study sessions',
      ],
      onSkip: () => _goToLogin(context),
      onNext: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Intro2Screen()),
        );
      },
    );
  }

  Future<void> _goToLogin(BuildContext context) async {
    await AppLaunchService.markOnboardingSeen();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
