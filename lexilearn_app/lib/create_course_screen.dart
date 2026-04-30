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

  // Kategorileri backend'den çekiyor
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

  // Yeni kategori oluşturuyor (backend'e POST atıyor)
  Future<void> _createDomain() async {
    if (_newDomainController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/domains'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': _newDomainController.text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _newDomainController.clear();
        _fetchDomains(); // Listeyi güncelle
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category created!')),
        );
      }
    } catch (e) {
      print('Error creating domain: $e');
    }
  }

  // Kursu gerçekten backend'e kaydediyor
  Future<void> _saveCourse() async {
    if (_courseNameController.text.isEmpty ||
        _selectedLevel == null ||
        _selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select a category')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/study'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _courseNameController.text,
          'level': _selectedLevel,
          'domainId': _selectedDomainId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
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
      appBar: AppBar(
        title: const Text('Create New Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ders Adı ──
            const Text('Course Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                hintText: 'Enter course name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Kategori Dropdown (YENİ) ──
            const Text('Category (Domain)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDomainId,
              hint: const Text('Select a category'),
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
                });
              },
            ),
            const SizedBox(height: 16),

            // ── Yeni Kategori Ekleme Alanı (YENİ) ──
            const Text('Or Create New Category',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newDomainController,
                    decoration: const InputDecoration(
                      hintText: 'New category name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createDomain,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Seviye Seçimi ──
            const Text('Difficulty Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

            // ── Kaydet Butonu ──
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