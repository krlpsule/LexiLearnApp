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

  // Yeni kategori oluşturuyor (backend'e form data olarak POST atıyor)
  Future<void> _createDomain() async {
    if (_newDomainController.text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/domain'),
        body: {'domainName': _newDomainController.text.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _newDomainController.clear();
        await _fetchDomains(); // Listeyi güncelle
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error creating domain: $e');
    }
  }

  // Kursu backend'e kaydediyor (form data olarak)
  Future<void> _saveCourse() async {
    if (_courseNameController.text.isEmpty ||
        _selectedLevel == null ||
        _selectedDomainId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/study'),
        body: {
          'title': _courseNameController.text.trim(),
          'level': _selectedLevel,
          'domainId': _selectedDomainId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Course saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // SİYAH EKRAN ÇÖZÜMÜ: Sayfayı kapatmak yerine kutucukları temizle
          setState(() {
            _courseNameController.clear();
            _selectedLevel = null;
            _selectedDomainId = null;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            // ── Ders Adı ──
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

            // ── Kategori Dropdown ──
            const Text(
              'Category (Domain)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDomainId,
              hint: const Text('Select a category'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _domains.map<DropdownMenuItem<String>>((domain) {
                // Null hatasını engellemek için farklı isimlendirmeleri (domainName, domain_name) kontrol ediyoruz
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
                            'Unknown Category')
                        .toString();

                return DropdownMenuItem<String>(
                  value: id.isNotEmpty ? id : null,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDomainId = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // ── Yeni Kategori Ekleme Alanı ──
            const Text(
              'Or Create New Category',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
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

            // ── Kaydet Butonu ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveCourse,
                child: const Text(
                  'Save Course',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
