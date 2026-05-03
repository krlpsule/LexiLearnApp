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

  // Arkadaşının eklediği: Bellek sızıntısını önlemek için controller'ları temizliyoruz
  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Domain'leri çek
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

  // Study'leri çek
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

  // Seçili Domain'e göre Study'leri filtrele (Null Safety eklendi)
  void _filterStudies() {
    if (_selectedDomainId == null) {
      _filteredStudies = [];
    } else {
      _filteredStudies = _studies.where((s) {
        String sDomainId = (s['domainId'] ?? s['domain_id'] ?? '').toString();
        return sDomainId == _selectedDomainId;
      }).toList();
    }
    _selectedStudyId = null; // Domain değişince Study sıfırlansın
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
          content: Text(
            'Please select a Study, Question Text, and Difficulty Level.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark the correct answer by tapping a circle.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Senin yazdığın detaylı kontrol mekanizması (Kullanıcıya tam nerenin boş olduğunu söyler)
    List<String> options = [];
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
      options.add(controller.text.trim());
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

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question saved successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm(); // Arkadaşının eklediği reset metodu çağrıldı
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

  // Arkadaşının eklediği reset metodu. SENİN UX tasarımına göre modifiye edildi:
  // Domain'i bilerek sıfırlamıyoruz ki hoca aynı konuya hızlıca 2. soruyu yazabilsin!
  void _resetForm() {
    _questionController.clear();
    for (var controller in _answerControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswerIndex = null;
      _selectedLevel = null;
      _selectedStudyId = null;
      // _selectedDomainId = null; // Yoruma alındı: Domain seçili kalmaya devam etsin.
      // _filteredStudies = [];    // Yoruma alındı: Study'ler listede kalmaya devam etsin.
    });
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
            // ── 1. ÖNCE DOMAIN SEÇ ──
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

            // ── 2. SONRA STUDY SEÇ ──
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
                hintText: 'Enter question',
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
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
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
                      // Senin UX iyileştirmen: Seçili olmayanlar gri
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
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
            const SizedBox(height: 24),

            // ── Kaydet Butonu ──
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
