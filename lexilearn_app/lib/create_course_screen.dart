import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  String? _selectedLevel;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  void _saveCourse() {
    if (_courseNameController.text.isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kurs adı ve seviye seçiniz')),
      );
      return;
    }

    // Backend hazır olunca buraya API çağrısı gelecek
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kurs oluşturuldu: ${_courseNameController.text} - $_selectedLevel')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kurs Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kurs Adı', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                hintText: 'Kurs adını giriniz',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Seviye', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._levels.map((level) => RadioListTile<String>(
                  title: Text(level),
                  value: level,
                  groupValue: _selectedLevel,
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  },
                )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCourse,
                child: const Text('Kursu Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}