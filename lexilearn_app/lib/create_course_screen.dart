import 'package:flutter/material.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  String? _selectedLevel;

  // Veritabanı şemasına uygun seviyeler 
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  void _saveCourse() {
    if (_courseNameController.text.isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a course name and select a level')),
      );
      return;
    }

    // Task 4.1 ve 4.3 kapsamında veritabanına kayıt simülasyonu [cite: 24, 26]
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course Created: ${_courseNameController.text} - $_selectedLevel')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Buradaki tırnak hatası düzeltildi
        title: const Text('Create New Course'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Course Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                hintText: 'Enter course name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Difficulty Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // User Story 4 - Task 4.1 UI implementation [cite: 24]
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
                child: const Text('Save Course'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}