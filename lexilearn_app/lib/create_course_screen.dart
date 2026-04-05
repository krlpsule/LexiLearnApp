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

  // DİKKAT: Android Emülatör kullanıyorsan 10.0.2.2 kalmalı.
  // Eğer Windows Desktop uygulamasında test ediyorsan burayı 'http://localhost:8080' yap.
  final String baseUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    _fetchDomains();
  }

  // API'den Kategorileri (Domainleri) Çekme
  Future<void> _fetchDomains() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/domains'));
      if (response.statusCode == 200) {
        setState(() {
          _domains = jsonDecode(response.body);
          if (_selectedDomainId != null &&
              !_domains.any(
                (d) => d['domainId'].toString() == _selectedDomainId,
              )) {
            _selectedDomainId = null;
          }
        });
      }
    } catch (e) {
      print('Domainleri çekerken hata: $e');
    }
  }

  // Yeni Kategori (Domain) Ekleme
  Future<void> _createNewDomain(String domainName) async {
    if (domainName.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/domain'),
        body: {'domainName': domainName},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New Category Added: $domainName')),
        );
        _newDomainController.clear();
        Navigator.of(context).pop(); // Açılır pencereyi kapat
        await _fetchDomains(); // Listeyi yenile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category could not be added!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connection error: $e')));
    }
  }

  // Yeni Kategori Ekleme Penceresini (Dialog) Göster
  void _showAddDomainDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _newDomainController,
            decoration: const InputDecoration(
              hintText: 'Category Name (e.g., Biology)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  _createNewDomain(_newDomainController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Kursu (Study) Kaydetme
  Future<void> _saveCourse() async {
    if (_courseNameController.text.isEmpty ||
        _selectedLevel == null ||
        _selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/study'),
        body: {
          'domainId': _selectedDomainId!,
          'title': _courseNameController.text,
          'level': _selectedLevel!,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course created successfully!')),
        );
        _courseNameController.clear();
        setState(() {
          _selectedLevel = null;
          _selectedDomainId = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category (Domain)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Dropdown ve Ekleme Butonu Yan Yana
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedDomainId,
                    items: _domains.map<DropdownMenuItem<String>>((domain) {
                      return DropdownMenuItem<String>(
                        value: domain['domainId'].toString(),
                        child: Text(domain['domainName']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDomainId = value),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Please select a category'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    tooltip: 'Add New Category',
                    onPressed: _showAddDomainDialog,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Course Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(
                hintText: 'Please enter the course name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._levels.map(
              (level) => RadioListTile<String>(
                title: Text(level),
                value: level,
                groupValue: _selectedLevel,
                onChanged: (value) => setState(() => _selectedLevel = value),
              ),
            ),

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
