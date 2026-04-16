import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_question_screen.dart';

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
                'Welcome back, ${widget.username}!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Role: ${widget.userRole}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // PROFESSOR DASHBOARD VIEW
              if (widget.userRole == 'Professor') ...[
                Text(
                  'You have created ${professorStats.length} quiz(zes).',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),
                if (professorStats.isEmpty)
                  const Text("You haven't created any studies yet.", style: TextStyle(fontSize: 16))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // allow SingleChildScrollView to handle scrolling
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
                              Text('👥 ${stat['studentCount']} student(s) took your quiz.', style: const TextStyle(fontSize: 16)),
                              Text('📈 Average success rate: ${stat['avgSuccess'].toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CreateQuestionScreen()), 
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Wanna add question to that quiz?'),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
              ] 
              // STUDENT DASHBOARD VIEW
              else ...[
                const Text(
                  'Student statistics coming soon...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
