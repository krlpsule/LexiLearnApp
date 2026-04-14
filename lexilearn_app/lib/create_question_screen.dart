import 'package:flutter/material.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int? _correctAnswerIndex;

  void _addAnswer() {
    if (_answerControllers.length < 6) {
      setState(() {
        _answerControllers.add(TextEditingController());
      });
    }
  }

  void _removeAnswer(int index) {
    if (_answerControllers.length > 2) {
      setState(() {
        _answerControllers.removeAt(index);
        if (_correctAnswerIndex == index) {
          _correctAnswerIndex = null;
        } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
          _correctAnswerIndex = _correctAnswerIndex! - 1;
        }
      });
    }
  }

  void _saveQuestion() {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }
    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the correct answer')),
      );
      return;
    }
    for (var controller in _answerControllers) {
      if (controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all answer fields')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Question saved! Correct answer: ${_answerControllers[_correctAnswerIndex!].text}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Click the circle to select the correct answer',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...List.generate(_answerControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _correctAnswerIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswerIndex = value;
                        });
                      },
                      activeColor: Colors.green,
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (_correctAnswerIndex == index) {
                          return Colors.green;
                        }
                        return Colors.red;
                      }),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _answerControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Answer ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeAnswer(index),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addAnswer,
              icon: const Icon(Icons.add),
              label: const Text('Add Answer'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}