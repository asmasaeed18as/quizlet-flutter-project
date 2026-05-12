import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingScreenShell extends StatelessWidget {
  final int activeIndex;
  final String imagePath;
  final String eyebrow;
  final String title;
  final String subtitle;
  final List<String> highlights;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final bool isFinal;

  const OnboardingScreenShell({
    super.key,
    required this.activeIndex,
    required this.imagePath,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.highlights,
    required this.onSkip,
    required this.onNext,
    this.isFinal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.screenGradient),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              right: -70,
              child: _GlowCircle(size: 220, color: Color(0x3300B4D8)),
            ),
            const Positioned(
              left: -70,
              bottom: 80,
              child: _GlowCircle(size: 180, color: Color(0x22FFC857)),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 34,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Dots(activeIndex: activeIndex)),
                                TextButton(
                                  onPressed: onSkip,
                                  child: const Text('Skip'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _HeroCard(
                              imagePath: imagePath,
                              eyebrow: eyebrow,
                              activeIndex: activeIndex,
                            ),
                            const SizedBox(height: 26),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4A5568),
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ...highlights.map(
                              (highlight) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _HighlightTile(label: highlight),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Dots(activeIndex: activeIndex),
                                const Spacer(),
                                NextButton(
                                  onPressed: onNext,
                                  isFinal: isFinal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dots extends StatelessWidget {
  final int activeIndex;

  const Dots({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = activeIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : const Color(0xFFD1D9EA),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isFinal;

  const NextButton({super.key, required this.onPressed, this.isFinal = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(122, 54),
          maximumSize: const Size(122, 54),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: Icon(
          isFinal ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
        ),
        label: Text(isFinal ? 'Start' : 'Next'),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String imagePath;
  final String eyebrow;
  final int activeIndex;

  const _HeroCard({
    required this.imagePath,
    required this.eyebrow,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = [
      const [Color(0xFF5F4BFF), Color(0xFF2AC5FF)],
      const [Color(0xFF2D6A4F), Color(0xFF52B788)],
      const [Color(0xFF4361EE), Color(0xFF4CC9F0)],
    ];

    final colors = gradients[activeIndex.clamp(0, gradients.length - 1)];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x220B1B3F),
              blurRadius: 24,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                eyebrow,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                color: Colors.white.withValues(alpha: 0.14),
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightTile extends StatelessWidget {
  final String label;

  const _HighlightTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E9F4)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0x145F4BFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
