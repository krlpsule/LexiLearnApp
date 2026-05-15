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

  // Multiple Choice için
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int? _correctAnswerIndex;

  // True/False için
  String? _trueFalseAnswer; // 'true' veya 'false'

  // Fill in the Blank için
  final TextEditingController _fillAnswerController = TextEditingController();

  // Seçilen soru tipi
  String _questionType = 'multiple_choice';

  String? _selectedDomainId;
  String? _selectedStudyId;
  List<dynamic> _domains = [];
  List<dynamic> _studies = [];
  List<dynamic> _filteredStudies = [];

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
    _fillAnswerController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchDomains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/domains'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _domains = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching domains: $e');
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
      debugPrint('Error fetching studies: $e');
    }
  }

  void _filterStudies() {
    if (_selectedDomainId == null) {
      _filteredStudies = [];
    } else {
      _filteredStudies = _studies.where((s) {
        String sDomainId =
            (s['domainId'] ?? s['domain_id'] ?? '').toString();
        return sDomainId == _selectedDomainId;
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
        } else if (_correctAnswerIndex != null &&
            _correctAnswerIndex! > index) {
          _correctAnswerIndex = _correctAnswerIndex! - 1;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There must be at least 2 options.'),
        ),
      );
    }
  }

  Future<void> _saveQuestion() async {
    // ── Ortak validasyonlar ──
    if (_selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Domain first.')),
      );
      return;
    }
    if (_selectedStudyId == null || _questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a Study and enter the Question Text.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String answer = '';
    String options = '[]';

    // ── Soru tipine göre validasyon ve veri hazırlama ──
    if (_questionType == 'multiple_choice') {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please mark the correct answer by tapping a circle.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      List<String> optionList = [];
      for (var controller in _answerControllers) {
        if (controller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please fill in all answer fields or remove empty options.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        optionList.add(controller.text.trim());
      }

      answer = optionList[_correctAnswerIndex!];
      options = jsonEncode(optionList);
    } else if (_questionType == 'true_false') {
      if (_trueFalseAnswer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select True or False as the correct answer.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      answer = _trueFalseAnswer!;
      options = jsonEncode(['true', 'false']);
    } else if (_questionType == 'fill_in_blank') {
      if (_fillAnswerController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the correct answer for the blank.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      answer = _fillAnswerController.text.trim();
      options = jsonEncode([]);
    }

    // ── Backend'e gönder ──
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/question'),
        body: {
          'studyId': _selectedStudyId!,
          'text': _questionController.text.trim(),
          'answer': answer,
          'options': options,
          'questionType': _questionType, // ← YENİ ALAN
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question saved successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save question! Error: ${response.statusCode}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    _questionController.clear();
    _fillAnswerController.clear();
    for (var controller in _answerControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswerIndex = null;
      _trueFalseAnswer = null;
      _selectedStudyId = null;
      _questionType = 'multiple_choice';
    });
  }

  // ──────────────────────────────────────────────────
  // True/False formu
  // ──────────────────────────────────────────────────
  Widget _buildTrueFalseForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _trueFalseAnswer = 'true'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _trueFalseAnswer == 'true'
                        ? Colors.green
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade400,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _trueFalseAnswer == 'true'
                            ? Colors.white
                            : Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'True',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _trueFalseAnswer == 'true'
                              ? Colors.white
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _trueFalseAnswer = 'false'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _trueFalseAnswer == 'false'
                        ? Colors.red
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.shade400,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel,
                        color: _trueFalseAnswer == 'false'
                            ? Colors.white
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'False',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _trueFalseAnswer == 'false'
                              ? Colors.white
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // Fill in the Blank formu
  // ──────────────────────────────────────────────────
  Widget _buildFillInBlankForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Correct Answer (what goes in the blank)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _fillAnswerController,
          decoration: InputDecoration(
            hintText: 'e.g. "Paris" or "photosynthesis"',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tip: Use ___ in your question text to show where the blank is.\nExample: "The capital of France is ___."',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // Multiple Choice formu (mevcut)
  // ──────────────────────────────────────────────────
  Widget _buildMultipleChoiceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Answers',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    return Colors.grey.shade400;
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
          label: const Text('Add Another Option'),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────
  // Ana build
  // ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Question'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Domain seçimi ──
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
                String id =
                    (domain['domainId'] ??
                            domain['domain_id'] ??
                            domain['id'] ??
                            '')
                        .toString();
                String name =
                    (domain['domainName'] ??
                            domain['domain_name'] ??
                            domain['name'] ??
                            'Unknown')
                        .toString();
                return DropdownMenuItem<String>(
                  value: id.isNotEmpty ? id : null,
                  child: Text(name),
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

            // ── Study seçimi ──
            const Text(
              'Which Study to Add To?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStudyId,
              hint: Text(
                _selectedDomainId == null
                    ? 'First select a category above'
                    : 'Select a Study',
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _filteredStudies.map<DropdownMenuItem<String>>((study) {
                String id =
                    (study['studyId'] ?? study['study_id'] ?? '').toString();
                String title =
                    (study['title'] ?? study['name'] ?? 'Unknown Study')
                        .toString();
                return DropdownMenuItem<String>(
                  value: id.isNotEmpty ? id : null,
                  child: Text(title),
                );
              }).toList(),
              onChanged: _selectedDomainId == null
                  ? null
                  : (value) => setState(() => _selectedStudyId = value),
            ),
            const SizedBox(height: 24),

            // ── Soru Tipi seçimi ──
            const Text(
              'Question Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _questionType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                  value: 'multiple_choice',
                  child: Row(
                    children: [
                      Icon(Icons.list, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Multiple Choice'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'true_false',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green),
                      SizedBox(width: 8),
                      Text('True / False'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'fill_in_blank',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Fill in the Blank'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _questionType = value!;
                  // Tip değişince cevap seçimlerini sıfırla
                  _correctAnswerIndex = null;
                  _trueFalseAnswer = null;
                  _fillAnswerController.clear();
                });
              },
            ),
            const SizedBox(height: 24),

            // ── Soru metni ──
            const Text(
              'Question',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _questionType == 'fill_in_blank'
                    ? 'e.g. "The capital of France is ___."'
                    : 'Enter question',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Soru tipine göre form ──
            if (_questionType == 'multiple_choice') _buildMultipleChoiceForm(),
            if (_questionType == 'true_false') _buildTrueFalseForm(),
            if (_questionType == 'fill_in_blank') _buildFillInBlankForm(),

            const SizedBox(height: 32),

            // ── Kaydet butonu ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveQuestion,
                child: const Text(
                  'Save Question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}