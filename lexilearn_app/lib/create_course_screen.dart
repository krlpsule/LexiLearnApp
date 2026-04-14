import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _newDomainController = TextEditingController();

  String? _selectedLevel;
  String? _selectedDomainId;
  List<dynamic> _domains = [];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _fetchDomains();
  }

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

  Future<void> _saveCourse() async {
    if (_courseNameController.text.isEmpty || _selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a course name and select a level'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Course Created: ${_courseNameController.text} - $_selectedLevel',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                hintText: 'Enter course name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Difficulty Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._levels.map(
              (level) => RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value;
                  });
                },
              ),
            ),
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
