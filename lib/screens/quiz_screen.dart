import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int selected = -1;

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
            const Text(
              "What is 5 + 5?",
              style: TextStyle(fontSize: 18),
            ),
            RadioListTile(
              value: 0,
              groupValue: selected,
              onChanged: (value) {
                setState(() => selected = value!);
              },
              title: const Text("8"),
            ),
            RadioListTile(
              value: 1,
              groupValue: selected,
              onChanged: (value) {
                setState(() => selected = value!);
              },
              title: const Text("10"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}