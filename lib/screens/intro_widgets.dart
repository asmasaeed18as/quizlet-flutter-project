import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Dots extends StatelessWidget {
  final int activeIndex;

  const Dots({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = activeIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 22 : 8,
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(54, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Icon(isFinal ? Icons.check_rounded : Icons.arrow_forward_rounded),
    );
  }
}
