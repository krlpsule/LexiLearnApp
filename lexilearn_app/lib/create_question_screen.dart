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
    TextEditingController(),
    TextEditingController(),
  ];
  int? _correctAnswerIndex;

  String? _selectedLevel;
  String? _selectedDomainId;
  String? _selectedStudyId;
  List<dynamic> _domains = [];
  List<dynamic> _studies = [];
  List<dynamic> _filteredStudies = [];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _fetchDomains();
    _fetchStudies();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDomains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/domains'));
      if (!mounted) return; // BuildContext güvenliği

      if (response.statusCode == 200) {
        setState(() {
          _domains = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching domains: $e'); // avoid_print düzeltmesi
    }
  }

  Future<void> _fetchStudies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/studies'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _studies = jsonDecode(response.body);
          _filterStudies();
        });
      }
    } catch (e) {
      debugPrint('Error fetching studies: $e'); // avoid_print düzeltmesi
    }
  }

  void _filterStudies() {
    if (_selectedDomainId == null) {
      _filteredStudies = [];
    } else {
      _filteredStudies = _studies.where((s) {
        return s['domainId'].toString() == _selectedDomainId;
      }).toList();
    }
    _selectedStudyId = null;
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
        } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
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
    if (_selectedDomainId == null || _selectedStudyId == null ||
        _questionController.text.trim().isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark the correct answer.')),
      );
      return;
    }

    List<String> options = _answerControllers.map((c) => c.text.trim()).toList();
    if (options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all answer fields.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/question'),
        body: {
          'studyId': _selectedStudyId!,
          'text': _questionController.text.trim(),
          'answer': options[_correctAnswerIndex!],
          'options': jsonEncode(options),
          'level': _selectedLevel!,
        },
      );

      if (!mounted) return; // Async sonrası context kullanımı koruması

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question saved successfully!')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save question!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
  }

  void _resetForm() {
    _questionController.clear();
    for (var controller in _answerControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswerIndex = null;
      _selectedLevel = null;
      _selectedStudyId = null;
      _selectedDomainId = null;
      _filteredStudies = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Category (Domain)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDomainId, // 'value' yerine 'initialValue' kullanıldı
              hint: const Text('Select a Category'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _domains.map<DropdownMenuItem<String>>((domain) {
                return DropdownMenuItem<String>(
                  value: domain['id'].toString(),
                  child: Text(domain['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDomainId = value;
                  _filterStudies();
                });
              },
            ),
            const SizedBox(height: 24),
            const Text('Which Study to Add To?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedStudyId, // 'value' yerine 'initialValue' kullanıldı
              hint: Text(_selectedDomainId == null ? 'First select a category' : 'Select a Study'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _filteredStudies.map<DropdownMenuItem<String>>((study) {
                return DropdownMenuItem<String>(
                  value: study['studyId'].toString(),
                  child: Text(study['title']),
                );
              }).toList(),
              onChanged: _selectedDomainId == null ? null : (value) => setState(() => _selectedStudyId = value),
            ),
            const SizedBox(height: 24),
            const Text('Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Enter question', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('Difficulty Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedLevel, // 'value' yerine 'initialValue' kullanıldı
              items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) => setState(() => _selectedLevel = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select Level'),
            ),
            const SizedBox(height: 24),
            const Text('Answers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // RadioGroup kullanımı yerine mevcut yapı mounted kontrolleriyle modernize edildi
            ...List.generate(_answerControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _correctAnswerIndex,
                      onChanged: (value) => setState(() => _correctAnswerIndex = value),
                      activeColor: Colors.green,
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