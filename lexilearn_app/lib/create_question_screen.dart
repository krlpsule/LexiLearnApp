import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'language_manager.dart';

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

  Widget _buildAnswerSection() {
if (_selectedQuestionType == 'multiple_choice') {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
LanguageManager.getText('options'),
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 4),
Text(
LanguageManager.getText('click_circle_correct'),
style: const TextStyle(fontSize: 12, color: Colors.grey),
),
const SizedBox(height: 12),
...List.generate(_answerControllers.length, (index) {
return Padding(
padding: const EdgeInsets.only(bottom: 10),
child: Row(
children: [
Radio(
value: index,
groupValue: _correctAnswerIndex,
onChanged: (value) => setState(() => _correctAnswerIndex = value),
activeColor: Colors.green,
fillColor: WidgetStateProperty.resolveWith((states) {
if (_correctAnswerIndex == index) return Colors.green;
return Colors.grey.shade400;
}),
),
Expanded(
child: TextField(
controller: _answerControllers[index],
decoration: InputDecoration(
hintText: '${LanguageManager.getText('option_prefix')} ${index + 1}',
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
label: Text(LanguageManager.getText('add_another_option')),
),
],
);
} else if (_selectedQuestionType == 'true_false') {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
LanguageManager.getText('select_correct_answer'),
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
Row(
children: [
Radio(
value: 0,
groupValue: _correctAnswerIndex,
onChanged: (value) => setState(() => _correctAnswerIndex = value),
activeColor: Colors.green,
),
Text(LanguageManager.getText('true_option'), style: const TextStyle(fontSize: 16)),
const SizedBox(width: 24),
Radio(
value: 1,
groupValue: _correctAnswerIndex,
onChanged: (value) => setState(() => _correctAnswerIndex = value),
activeColor: Colors.green,
),
Text(LanguageManager.getText('false_option'), style: const TextStyle(fontSize: 16)),
],
),
],
);
} else if (_selectedQuestionType == 'fill_in_blank') {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
LanguageManager.getText('correct_answer_word'),
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
Text(
LanguageManager.getText('students_type_exact'),
style: const TextStyle(fontSize: 12, color: Colors.grey),
),
const SizedBox(height: 12),
TextField(
controller: _answerControllers[0],
decoration: const InputDecoration(
hintText: '...',
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
return ValueListenableBuilder(
valueListenable: LanguageManager.currentLang,
builder: (context, lang, child) {
return Scaffold(
appBar: AppBar(
title: Text(LanguageManager.getText('create_question_title')),
backgroundColor: Theme.of(context).colorScheme.inversePrimary,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
LanguageManager.getText('select_category_domain'),
style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
const SizedBox(height: 8),
DropdownButtonFormField(
value: _selectedDomainId,
hint: Text(LanguageManager.getText('select_category_hint')),
decoration: const InputDecoration(border: OutlineInputBorder()),
items: _domains.map<DropdownMenuItem>((domain) {
String id = (domain['domainId'] ?? domain['domain_id'] ?? domain['id'] ?? '').toString();
String name = (domain['domainName'] ?? domain['domain_name'] ?? domain['name'] ?? 'Unknown').toString();
return DropdownMenuItem(value: id.isNotEmpty ? id : null, child: Text(name));
}).toList(),
onChanged: (value) => setState(() {
_selectedDomainId = value;
_filterStudies();
}),
),
const SizedBox(height: 24),

            Text(
              LanguageManager.getText('which_study_add'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStudyId,
              hint: Text(
                _selectedDomainId == null
                    ? LanguageManager.getText('first_select_category')
                    : LanguageManager.getText('select_study_hint'),
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _filteredStudies.map<DropdownMenuItem<String>>((study) {
                String id = (study['studyId'] ?? study['study_id'] ?? '').toString();
                String title = (study['title'] ?? study['name'] ?? 'Unknown Study').toString();
                return DropdownMenuItem<String>(value: id.isNotEmpty ? id : null, child: Text(title));
              }).toList(),
              onChanged: _selectedDomainId == null ? null : (value) => setState(() => _selectedStudyId = value),
            ),
            const SizedBox(height: 24),

            Text(
              LanguageManager.getText('question_type'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedQuestionType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _questionTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  // Dynamically translate the type name
                  child: Text(LanguageManager.getText(type['value']!)), 
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestionType = value!;
                  _correctAnswerIndex = null;
                });
              },
            ),
            const SizedBox(height: 24),

            Text(
              LanguageManager.getText('question_text_label'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: LanguageManager.getText('enter_question_text'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              LanguageManager.getText('difficulty_level'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              items: _levels
                  .map((l) => DropdownMenuItem(value: l, child: Text(LanguageManager.getText(l.toLowerCase()))))
                  .toList(),
              onChanged: (val) => setState(() => _selectedLevel = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: Text(LanguageManager.getText('select_level')),
            ),
            const SizedBox(height: 24),

            _buildAnswerSection(),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _saveQuestion,
                child: Text(
                  LanguageManager.getText('save_question'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
);
