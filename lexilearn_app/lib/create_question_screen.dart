import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  String? _selectedLevel;
  String? _selectedStudyId;
  List<dynamic> _studies = [];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _fetchStudies();
  }

  Future<void> _fetchStudies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/studies'));
      if (response.statusCode == 200) {
        setState(() {
          _studies = jsonDecode(response.body);
          if (_selectedStudyId != null &&
              !_studies.any(
                (s) => s['studyId'].toString() == _selectedStudyId,
              )) {
            _selectedStudyId = null;
          }
        });
      }
    } catch (e) {
      print('Error fetching studies: $e');
    }
  }

  void _addAnswer() {
    if (_answerControllers.length < 6) {
      setState(() {
        _answerControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 6 options.')),
      );
    }
  }

  void _removeAnswer(int index) {
    if (_answerControllers.length > 2) {
      setState(() {
        _answerControllers.removeAt(index);
        if (_correctAnswerIndex == index) {
          _correctAnswerIndex = null;
        } else if (_correctAnswerIndex != null &&
            _correctAnswerIndex! > index) {
          _correctAnswerIndex = _correctAnswerIndex! - 1;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There must be at least 2 options.')),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (_selectedStudyId == null ||
        _questionController.text.trim().isEmpty ||
        _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(content: Text('Please enter a question')),
=======
        const SnackBar(
          content: Text(
            'Please select a Study, Question Text, and Difficulty Level.',
          ),
        ),
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
      );
      return;
    }
    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(content: Text('Please select the correct answer')),
=======
        const SnackBar(content: Text('Please mark the correct answer.')),
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
      );
      return;
    }

    List<String> options = [];
    for (var controller in _answerControllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
          const SnackBar(content: Text('Please fill in all answer fields')),
=======
          const SnackBar(
            content: Text(
              'Please fill in all answer fields or remove empty options.',
            ),
          ),
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
        );
        return;
      }
      options.add(controller.text.trim());
    }

<<<<<<< HEAD
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Question saved! Correct answer: ${_answerControllers[_correctAnswerIndex!].text}',
        ),
      ),
    );
=======
    String correctAnswer = options[_correctAnswerIndex!];
    String optionsJson = jsonEncode(options);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/question'),
        body: {
          'studyId': _selectedStudyId!,
          'text': _questionController.text.trim(),
          'answer': correctAnswer,
          'options': optionsJson,
          'level': _selectedLevel!,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question saved successfully!')),
        );

        _questionController.clear();
        for (var controller in _answerControllers) {
          controller.clear();
        }
        setState(() {
          _correctAnswerIndex = null;
          _selectedLevel = null;
          _selectedStudyId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save question!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
    }
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Create Question'),
      ),
=======
      appBar: AppBar(title: const Text('Create Question')),
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            const Text('Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
=======
            const Text(
              'Which Study to Add To?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStudyId,
              items: _studies.map<DropdownMenuItem<String>>((study) {
                return DropdownMenuItem<String>(
                  value: study['studyId'].toString(),
                  child: Text(study['title']),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedStudyId = value),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select a Study'),
            ),
            const SizedBox(height: 24),

            const Text(
              'Question',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
<<<<<<< HEAD
                hintText: 'Enter your question',
=======
                hintText: 'Enter the question',
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
<<<<<<< HEAD
            const Text('Answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'Click the circle to select the correct answer',
=======

            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: _levels
                  .map(
                    (level) =>
                        DropdownMenuItem(value: level, child: Text(level)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedLevel = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select Level'),
            ),
            const SizedBox(height: 24),

            const Text(
              'Answers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Click the circle next to the correct answer',
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
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
<<<<<<< HEAD
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
=======
                      onChanged: (value) =>
                          setState(() => _correctAnswerIndex = value),
                      activeColor: Colors.green,
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (_correctAnswerIndex == index) return Colors.green;
>>>>>>> 4475f0a0a692013d0cac4d3d25056c9c89dee2d9
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
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
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
