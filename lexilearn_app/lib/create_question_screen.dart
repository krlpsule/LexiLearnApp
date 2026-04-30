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
  String? _selectedDomainId;  // YENİ
  String? _selectedStudyId;
  List<dynamic> _domains = [];  // YENİ
  List<dynamic> _studies = [];
  List<dynamic> _filteredStudies = [];  // YENİ

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _fetchDomains();  // YENİ — önce domainleri çek
    _fetchStudies();
  }

  // YENİ — Domain'leri çek
  Future<void> _fetchDomains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/domains'));
      if (response.statusCode == 200) {
        setState(() {
          _domains = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching domains: $e');
    }
  }

  Future<void> _fetchStudies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/studies'));
      if (response.statusCode == 200) {
        setState(() {
          _studies = jsonDecode(response.body);
          _filterStudies();  // YENİ
        });
      }
    } catch (e) {
      print('Error fetching studies: $e');
    }
  }

  // YENİ — Seçili Domain'e göre Study'leri filtrele
  void _filterStudies() {
    if (_selectedDomainId == null) {
      _filteredStudies = [];
    } else {
      _filteredStudies = _studies.where((s) {
        return s['domainId'].toString() == _selectedDomainId;
      }).toList();
    }
    _selectedStudyId = null;  // Domain değişince Study sıfırlansın
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
    if (_selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Domain first.')),
      );
      return;
    }
    if (_selectedStudyId == null ||
        _questionController.text.trim().isEmpty ||
        _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Study, Question Text, and Difficulty Level.'),
        ),
      );
      return;
    }
    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark the correct answer.')),
      );
      return;
    }

    List<String> options = [];
    for (var controller in _answerControllers) {
      if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all answer fields or remove empty options.'),
          ),
        );
        return;
      }
      options.add(controller.text.trim());
    }

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
          _selectedDomainId = null;
          _filteredStudies = [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save question!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e')),
      );
    }
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

            // ── 1. ÖNCE DOMAIN SEÇ (YENİ) ──
            const Text(
              'Select Category (Domain)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDomainId,
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
                  _filterStudies();  // Domain seçilince Study'leri filtrele
                });
              },
            ),
            const SizedBox(height: 24),

            // ── 2. SONRA STUDY SEÇ (filtrelenmiş) ──
            const Text(
              'Which Study to Add To?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStudyId,
              hint: const Text(_selectedDomainId == null
                  ? 'First select a category above'
                  : 'Select a Study'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _filteredStudies.map<DropdownMenuItem<String>>((study) {
                return DropdownMenuItem<String>(
                  value: study['studyId'].toString(),
                  child: Text(study['title']),
                );
              }).toList(),
              onChanged: _selectedDomainId == null
                  ? null
                  : (value) => setState(() => _selectedStudyId = value),
            ),
            const SizedBox(height: 24),

            // ── Soru Metni ──
            const Text(
              'Question',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter the question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Zorluk Seviyesi ──
            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: _levels
                  .map((level) =>
                      DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedLevel = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select Level'),
            ),
            const SizedBox(height: 24),

            // ── Cevaplar ──
            const Text(
              'Answers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Click the circle next to the correct answer',
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
                      onChanged: (value) =>
                          setState(() => _correctAnswerIndex = value),
                      activeColor: Colors.green,
                      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                        if (_correctAnswerIndex == index) return Colors.green;
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

            // ── Kaydet Butonu ──
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