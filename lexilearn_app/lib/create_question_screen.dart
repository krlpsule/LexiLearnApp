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
  String _selectedQuestionType =
      'multiple_choice'; // YENİ: Soru tipi varsayılan olarak çoktan seçmeli

  List<dynamic> _domains = [];
  List<dynamic> _studies = [];
  List<dynamic> _filteredStudies = [];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  // YENİ: Soru tipleri listesi
  final List<Map<String, String>> _questionTypes = [
    {'value': 'multiple_choice', 'label': 'Multiple Choice'},
    {'value': 'true_false', 'label': 'True / False'},
    {'value': 'fill_in_blank', 'label': 'Fill in the Blank'},
  ];

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
        String sDomainId = (s['domainId'] ?? s['domain_id'] ?? '').toString();
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
        const SnackBar(content: Text('There must be at least 2 options.')),
      );
    }
  }

  Future<void> _saveQuestion() async {
    if (_selectedDomainId == null || _selectedStudyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Category and Study.')),
      );
      return;
    }
    if (_questionController.text.trim().isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Question Text and Level.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String correctAnswer = "";
    List<String> options = [];

    // YENİ: Seçilen soru tipine göre veri paketleme mantığı
    if (_selectedQuestionType == 'multiple_choice') {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please mark the correct answer.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      for (var controller in _answerControllers) {
        if (controller.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all option fields.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        options.add(controller.text.trim());
      }
      correctAnswer = options[_correctAnswerIndex!];
    } else if (_selectedQuestionType == 'true_false') {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select True or False.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      options = ["True", "False"];
      correctAnswer = options[_correctAnswerIndex!];
    } else if (_selectedQuestionType == 'fill_in_blank') {
      if (_answerControllers[0].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the correct answer word/phrase.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      correctAnswer = _answerControllers[0].text.trim();
      options =
          []; // Boşluk doldurmada şık olmaz, o yüzden boş liste gönderiyoruz.
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/question'),
        body: {
          'studyId': _selectedStudyId!,
          'text': _questionController.text.trim(),
          'answer': correctAnswer,
          'options': jsonEncode(options),
          'level': _selectedLevel!,
          'questionType':
              _selectedQuestionType, // YENİ: Soru tipi backend'e gidiyor!
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
    for (var controller in _answerControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswerIndex = null;
      _selectedLevel = null;
      _selectedStudyId = null;
      // _selectedQuestionType varsayılan olarak kalsın, hoca peş peşe aynı tip soru girebilir
    });
  }

  // YENİ: Soru Tipine göre Arayüzü Çizen Akıllı Fonksiyon
  Widget _buildAnswerSection() {
    if (_selectedQuestionType == 'multiple_choice') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options',
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
                      return Colors.grey.shade400;
                    }),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _answerControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Option ${index + 1}',
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
    } else if (_selectedQuestionType == 'true_false') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the Correct Answer:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Radio<int>(
                value: 0,
                groupValue: _correctAnswerIndex,
                onChanged: (value) =>
                    setState(() => _correctAnswerIndex = value),
                activeColor: Colors.green,
              ),
              const Text('True', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 24),
              Radio<int>(
                value: 1,
                groupValue: _correctAnswerIndex,
                onChanged: (value) =>
                    setState(() => _correctAnswerIndex = value),
                activeColor: Colors.green,
              ),
              const Text('False', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      );
    } else if (_selectedQuestionType == 'fill_in_blank') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Correct Answer (Word/Phrase)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Students will need to type this exact word to pass.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          TextField(
            controller:
                _answerControllers[0], // Sadece ilk controller'ı kullanıyoruz
            decoration: const InputDecoration(
              hintText: 'e.g. Mitochondria',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

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
            // ── DOMAIN ──
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
              onChanged: (value) => setState(() {
                _selectedDomainId = value;
                _filterStudies();
              }),
            ),
            const SizedBox(height: 24),

            // ── STUDY ──
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
                String id = (study['studyId'] ?? study['study_id'] ?? '')
                    .toString();
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

            // ── YENİ: SORU TİPİ SEÇİMİ ──
            const Text(
              'Question Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedQuestionType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _questionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestionType = value!;
                  _correctAnswerIndex =
                      null; // Tip değişince seçili cevabı sıfırla
                });
              },
            ),
            const SizedBox(height: 24),

            // ── SORU METNİ ──
            const Text(
              'Question',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter question text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── ZORLUK SEVİYESİ ──
            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: _levels
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedLevel = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Select Level'),
            ),
            const SizedBox(height: 24),

            // ── AKILLI CEVAP ALANI (Tipe göre değişir) ──
            _buildAnswerSection(),
            const SizedBox(height: 32),

            // ── KAYDET BUTONU ──
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
