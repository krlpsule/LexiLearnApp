import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_question_screen.dart';
import 'language_manager.dart';

class DashboardScreen extends StatefulWidget {
  final int userId; // Now requires userId to fetch custom data
  final String username;
  final String userRole;
  
  const DashboardScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.userRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> professorStats = [];
  bool isLoading = true;
  final String backendUrl = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
    if (widget.userRole == 'Professor') {
      _fetchProfessorStats();
    } else {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _fetchProfessorStats() async {
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/professor/stats?userId=${widget.userId}')
      );
      
      if (response.statusCode == 200) {
        setState(() {
          professorStats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // Handle error visually if necessary
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  
@override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ADDED: ValueListenableBuilder watches for language changes
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(
                    // CHANGED: Using LanguageManager for translation
                    '${LanguageManager.getText('welcome_back')}, ${widget.username}!',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    // CHANGED
                    '${LanguageManager.getText('role')}: ${LanguageManager.getText(widget.userRole.toLowerCase())}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  if (widget.userRole == 'Professor') ...[
                    Text(
                      // CHANGED
                      '${LanguageManager.getText('quizzes_created_part1')} ${professorStats.length} ${LanguageManager.getText('quizzes_created_part2')}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 20),
                    if (professorStats.isEmpty)
                      Text(LanguageManager.getText('no_studies_created'), style: const TextStyle(fontSize: 16))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: professorStats.length,
                        itemBuilder: (context, index) {
                          final stat = professorStats[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${stat['title']}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('👥 ${stat['studentCount']} ${LanguageManager.getText('students_took_quiz')}', style: const TextStyle(fontSize: 16)),
                                  Text('📈 ${LanguageManager.getText('avg_success_rate')} ${stat['avgSuccess'].toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const CreateQuestionScreen()), 
                                        );
                                        setState(() {
                                          isLoading = true;
                                        });
                                        _fetchProfessorStats();
                                      },
                                      icon: const Icon(Icons.add),
                                      label: Text(LanguageManager.getText('add_question_btn')),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                  ] else ...[
                    Text(
                      LanguageManager.getText('student_stats_coming'),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }
    );
  }
