import 'package:flutter/material.dart';

class Dots extends StatelessWidget {
  final int activeIndex;
  const Dots({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: activeIndex == index ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: activeIndex == index
                ? Colors.deepPurple
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.all(18),
      ),
      child: const Icon(Icons.arrow_forward, color: Colors.white),
    );
  }
}