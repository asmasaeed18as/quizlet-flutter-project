import 'package:flutter/material.dart';
import '../services/app_launch_service.dart';
import 'intro_widgets.dart';
import 'login_screen.dart';

class Intro3Screen extends StatelessWidget {
  const Intro3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreenShell(
      activeIndex: 2,
      imagePath: 'assets/images/quiz_paper.png',
      eyebrow: 'Track your growth',
      title: 'Test Your Knowledge',
      subtitle:
          'Get instant feedback, review your answers, climb the leaderboard, and keep improving in every category.',
      highlights: const [
        'See score summaries, explanations, and answer review after each quiz',
        'Track streaks, total score, bookmarks, and recent attempts',
        'Compete through global and course-wise leaderboards',
      ],
      onSkip: () async {
        await AppLaunchService.markOnboardingSeen();
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      onNext: () async {
        await AppLaunchService.markOnboardingSeen();
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      isFinal: true,
    );
  }
}
