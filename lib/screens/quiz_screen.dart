import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const LinearProgressIndicator(value: 0.5),
            const SizedBox(height: 20),
            const Text("What is 5 + 5?", style: TextStyle(fontSize: 18)),
            RadioGroup<int>(
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(selected == 0 ? 12 : 8),
                    decoration: BoxDecoration(
                      color: selected == 0
                          ? Colors.deepPurple.shade50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<int>(value: 0, title: const Text("8")),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(selected == 1 ? 12 : 8),
                    decoration: BoxDecoration(
                      color: selected == 1
                          ? Colors.deepPurple.shade50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<int>(
                      value: 1,
                      title: const Text("10"),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                final screenContext = context;
                showDialog(
                  context: screenContext,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Quiz Submitted'),
                    content: const Text('Your answer has been submitted.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pop(screenContext);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
