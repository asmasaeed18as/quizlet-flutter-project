import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'intro2_screen.dart';
import 'intro_widgets.dart';
import 'login_screen.dart';

class Intro1Screen extends StatefulWidget {
  const Intro1Screen({super.key});

  @override
  State<Intro1Screen> createState() => _Intro1ScreenState();
}

class _Intro1ScreenState extends State<Intro1Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingLayout(
      activeIndex: 0,
      imagePath: 'assets/images/login_bg.png',
      title: 'Welcome to Quizlet',
      subtitle: 'Create and play interactive quizzes with a polished learning experience.',
      onSkip: () => _goToLogin(context),
      onNext: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Intro2Screen()),
        );
      },
      fadeAnimation: _fadeAnimation,
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class _OnboardingLayout extends StatelessWidget {
  final int activeIndex;
  final String imagePath;
  final String title;
  final String subtitle;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final Animation<double> fadeAnimation;

  const _OnboardingLayout({
    required this.activeIndex,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.onSkip,
    required this.onNext,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(onPressed: onSkip, child: const Text('Skip')),
                      ),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: Image.asset(imagePath, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Dots(activeIndex: activeIndex),
                          NextButton(onPressed: onNext),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
